/**
 * Shared utilities for FINSTAR Supabase Edge Functions
 */

// ============================================
// CONSTANTS
// ============================================

export const GAME_IDS = {
  LIFE_SWIPE: "life_swipe",
  MARKET_EXPLORER: "market_explorer",
  QUIZ_BATTLE: "quiz_battle",
  BUDGET_BLITZ: "budget_blitz",
} as const;

export const BASE_XP = 1000; // XP required for level 2
export const XP_MULTIPLIER = 1.5;

export const STREAK_BONUSES: Record<number, { xp: number; coins: number }> = {
  3: { xp: 50, coins: 20 },
  7: { xp: 100, coins: 50 },
  14: { xp: 200, coins: 100 },
  30: { xp: 500, coins: 200 },
};

export const ACHIEVEMENT_REWARDS: Record<string, { xp: number; coins: number }> = {
  first_game: { xp: 100, coins: 50 },
  games_10: { xp: 500, coins: 200 },
  games_50: { xp: 1000, coins: 500 },
  coins_1000: { xp: 600, coins: 250 },
  lessons_5: { xp: 400, coins: 150 },
  lessons_10: { xp: 800, coins: 300 },
  streak_3: { xp: 150, coins: 75 },
  streak_7: { xp: 300, coins: 150 },
  streak_14: { xp: 500, coins: 250 },
  streak_30: { xp: 1000, coins: 500 },
  level_5: { xp: 250, coins: 100 },
  level_10: { xp: 500, coins: 200 },
  level_25: { xp: 1000, coins: 500 },
  perfect_quiz: { xp: 200, coins: 100 },
  market_master: { xp: 500, coins: 250 },
};

export const DAILY_CHALLENGE_TYPES = [
  "playGames",
  "earnXp",
  "earnCoins",
  "completeLesson",
  "perfectScore",
  "winQuiz",
] as const;

// ============================================
// HELPER FUNCTIONS
// ============================================

/**
 * Calculate user level from total XP using exponential scaling
 */
export function calculateLevel(totalXp: number): {
  level: number;
  currentXp: number;
  xpForNextLevel: number;
} {
  let level = 1;
  let xpRequired = BASE_XP;
  let accumulated = 0;

  while (totalXp >= accumulated + xpRequired) {
    accumulated += xpRequired;
    level++;
    xpRequired = Math.floor(xpRequired * XP_MULTIPLIER);
  }

  return {
    level,
    currentXp: totalXp - accumulated,
    xpForNextLevel: xpRequired,
  };
}

/**
 * Calculate XP required to reach a specific level
 */
export function xpRequiredForLevel(targetLevel: number): number {
  let total = 0;
  let current = BASE_XP;

  for (let i = 1; i < targetLevel; i++) {
    total += current;
    current = Math.floor(current * XP_MULTIPLIER);
  }

  return total;
}

/**
 * Get today's date in YYYY-MM-DD format (IST timezone)
 */
export function getTodayIST(): string {
  const now = new Date();
  // Convert to IST (UTC+5:30)
  const istOffset = 5.5 * 60 * 60 * 1000;
  const istDate = new Date(now.getTime() + istOffset);
  return istDate.toISOString().split("T")[0];
}

/**
 * Get yesterday's date in YYYY-MM-DD format (IST timezone)
 */
export function getYesterdayIST(): string {
  const now = new Date();
  const istOffset = 5.5 * 60 * 60 * 1000;
  const istDate = new Date(now.getTime() + istOffset - 86400000);
  return istDate.toISOString().split("T")[0];
}

/**
 * Get current month season ID (YYYY-MM)
 */
export function getCurrentSeasonId(): string {
  return getTodayIST().slice(0, 7);
}

/**
 * Calculate Life Swipe rewards based on allocations and score
 */
export function calculateLifeSwipeRewards(
  allocations: Record<string, number>,
  score: number
): { xp: number; coins: number; savingsRate: number } {
  const savingsRate = ((allocations.savings || 0) + (allocations.invest || 0)) / 100;
  const emergencyFundMet = (allocations.savings || 0) >= 1000;

  let xp = 20; // Base XP
  xp += Math.min(Math.floor(savingsRate / 5) * 2, 12); // Savings bonus (max 12)
  xp += emergencyFundMet ? 8 : 0; // Emergency fund bonus
  xp += Math.floor(score / 100) * 2; // Score bonus (2 XP per 100 score)
  xp = Math.max(0, Math.min(xp, 50)); // Cap at 50

  const coins = Math.floor(xp * 1.2);

  return { xp, coins, savingsRate };
}

/**
 * Calculate Budget Blitz rewards based on score and level
 */
export function calculateBudgetBlitzRewards(
  score: number,
  level: number,
  accuracy: number
): { xp: number; coins: number } {
  let xp = Math.floor(score / 10); // Base: 1 XP per 10 score
  xp += level * 5; // Level bonus
  xp += Math.floor(accuracy * 20); // Accuracy bonus (max 20)
  xp = Math.min(xp, 100); // Cap at 100

  const coins = Math.floor(xp * 0.8);

  return { xp, coins };
}

/**
 * Calculate Quiz Battle rewards based on score and time
 */
export function calculateQuizBattleRewards(
  correctAnswers: number,
  totalQuestions: number,
  timeBonus: number,
  isWinner: boolean
): { xp: number; coins: number } {
  const accuracy = correctAnswers / totalQuestions;

  let xp = correctAnswers * 10; // 10 XP per correct answer
  xp += Math.floor(timeBonus); // Time bonus
  xp += accuracy >= 1.0 ? 50 : 0; // Perfect score bonus
  xp += isWinner ? 25 : 0; // Winner bonus
  xp = Math.min(xp, 150); // Cap at 150

  const coins = Math.floor(xp * 0.6);

  return { xp, coins };
}

/**
 * Calculate Market Explorer rewards based on portfolio performance
 */
export function calculateMarketExplorerRewards(
  portfolioReturn: number,
  diversificationScore: number,
  decisionsCount: number
): { xp: number; coins: number } {
  let xp = 20; // Base XP

  // Return bonus (can be negative for losses)
  if (portfolioReturn > 0) {
    xp += Math.min(Math.floor(portfolioReturn * 50), 30); // Max 30 for 60%+ return
  }

  // Diversification bonus
  xp += Math.floor(diversificationScore * 15); // Max 15

  // Activity bonus
  xp += Math.min(decisionsCount * 2, 10); // Max 10

  xp = Math.max(10, Math.min(xp, 75)); // Min 10, Max 75

  const coins = Math.floor(xp * 1.0);

  return { xp, coins };
}

/**
 * Generate random daily challenges
 */
export function generateDailyChallenges(): Array<{
  id: string;
  type: string;
  target: number;
  xpReward: number;
  coinReward: number;
  description: string;
}> {
  const challenges = [
    {
      type: "playGames",
      targets: [2, 3, 5],
      descriptions: ["Play 2 games", "Play 3 games", "Play 5 games"],
    },
    {
      type: "earnXp",
      targets: [50, 100, 200],
      descriptions: ["Earn 50 XP", "Earn 100 XP", "Earn 200 XP"],
    },
    {
      type: "earnCoins",
      targets: [30, 50, 100],
      descriptions: ["Earn 30 coins", "Earn 50 coins", "Earn 100 coins"],
    },
    {
      type: "completeLesson",
      targets: [1, 2],
      descriptions: ["Complete 1 lesson", "Complete 2 lessons"],
    },
    {
      type: "perfectScore",
      targets: [1],
      descriptions: ["Get a perfect quiz score"],
    },
  ];

  // Shuffle and pick 3 challenges
  const shuffled = challenges.sort(() => Math.random() - 0.5);
  const selected = shuffled.slice(0, 3);

  return selected.map((challenge, index) => {
    const targetIndex = Math.floor(Math.random() * challenge.targets.length);
    const target = challenge.targets[targetIndex];
    const baseReward = target * 10;

    return {
      id: `daily_${getTodayIST()}_${index}`,
      type: challenge.type,
      target,
      xpReward: baseReward + Math.floor(Math.random() * 20),
      coinReward: Math.floor(baseReward * 0.5) + Math.floor(Math.random() * 10),
      description: challenge.descriptions[targetIndex],
    };
  });
}

/**
 * Validate score is within acceptable bounds
 */
export function validateScore(score: number, minScore: number, maxScore: number): boolean {
  return score >= minScore && score <= maxScore && Number.isInteger(score);
}

/**
 * Update daily challenge progress
 * Called after game completion, lesson completion, etc.
 */
export async function updateChallengeProgress(
  db: FirebaseFirestore.Firestore,
  userId: string,
  updates: {
    gamesPlayed?: number;
    xpEarned?: number;
    coinsEarned?: number;
    lessonsCompleted?: number;
    perfectScore?: boolean;
    quizWon?: boolean;
  }
): Promise<void> {
  const today = getTodayIST();
  const challengesRef = db
    .collection("users")
    .doc(userId)
    .collection("dailyChallenges")
    .doc(today);

  const challengesDoc = await challengesRef.get();

  if (!challengesDoc.exists) {
    console.log("No daily challenges found for today");
    return;
  }

  const data = challengesDoc.data()!;
  const challenges = data.challenges as Array<{
    id: string;
    type: string;
    target: number;
    progress: number;
    completed: boolean;
    claimed: boolean;
    xpReward: number;
    coinReward: number;
  }>;

  let updated = false;
  let totalXpReward = 0;
  let totalCoinReward = 0;

  for (const challenge of challenges) {
    if (challenge.completed) continue;

    let progressIncrement = 0;

    switch (challenge.type) {
      case "playGames":
        progressIncrement = updates.gamesPlayed || 0;
        break;
      case "earnXp":
        progressIncrement = updates.xpEarned || 0;
        break;
      case "earnCoins":
        progressIncrement = updates.coinsEarned || 0;
        break;
      case "completeLesson":
        progressIncrement = updates.lessonsCompleted || 0;
        break;
      case "perfectScore":
        progressIncrement = updates.perfectScore ? 1 : 0;
        break;
      case "winQuiz":
        progressIncrement = updates.quizWon ? 1 : 0;
        break;
    }

    if (progressIncrement > 0) {
      challenge.progress += progressIncrement;
      updated = true;

      // Check if challenge is now complete
      if (challenge.progress >= challenge.target && !challenge.completed) {
        challenge.completed = true;
        totalXpReward += challenge.xpReward;
        totalCoinReward += challenge.coinReward;
        console.log(`Challenge ${challenge.id} completed!`);
      }
    }
  }

  if (updated) {
    // Update challenges in Firestore
    await challengesRef.update({ challenges });

    // Award rewards for completed challenges
    if (totalXpReward > 0 || totalCoinReward > 0) {
      const userRef = db.collection("users").doc(userId);
      const updates: Record<string, FirebaseFirestore.FieldValue> = {};

      if (totalXpReward > 0) {
        updates["xp"] = FirebaseFirestore.FieldValue.increment(totalXpReward);
      }
      if (totalCoinReward > 0) {
        updates["coins"] = FirebaseFirestore.FieldValue.increment(totalCoinReward);
      }

      await userRef.update(updates);
      console.log(`Challenge rewards: +${totalXpReward} XP, +${totalCoinReward} coins`);
    }
  }
}
