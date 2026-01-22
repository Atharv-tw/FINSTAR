/**
 * Submit Life Swipe Game Result
 *
 * Validates game data, calculates rewards, and updates user progress
 */

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { initializeFirebase, warmupFirebase, FieldValue } from "../_shared/firebase-rest.ts";
import { handleCors, jsonResponse, errorResponse, verifyAuthTokenLight } from "../_shared/cors.ts";
import {
  GAME_IDS,
  calculateLifeSwipeRewards,
  calculateLevel,
  validateScore,
  getTodayIST,
  updateChallengeProgress,
} from "../_shared/utils.ts";

interface LifeSwipeSubmission {
  seed: number;
  allocations: Record<string, number>;
  score: number;
  eventChoices?: unknown[];
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
    const body: LifeSwipeSubmission = await req.json();
    const { seed, allocations, score, eventChoices } = body;

    // Validate required fields
    if (seed === undefined || !allocations || score === undefined) {
      return errorResponse("Missing required fields: seed, allocations, score");
    }

    // Validate allocations sum to 10000 (representing 100.00%)
    const total = Object.values(allocations).reduce((sum, val) => sum + val, 0);
    if (total !== 10000) {
      return errorResponse(`Allocations must sum to 10000, got ${total}`);
    }

    // Validate score bounds (0-1000)
    if (!validateScore(score, 0, 1000)) {
      return errorResponse("Invalid score: must be between 0 and 1000");
    }

    // Calculate rewards
    const rewards = calculateLifeSwipeRewards(allocations, score);
    const xpEarned = rewards.xp;
    const coinsEarned = rewards.coins;

    // Update user progress in transaction
    const result = await db.runTransaction(async (t) => {
      const userRef = db.collection("users").doc(uid);
      const progressRef = userRef.collection("progress").doc(GAME_IDS.LIFE_SWIPE);

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
          timesPlayed: FieldValue.increment(1),
          totalXp: FieldValue.increment(xpEarned),
          totalCoins: FieldValue.increment(coinsEarned),
          lastPlayed: new Date().toISOString(),
          bestSavingsRate: Math.max(progressData.bestSavingsRate || 0, rewards.savingsRate),
          lastAllocations: allocations,
          lastSeed: seed,
        });
      } else {
        t.set(progressRef, {
          gameId: GAME_IDS.LIFE_SWIPE,
          highScore: score,
          timesPlayed: 1,
          totalXp: xpEarned,
          totalCoins: coinsEarned,
          lastPlayed: new Date().toISOString(),
          bestSavingsRate: rewards.savingsRate,
          lastAllocations: allocations,
          lastSeed: seed,
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
        savingsRate: rewards.savingsRate,
        gamesPlayed: gamesPlayed + 1,
      };
    });

    console.log(`Life Swipe completed by ${uid}: ${xpEarned} XP, ${coinsEarned} coins`);

    // Update daily challenge progress (non-blocking)
    updateChallengeProgress(db, uid, {
      gamesPlayed: 1,
      xpEarned,
      coinsEarned,
    }).catch((e) => console.error("Challenge progress update failed:", e));

    return jsonResponse(result);
  } catch (error) {
    console.error("Error in submit-life-swipe:", error);
    return errorResponse(error.message || "Internal server error", 500);
  }
});
