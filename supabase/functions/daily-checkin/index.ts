/**
 * Daily Check-In
 *
 * Handles user daily check-in, streak tracking, and bonus rewards
 */

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { initializeFirebase, FieldValue } from "../_shared/firebase.ts";
import { handleCors, jsonResponse, errorResponse, verifyAuthToken } from "../_shared/cors.ts";
import { getTodayIST, getYesterdayIST, calculateLevel, STREAK_BONUSES } from "../_shared/utils.ts";

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
    const today = getTodayIST();
    const yesterday = getYesterdayIST();

    // Use transaction for atomic update
    const result = await db.runTransaction(async (t) => {
      const userRef = db.collection("users").doc(uid);
      const userDoc = await t.get(userRef);

      if (!userDoc.exists) {
        throw new Error("User not found");
      }

      const userData = userDoc.data()!;
      const lastActiveDate = userData.lastActiveDate;
      const currentStreak = userData.streakDays || 0;
      const currentXp = userData.xp || 0;
      const currentLevel = userData.level || 1;

      // Check if already checked in today
      if (lastActiveDate === today) {
        return {
          success: false,
          alreadyCheckedIn: true,
          message: "Already checked in today!",
          streakDays: currentStreak,
        };
      }

      // Calculate new streak
      const isConsecutive = lastActiveDate === yesterday;
      const newStreak = isConsecutive ? currentStreak + 1 : 1;

      // Base rewards
      let xpReward = 20;
      let coinReward = 5;

      // Streak bonus (every 7 days)
      const streakMultiplier = Math.floor(newStreak / 7);
      xpReward += streakMultiplier * 10;
      coinReward += streakMultiplier * 5;

      // Milestone bonuses
      const milestoneBonus = STREAK_BONUSES[newStreak];
      if (milestoneBonus) {
        xpReward += milestoneBonus.xp;
        coinReward += milestoneBonus.coins;
      }

      // Calculate new level
      const newTotalXp = currentXp + xpReward;
      const levelData = calculateLevel(newTotalXp);
      const leveledUp = levelData.level > currentLevel;

      // Update user profile
      t.update(userRef, {
        xp: newTotalXp,
        level: levelData.level,
        coins: FieldValue.increment(coinReward),
        streakDays: newStreak,
        lastActiveDate: today,
        lastCheckInAt: new Date().toISOString(),
        totalCheckIns: FieldValue.increment(1),
      });

      // Record check-in history
      const checkInRef = userRef.collection("checkInHistory").doc(today);
      t.set(checkInRef, {
        date: today,
        streakDay: newStreak,
        xpEarned: xpReward,
        coinsEarned: coinReward,
        milestone: milestoneBonus ? newStreak : null,
        timestamp: new Date().toISOString(),
      });

      return {
        success: true,
        alreadyCheckedIn: false,
        streakDays: newStreak,
        xpEarned: xpReward,
        coinsEarned: coinReward,
        milestone: milestoneBonus ? newStreak : null,
        milestoneBonus: milestoneBonus || null,
        newLevel: levelData.level,
        leveledUp,
        message: `Check-in successful! ${newStreak} day streak!`,
      };
    });

    if (result.success) {
      console.log(`Daily check-in by ${uid}: streak ${result.streakDays}, ${result.xpEarned} XP`);
    }

    return jsonResponse(result);
  } catch (error) {
    console.error("Error in daily-checkin:", error);
    return errorResponse(error.message || "Internal server error", 500);
  }
});
