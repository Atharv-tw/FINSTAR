/**
 * Submit Quiz Battle Game Result
 *
 * Validates game data, calculates rewards, and updates user progress
 */

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { initializeFirebase, warmupFirebase, FieldValue } from "../_shared/firebase-rest.ts";
import { handleCors, jsonResponse, errorResponse, verifyAuthTokenLight } from "../_shared/cors.ts";
import {
  GAME_IDS,
  calculateQuizBattleRewards,
  calculateLevel,
  getTodayIST,
  updateChallengeProgress,
} from "../_shared/utils.ts";

interface QuizBattleSubmission {
  correctAnswers: number;
  totalQuestions: number;
  timeBonus: number;
  isWinner?: boolean;
  matchId?: string;
  opponentUid?: string;
  category?: string;
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
    const body: QuizBattleSubmission = await req.json();
    const { correctAnswers, totalQuestions, timeBonus, isWinner, matchId, opponentUid, category } = body;

    // Validate required fields
    if (correctAnswers === undefined || totalQuestions === undefined || timeBonus === undefined) {
      return errorResponse("Missing required fields: correctAnswers, totalQuestions, timeBonus");
    }

    // Validate bounds
    if (correctAnswers < 0 || correctAnswers > totalQuestions) {
      return errorResponse("Invalid correctAnswers: cannot exceed totalQuestions");
    }

    if (totalQuestions < 1 || totalQuestions > 50) {
      return errorResponse("Invalid totalQuestions: must be between 1 and 50");
    }

    if (timeBonus < 0 || timeBonus > 100) {
      return errorResponse("Invalid timeBonus: must be between 0 and 100");
    }

    // Calculate rewards
    const rewards = calculateQuizBattleRewards(
      correctAnswers,
      totalQuestions,
      timeBonus,
      isWinner || false
    );
    const xpEarned = rewards.xp;
    const coinsEarned = rewards.coins;
    const isPerfect = correctAnswers === totalQuestions;

    // Update user progress in transaction
    const result = await db.runTransaction(async (t) => {
      const userRef = db.collection("users").doc(uid);
      const progressRef = userRef.collection("progress").doc(GAME_IDS.QUIZ_BATTLE);

      const userDoc = await t.get(userRef);
      const progressDoc = await t.get(progressRef);

      if (!userDoc.exists) {
        throw new Error("User not found");
      }

      const userData = userDoc.data()!;
      const currentXp = userData.xp || 0;
      const currentCoins = userData.coins || 0;
      const currentLevel = userData.level || 1;
      const gamesPlayed = userData.gamesPlayed || 0;

      const newTotalXp = currentXp + xpEarned;
      const levelData = calculateLevel(newTotalXp);
      const leveledUp = levelData.level > currentLevel;

      // Calculate score for this quiz
      const score = correctAnswers * 100 + Math.floor(timeBonus);

      // Update user profile
      t.update(userRef, {
        xp: newTotalXp,
        level: levelData.level,
        coins: FieldValue.increment(coinsEarned),
        lastActiveDate: getTodayIST(),
        gamesPlayed: FieldValue.increment(1),
      });

      // Update or create game progress
      if (progressDoc.exists) {
        const progressData = progressDoc.data()!;
        const updates: Record<string, unknown> = {
          highScore: Math.max(progressData.highScore || 0, score),
          timesPlayed: FieldValue.increment(1),
          totalXp: FieldValue.increment(xpEarned),
          totalCoins: FieldValue.increment(coinsEarned),
          lastPlayed: new Date().toISOString(),
          totalCorrectAnswers: FieldValue.increment(correctAnswers),
          totalQuestions: FieldValue.increment(totalQuestions),
        };

        if (isPerfect) {
          updates.perfectScores = FieldValue.increment(1);
        }

        if (isWinner) {
          updates.wins = FieldValue.increment(1);
        } else if (isWinner === false) {
          updates.losses = FieldValue.increment(1);
        }

        t.update(progressRef, updates);
      } else {
        t.set(progressRef, {
          gameId: GAME_IDS.QUIZ_BATTLE,
          highScore: score,
          timesPlayed: 1,
          totalXp: xpEarned,
          totalCoins: coinsEarned,
          lastPlayed: new Date().toISOString(),
          totalCorrectAnswers: correctAnswers,
          totalQuestions: totalQuestions,
          perfectScores: isPerfect ? 1 : 0,
          wins: isWinner ? 1 : 0,
          losses: isWinner === false ? 1 : 0,
        });
      }

      return {
        success: true,
        xpEarned,
        coinsEarned,
        newLevel: levelData.level,
        newXp: newTotalXp,
        leveledUp,
        xpForNextLevel: levelData.xpForNextLevel,
        score,
        isPerfect,
        accuracy: Math.round((correctAnswers / totalQuestions) * 100),
        gamesPlayed: gamesPlayed + 1,
      };
    });

    console.log(`Quiz Battle completed by ${uid}: ${xpEarned} XP, ${coinsEarned} coins, ${correctAnswers}/${totalQuestions} correct`);

    // Update daily challenge progress (non-blocking)
    updateChallengeProgress(db, uid, {
      gamesPlayed: 1,
      xpEarned,
      coinsEarned,
      perfectScore: isPerfect,
      quizWon: isWinner || false,
    }).catch((e) => console.error("Challenge progress update failed:", e));

    return jsonResponse(result);
  } catch (error) {
    console.error("Error in submit-quiz-battle:", error);
    return errorResponse(error.message || "Internal server error", 500);
  }
});
