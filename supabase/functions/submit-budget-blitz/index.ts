/**
 * Submit Budget Blitz Game Result
 *
 * Validates game data, calculates rewards, and updates user progress
 */

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { initializeFirebase, FieldValue } from "../_shared/firebase.ts";
import { handleCors, jsonResponse, errorResponse, verifyAuthToken } from "../_shared/cors.ts";
import {
  GAME_IDS,
  calculateBudgetBlitzRewards,
  calculateLevel,
  validateScore,
  getTodayIST,
  updateChallengeProgress,
} from "../_shared/utils.ts";

interface BudgetBlitzSubmission {
  score: number;
  level: number;
  correctDecisions: number;
  totalDecisions: number;
  timeRemaining?: number;
}

serve(async (req: Request) => {
  // Handle CORS preflight
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    // Initialize Firebase
    const { db, auth } = initializeFirebase();

    // Verify authentication
    const user = await verifyAuthToken(req, auth);
    if (!user) {
      return errorResponse("Unauthorized: Invalid or missing authentication token", 401);
    }

    const uid = user.uid;

    // Parse request body
    const body: BudgetBlitzSubmission = await req.json();
    const { score, level, correctDecisions, totalDecisions, timeRemaining } = body;

    // Validate required fields
    if (score === undefined || level === undefined || correctDecisions === undefined || totalDecisions === undefined) {
      return errorResponse("Missing required fields: score, level, correctDecisions, totalDecisions");
    }

    // Validate score bounds
    if (!validateScore(score, 0, 10000)) {
      return errorResponse("Invalid score: must be between 0 and 10000");
    }

    // Validate level
    if (level < 1 || level > 100) {
      return errorResponse("Invalid level: must be between 1 and 100");
    }

    // Calculate accuracy
    const accuracy = totalDecisions > 0 ? correctDecisions / totalDecisions : 0;

    // Calculate rewards
    const rewards = calculateBudgetBlitzRewards(score, level, accuracy);
    const xpEarned = rewards.xp;
    const coinsEarned = rewards.coins;

    // Update user progress in transaction
    const result = await db.runTransaction(async (t) => {
      const userRef = db.collection("users").doc(uid);
      const progressRef = userRef.collection("progress").doc(GAME_IDS.BUDGET_BLITZ);

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
        t.update(progressRef, {
          highScore: Math.max(progressData.highScore || 0, score),
          highestLevel: Math.max(progressData.highestLevel || 0, level),
          timesPlayed: FieldValue.increment(1),
          totalXp: FieldValue.increment(xpEarned),
          totalCoins: FieldValue.increment(coinsEarned),
          lastPlayed: new Date().toISOString(),
          totalCorrectDecisions: FieldValue.increment(correctDecisions),
          totalDecisions: FieldValue.increment(totalDecisions),
        });
      } else {
        t.set(progressRef, {
          gameId: GAME_IDS.BUDGET_BLITZ,
          highScore: score,
          highestLevel: level,
          timesPlayed: 1,
          totalXp: xpEarned,
          totalCoins: coinsEarned,
          lastPlayed: new Date().toISOString(),
          totalCorrectDecisions: correctDecisions,
          totalDecisions: totalDecisions,
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
        accuracy: Math.round(accuracy * 100),
        gamesPlayed: gamesPlayed + 1,
      };
    });

    console.log(`Budget Blitz completed by ${uid}: ${xpEarned} XP, ${coinsEarned} coins, level ${level}`);

    // Update daily challenge progress (non-blocking)
    updateChallengeProgress(db, uid, {
      gamesPlayed: 1,
      xpEarned,
      coinsEarned,
    }).catch((e) => console.error("Challenge progress update failed:", e));

    return jsonResponse(result);
  } catch (error) {
    console.error("Error in submit-budget-blitz:", error);
    return errorResponse(error.message || "Internal server error", 500);
  }
});
