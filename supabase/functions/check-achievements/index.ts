/**
 * Check and Unlock Achievements
 *
 * Called after game completions, lessons, and other activities
 * to check if user has unlocked any new achievements
 */

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { initializeFirebase, warmupFirebase, FieldValue } from "../_shared/firebase-rest.ts";
import { handleCors, jsonResponse, errorResponse, verifyAuthTokenLight } from "../_shared/cors.ts";
import { ACHIEVEMENT_REWARDS } from "../_shared/utils.ts";

interface AchievementCheck {
  trigger?: string; // 'game' | 'lesson' | 'streak' | 'level' | 'coins'
}

// Achievement definitions with unlock conditions
const ACHIEVEMENTS = {
  // Game achievements
  first_game: {
    name: "First Steps",
    description: "Complete your first game",
    check: (data: UserData) => data.gamesPlayed >= 1,
    targetProgress: 1,
  },
  games_10: {
    name: "Getting Started",
    description: "Complete 10 games",
    check: (data: UserData) => data.gamesPlayed >= 10,
    targetProgress: 10,
  },
  games_50: {
    name: "Game Master",
    description: "Complete 50 games",
    check: (data: UserData) => data.gamesPlayed >= 50,
    targetProgress: 50,
  },

  // Lesson achievements
  lessons_5: {
    name: "Eager Learner",
    description: "Complete 5 lessons",
    check: (data: UserData) => data.lessonsCompleted >= 5,
    targetProgress: 5,
  },
  lessons_10: {
    name: "Knowledge Seeker",
    description: "Complete 10 lessons",
    check: (data: UserData) => data.lessonsCompleted >= 10,
    targetProgress: 10,
  },

  // Streak achievements
  streak_3: {
    name: "Consistent",
    description: "Maintain a 3-day streak",
    check: (data: UserData) => data.streakDays >= 3,
    targetProgress: 3,
  },
  streak_7: {
    name: "Week Warrior",
    description: "Maintain a 7-day streak",
    check: (data: UserData) => data.streakDays >= 7,
    targetProgress: 7,
  },
  streak_14: {
    name: "Dedicated",
    description: "Maintain a 14-day streak",
    check: (data: UserData) => data.streakDays >= 14,
    targetProgress: 14,
  },
  streak_30: {
    name: "Committed",
    description: "Maintain a 30-day streak",
    check: (data: UserData) => data.streakDays >= 30,
    targetProgress: 30,
  },

  // Level achievements
  level_5: {
    name: "Rising Star",
    description: "Reach level 5",
    check: (data: UserData) => data.level >= 5,
    targetProgress: 5,
  },
  level_10: {
    name: "Experienced",
    description: "Reach level 10",
    check: (data: UserData) => data.level >= 10,
    targetProgress: 10,
  },
  level_25: {
    name: "Veteran",
    description: "Reach level 25",
    check: (data: UserData) => data.level >= 25,
    targetProgress: 25,
  },

  // Coins achievements
  coins_1000: {
    name: "Saver",
    description: "Accumulate 1000 coins",
    check: (data: UserData) => data.totalCoinsEarned >= 1000,
    targetProgress: 1000,
  },
};

interface UserData {
  gamesPlayed: number;
  lessonsCompleted: number;
  streakDays: number;
  level: number;
  xp: number;
  coins: number;
  totalCoinsEarned: number;
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

    // Parse request body (optional trigger info)
    let body: AchievementCheck = {};
    try {
      body = await req.json();
    } catch {
      // No body is fine
    }

    // Get user data
    const userDoc = await db.collection("users").doc(uid).get();
    if (!userDoc.exists) {
      return errorResponse("User not found", 404);
    }

    const userData = userDoc.data()!;
    const userStats: UserData = {
      gamesPlayed: userData.gamesPlayed || 0,
      lessonsCompleted: userData.lessonsCompleted || 0,
      streakDays: userData.streakDays || 0,
      level: userData.level || 1,
      xp: userData.xp || 0,
      coins: userData.coins || 0,
      totalCoinsEarned: userData.totalCoinsEarned || userData.coins || 0,
    };

    // Get existing achievements
    const achievementsSnapshot = await db
      .collection("users")
      .doc(uid)
      .collection("achievements")
      .get();

    const existingAchievements = new Map<string, boolean>();
    achievementsSnapshot.docs.forEach((doc) => {
      const data = doc.data();
      existingAchievements.set(doc.id, data.unlocked || false);
    });

    // Check for new achievements
    const newlyUnlocked: Array<{
      id: string;
      name: string;
      xpReward: number;
      coinReward: number;
    }> = [];

    const batch = db.batch();
    let totalXpReward = 0;
    let totalCoinReward = 0;

    for (const [achievementId, achievement] of Object.entries(ACHIEVEMENTS)) {
      const isUnlocked = existingAchievements.get(achievementId);

      // Skip if already unlocked
      if (isUnlocked) continue;

      // Check if achievement condition is met
      if (achievement.check(userStats)) {
        const rewards = ACHIEVEMENT_REWARDS[achievementId] || { xp: 100, coins: 50 };

        // Create or update achievement document
        const achievementRef = db
          .collection("users")
          .doc(uid)
          .collection("achievements")
          .doc(achievementId);

        batch.set(
          achievementRef,
          {
            achievementId,
            name: achievement.name,
            description: achievement.description,
            unlocked: true,
            unlockedAt: new Date().toISOString(),
            currentProgress: achievement.targetProgress,
            targetProgress: achievement.targetProgress,
          },
          { merge: true }
        );

        newlyUnlocked.push({
          id: achievementId,
          name: achievement.name,
          xpReward: rewards.xp,
          coinReward: rewards.coins,
        });

        totalXpReward += rewards.xp;
        totalCoinReward += rewards.coins;

        console.log(`Achievement unlocked for ${uid}: ${achievementId}`);
      } else {
        // Update progress for unmet achievements
        const currentProgress = getProgressForAchievement(achievementId, userStats);
        const achievementRef = db
          .collection("users")
          .doc(uid)
          .collection("achievements")
          .doc(achievementId);

        // Only update if achievement document exists
        if (existingAchievements.has(achievementId)) {
          batch.update(achievementRef, {
            currentProgress,
          });
        } else {
          // Create new progress tracking document
          batch.set(achievementRef, {
            achievementId,
            name: achievement.name,
            description: achievement.description,
            unlocked: false,
            currentProgress,
            targetProgress: achievement.targetProgress,
          });
        }
      }
    }

    // Award XP and coins for newly unlocked achievements
    if (totalXpReward > 0 || totalCoinReward > 0) {
      const userRef = db.collection("users").doc(uid);
      batch.update(userRef, {
        xp: FieldValue.increment(totalXpReward),
        coins: FieldValue.increment(totalCoinReward),
      });
    }

    await batch.commit();

    return jsonResponse({
      success: true,
      newlyUnlocked,
      totalXpReward,
      totalCoinReward,
      achievementsChecked: Object.keys(ACHIEVEMENTS).length,
    });
  } catch (error) {
    console.error("Error in check-achievements:", error);
    return errorResponse(error.message || "Internal server error", 500);
  }
});

function getProgressForAchievement(achievementId: string, userStats: UserData): number {
  switch (achievementId) {
    case "first_game":
    case "games_10":
    case "games_50":
      return userStats.gamesPlayed;
    case "lessons_5":
    case "lessons_10":
      return userStats.lessonsCompleted;
    case "streak_3":
    case "streak_7":
    case "streak_14":
    case "streak_30":
      return userStats.streakDays;
    case "level_5":
    case "level_10":
    case "level_25":
      return userStats.level;
    case "coins_1000":
      return userStats.totalCoinsEarned;
    default:
      return 0;
  }
}
