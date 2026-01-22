/**
 * Complete Lesson
 *
 * Handles lesson completion, awards XP/coins, and tracks progress
 */

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { initializeFirebase, warmupFirebase, FieldValue } from "../_shared/firebase-rest.ts";
import { handleCors, jsonResponse, errorResponse, verifyAuthTokenLight } from "../_shared/cors.ts";
import { calculateLevel, getTodayIST, updateChallengeProgress } from "../_shared/utils.ts";

interface CompleteLessonRequest {
  lessonId: string;
  quizScore?: number;
  timeSpent?: number; // seconds
}

serve(async (req: Request) => {
  // Handle CORS preflight
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    // Start Firebase warmup in parallel with auth verification
    const warmupPromise = warmupFirebase();

    // Verify authentication (in parallel with warmup)
    const [user] = await Promise.all([
      verifyAuthTokenLight(req),
      warmupPromise,
    ]);

    if (!user) {
      return errorResponse("Unauthorized: Invalid or missing authentication token", 401);
    }

    // Initialize Firebase (token should be cached)
    const { db } = initializeFirebase();

    const uid = user.uid;

    // Parse request body
    const body: CompleteLessonRequest = await req.json();
    const { lessonId, quizScore, timeSpent } = body;

    if (!lessonId) {
      return errorResponse("Missing required field: lessonId");
    }

    // Get lesson details (optional - for custom rewards)
    const lessonDoc = await db.collection("lessons").doc(lessonId).get();

    // Default rewards
    let xpReward = 50;
    let coinReward = 10;

    // Use lesson-specific rewards if available
    if (lessonDoc.exists) {
      const lessonData = lessonDoc.data()!;
      xpReward = lessonData.xpReward || xpReward;
      coinReward = lessonData.coinReward || coinReward;
    }

    // Quiz score bonus (if applicable)
    if (quizScore !== undefined && quizScore > 0) {
      const quizBonus = Math.floor(quizScore / 10); // 1 XP per 10% score
      xpReward += quizBonus;

      // Perfect score bonus
      if (quizScore === 100) {
        xpReward += 20;
        coinReward += 5;
      }
    }

    // Check if already completed
    const progressRef = db
      .collection("users")
      .doc(uid)
      .collection("lessonProgress")
      .doc(lessonId);

    const progressDoc = await progressRef.get();

    if (progressDoc.exists && progressDoc.data()?.completed) {
      // Already completed - award reduced rewards
      xpReward = Math.floor(xpReward * 0.2); // 20% for replay
      coinReward = Math.floor(coinReward * 0.2);

      if (xpReward === 0) xpReward = 5;
      if (coinReward === 0) coinReward = 2;
    }

    // Update user progress in transaction
    const result = await db.runTransaction(async (t) => {
      const userRef = db.collection("users").doc(uid);
      const userDoc = await t.get(userRef);

      if (!userDoc.exists) {
        throw new Error("User not found");
      }

      const userData = userDoc.data()!;
      const currentXp = userData.xp || 0;
      const currentLevel = userData.level || 1;
      const lessonsCompleted = userData.lessonsCompleted || 0;

      const newTotalXp = currentXp + xpReward;
      const levelData = calculateLevel(newTotalXp);
      const leveledUp = levelData.level > currentLevel;

      // Update user profile
      const userUpdates: Record<string, unknown> = {
        xp: newTotalXp,
        level: levelData.level,
        coins: FieldValue.increment(coinReward),
        lastActiveDate: getTodayIST(),
      };

      // Only increment lessonsCompleted if first time
      if (!progressDoc.exists || !progressDoc.data()?.completed) {
        userUpdates.lessonsCompleted = FieldValue.increment(1);
      }

      t.update(userRef, userUpdates);

      // Save or update lesson progress
      const progressData: Record<string, unknown> = {
        lessonId,
        completed: true,
        completedAt: new Date().toISOString(),
        lastAttemptAt: new Date().toISOString(),
        xpEarned: FieldValue.increment(xpReward),
        coinsEarned: FieldValue.increment(coinReward),
        attempts: FieldValue.increment(1),
      };

      if (quizScore !== undefined) {
        progressData.quizScore = quizScore;
        progressData.bestQuizScore = progressDoc.exists
          ? Math.max(progressDoc.data()?.bestQuizScore || 0, quizScore)
          : quizScore;
      }

      if (timeSpent !== undefined) {
        progressData.lastTimeSpent = timeSpent;
        progressData.totalTimeSpent = FieldValue.increment(timeSpent);
      }

      t.set(progressRef, progressData, { merge: true });

      return {
        success: true,
        xpEarned: xpReward,
        coinsEarned: coinReward,
        newLevel: levelData.level,
        newXp: newTotalXp,
        leveledUp,
        xpForNextLevel: levelData.xpForNextLevel,
        isFirstCompletion: !progressDoc.exists || !progressDoc.data()?.completed,
        lessonsCompleted: (progressDoc.exists && progressDoc.data()?.completed)
          ? lessonsCompleted
          : lessonsCompleted + 1,
      };
    });

    console.log(`Lesson ${lessonId} completed by ${uid}: ${xpReward} XP, ${coinReward} coins`);

    // Update daily challenge progress (non-blocking)
    // Only count first completion for lesson challenges
    if (result.isFirstCompletion) {
      updateChallengeProgress(db, uid, {
        lessonsCompleted: 1,
        xpEarned: xpReward,
        coinsEarned: coinReward,
      }).catch((e) => console.error("Challenge progress update failed:", e));
    }

    return jsonResponse(result);
  } catch (error) {
    console.error("Error in complete-lesson:", error);
    return errorResponse(error.message || "Internal server error", 500);
  }
});
