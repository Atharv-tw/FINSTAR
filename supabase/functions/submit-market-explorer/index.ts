/**
 * Submit Market Explorer Game Result
 *
 * Validates game data, calculates rewards, and updates user progress
 */

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { initializeFirebase, FieldValue } from "../_shared/firebase.ts";
import { handleCors, jsonResponse, errorResponse, verifyAuthToken } from "../_shared/cors.ts";
import {
  GAME_IDS,
  calculateMarketExplorerRewards,
  calculateLevel,
  getTodayIST,
  updateChallengeProgress,
} from "../_shared/utils.ts";

interface MarketExplorerSubmission {
  portfolioValue: number;
  initialValue: number;
  portfolio: Record<string, number>;
  decisionsCount: number;
  daysSimulated?: number;
  trades?: unknown[];
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
    const body: MarketExplorerSubmission = await req.json();
    const { portfolioValue, initialValue, portfolio, decisionsCount, daysSimulated } = body;

    // Validate required fields
    if (portfolioValue === undefined || initialValue === undefined || !portfolio || decisionsCount === undefined) {
      return errorResponse("Missing required fields: portfolioValue, initialValue, portfolio, decisionsCount");
    }

    // Validate values
    if (initialValue <= 0) {
      return errorResponse("Invalid initialValue: must be positive");
    }

    if (portfolioValue < 0) {
      return errorResponse("Invalid portfolioValue: cannot be negative");
    }

    // Calculate portfolio return
    const portfolioReturn = (portfolioValue - initialValue) / initialValue;

    // Calculate diversification score (0-1 based on number of different assets)
    const assetCount = Object.keys(portfolio).filter((key) => portfolio[key] > 0).length;
    const diversificationScore = Math.min(assetCount / 5, 1); // Max at 5 assets

    // Calculate rewards
    const rewards = calculateMarketExplorerRewards(
      portfolioReturn,
      diversificationScore,
      decisionsCount
    );
    const xpEarned = rewards.xp;
    const coinsEarned = rewards.coins;

    // Calculate score for leaderboard (0-1000 scale)
    const returnScore = Math.min(Math.max(portfolioReturn * 500 + 500, 0), 800); // Return component
    const diversificationBonus = diversificationScore * 200; // Diversification component
    const score = Math.floor(returnScore + diversificationBonus);

    // Update user progress in transaction
    const result = await db.runTransaction(async (t) => {
      const userRef = db.collection("users").doc(uid);
      const progressRef = userRef.collection("progress").doc(GAME_IDS.MARKET_EXPLORER);

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
          bestReturn: Math.max(progressData.bestReturn || -1, portfolioReturn),
          timesPlayed: FieldValue.increment(1),
          totalXp: FieldValue.increment(xpEarned),
          totalCoins: FieldValue.increment(coinsEarned),
          lastPlayed: new Date().toISOString(),
          totalDecisions: FieldValue.increment(decisionsCount),
          lastPortfolio: portfolio,
          lastPortfolioValue: portfolioValue,
        });
      } else {
        t.set(progressRef, {
          gameId: GAME_IDS.MARKET_EXPLORER,
          highScore: score,
          bestReturn: portfolioReturn,
          timesPlayed: 1,
          totalXp: xpEarned,
          totalCoins: coinsEarned,
          lastPlayed: new Date().toISOString(),
          totalDecisions: decisionsCount,
          lastPortfolio: portfolio,
          lastPortfolioValue: portfolioValue,
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
        portfolioReturn: Math.round(portfolioReturn * 10000) / 100, // Percentage with 2 decimals
        diversificationScore: Math.round(diversificationScore * 100),
        gamesPlayed: gamesPlayed + 1,
      };
    });

    console.log(`Market Explorer completed by ${uid}: ${xpEarned} XP, ${coinsEarned} coins, ${Math.round(portfolioReturn * 100)}% return`);

    // Update daily challenge progress (non-blocking)
    updateChallengeProgress(db, uid, {
      gamesPlayed: 1,
      xpEarned,
      coinsEarned,
    }).catch((e) => console.error("Challenge progress update failed:", e));

    return jsonResponse(result);
  } catch (error) {
    console.error("Error in submit-market-explorer:", error);
    return errorResponse(error.message || "Internal server error", 500);
  }
});
