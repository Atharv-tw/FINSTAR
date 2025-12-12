/**
 * FINSTAR Cloud Functions
 *
 * Production-ready serverless backend for Finstar app
 * Region: asia-south1 (Mumbai) for low latency
 */

const {onCall, HttpsError} = require('firebase-functions/v2/https');
const {onDocumentCreated} = require('firebase-functions/v2/firestore');
const {onSchedule} = require('firebase-functions/v2/scheduler');
const {setGlobalOptions} = require('firebase-functions/v2');
const admin = require('firebase-admin');

// ============================================
// GLOBAL CONFIGURATION
// ============================================

// CRITICAL: Set region to asia-south1 for LOW LATENCY in India
setGlobalOptions({
  region: 'asia-south1',
  memory: '512MiB',
  timeoutSeconds: 60,
  maxInstances: 100,
  minInstances: 0, // Change to 1-2 for production to reduce cold starts
});

// Initialize Firebase Admin
admin.initializeApp();

const db = admin.firestore();
const rtdb = admin.database();

// ============================================
// CONSTANTS
// ============================================

const GAME_IDS = {
  LIFE_SWIPE: 'life_swipe',
  MARKET_EXPLORER: 'market_explorer',
  QUIZ_BATTLE: 'quiz_battle',
  BUDGET_BLITZ: 'budget_blitz',
};

const BASE_XP = 1000; // XP required for level 2
const XP_MULTIPLIER = 1.5;

const STREAK_BONUSES = {
  3: {xp: 50, coins: 20},
  7: {xp: 100, coins: 50},
  14: {xp: 200, coins: 100},
  30: {xp: 500, coins: 200},
};

// ============================================
// HELPER FUNCTIONS
// ============================================

/**
 * Calculate user level from total XP
 */
function calculateLevel(totalXp) {
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
function xpRequiredForLevel(targetLevel) {
  let total = 0;
  let current = BASE_XP;

  for (let i = 1; i < targetLevel; i++) {
    total += current;
    current = Math.floor(current * XP_MULTIPLIER);
  }

  return total;
}

/**
 * Update user XP, coins, and level (transactional)
 */
async function updateUserProgress(userId, xpDelta, coinsDelta, transaction = null) {
  const userRef = db.collection('users').doc(userId);

  const executeUpdate = async (t) => {
    const userDoc = await t.get(userRef);

    if (!userDoc.exists) {
      throw new HttpsError('not-found', 'User not found');
    }

    const userData = userDoc.data();
    const newTotalXp = userData.xp + xpDelta;
    const levelData = calculateLevel(newTotalXp);
    const leveledUp = levelData.level > userData.level;

    t.update(userRef, {
      xp: newTotalXp,
      level: levelData.level,
      coins: admin.firestore.FieldValue.increment(coinsDelta),
      lastActiveDate: new Date().toISOString().split('T')[0],
    });

    return {
      xpEarned: xpDelta,
      coinsEarned: coinsDelta,
      newLevel: levelData.level,
      newXp: newTotalXp,
      leveledUp,
      xpForNextLevel: levelData.xpForNextLevel,
    };
  };

  if (transaction) {
    return await executeUpdate(transaction);
  } else {
    return await db.runTransaction(executeUpdate);
  }
}

// ============================================
// TRIGGER: User Created (Starter Pack)
// ============================================

exports.onUserCreate = onDocumentCreated('users/{uid}', async (event) => {
  const uid = event.params.uid;
  const snapshot = event.data;

  if (!snapshot) {
    console.log('No data associated with the event');
    return;
  }

  console.log(`New user created: ${uid}`);

  // Award starter pack
  await db.collection('users').doc(uid).update({
    xp: 0,
    level: 1,
    coins: 200, // Starter coins
    streakDays: 0,
    lastActiveDate: new Date().toISOString().split('T')[0],
    rank: null,
  });

  console.log(`Starter pack awarded to ${uid}`);
});

// ============================================
// CALLABLE: Submit Life Swipe Result
// ============================================

exports.submitLifeSwipe = onCall({
  enforceAppCheck: true, // CRITICAL: Prevents API abuse
}, async (request) => {
  // Verify authentication
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'User must be logged in');
  }

  const {seed, allocations, score, eventChoices} = request.data;
  const uid = request.auth.uid;

  // Validate input
  if (!seed || !allocations || score === undefined) {
    throw new HttpsError('invalid-argument', 'Missing required fields');
  }

  // Validate allocations sum to 10000
  const total = Object.values(allocations).reduce((sum, val) => sum + val, 0);
  if (total !== 10000) {
    throw new HttpsError('invalid-argument', 'Allocations must sum to 10000');
  }

  // Server-side score calculation (anti-cheat)
  // TODO: Implement deterministic score calculation using seed
  const serverScore = score; // Placeholder - implement actual calculation

  // Calculate rewards
  const savingsRate = (allocations.savings + allocations.invest) / 100;
  const emergencyFundMet = allocations.savings >= 1000;

  let xpEarned = 20; // Base XP
  xpEarned += Math.min(Math.floor(savingsRate / 5) * 2, 12); // Savings bonus
  xpEarned += emergencyFundMet ? 8 : 0; // Emergency fund bonus
  xpEarned = Math.max(0, Math.min(xpEarned, 50)); // Cap at 50

  const coinsEarned = Math.floor(xpEarned * 1.2);

  // Update user progress in transaction
  const result = await db.runTransaction(async (t) => {
    const userRef = db.collection('users').doc(uid);
    const progressRef = userRef.collection('progress').doc(GAME_IDS.LIFE_SWIPE);

    const progressDoc = await t.get(progressRef);
    const progressResult = await updateUserProgress(uid, xpEarned, coinsEarned, t);

    // Update game progress
    if (progressDoc.exists) {
      const progressData = progressDoc.data();
      t.update(progressRef, {
        highScore: Math.max(progressData.highScore, serverScore),
        timesPlayed: admin.firestore.FieldValue.increment(1),
        totalXp: admin.firestore.FieldValue.increment(xpEarned),
        totalCoins: admin.firestore.FieldValue.increment(coinsEarned),
        lastPlayed: new Date().toISOString(),
        bestSavingsRate: Math.max(progressData.bestSavingsRate || 0, savingsRate),
      });
    } else {
      t.set(progressRef, {
        gameId: GAME_IDS.LIFE_SWIPE,
        highScore: serverScore,
        timesPlayed: 1,
        totalXp: xpEarned,
        totalCoins: coinsEarned,
        lastPlayed: new Date().toISOString(),
        bestSavingsRate: savingsRate,
      });
    }

    return progressResult;
  });

  console.log(`Life Swipe completed by ${uid}: ${xpEarned} XP, ${coinsEarned} coins`);

  return result;
});

// ============================================
// CALLABLE: Complete Lesson
// ============================================

exports.completeLesson = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'User must be logged in');
  }

  const {lessonId, quizScore} = request.data;
  const uid = request.auth.uid;

  if (!lessonId) {
    throw new HttpsError('invalid-argument', 'lessonId is required');
  }

  // Get lesson details
  const lessonDoc = await db.collection('lessons').doc(lessonId).get();

  if (!lessonDoc.exists) {
    throw new HttpsError('not-found', 'Lesson not found');
  }

  const lesson = lessonDoc.data();
  const xpReward = lesson.xpReward || 25;
  const coinReward = lesson.coinReward || 30;

  // Check if already completed
  const progressRef = db.collection('users').doc(uid).collection('lessonProgress').doc(lessonId);
  const progressDoc = await progressRef.get();

  if (progressDoc.exists && progressDoc.data().completed) {
    throw new HttpsError('already-exists', 'Lesson already completed');
  }

  // Update user progress and mark lesson complete
  const result = await updateUserProgress(uid, xpReward, coinReward);

  await progressRef.set({
    lessonId,
    completed: true,
    quizScore: quizScore || null,
    completedAt: admin.firestore.FieldValue.serverTimestamp(),
    xpEarned: xpReward,
    coinsEarned: coinReward,
  });

  console.log(`Lesson ${lessonId} completed by ${uid}: ${xpReward} XP, ${coinReward} coins`);

  return result;
});

// ============================================
// CALLABLE: Daily Check-In (Streak Tracking)
// ============================================

exports.dailyCheckIn = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'User must be logged in');
  }

  const uid = request.auth.uid;
  const today = new Date().toISOString().split('T')[0];

  return await db.runTransaction(async (t) => {
    const userRef = db.collection('users').doc(uid);
    const userDoc = await t.get(userRef);

    if (!userDoc.exists) {
      throw new HttpsError('not-found', 'User not found');
    }

    const userData = userDoc.data();
    const lastActive = userData.lastActiveDate;

    // Check if already checked in today
    if (lastActive === today) {
      throw new HttpsError('already-exists', 'Already checked in today');
    }

    // Calculate streak
    const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
    const isConsecutive = lastActive === yesterday;
    const newStreak = isConsecutive ? userData.streakDays + 1 : 1;

    // Check for milestone bonus
    let bonus = {xp: 0, coins: 0};
    if (STREAK_BONUSES[newStreak]) {
      bonus = STREAK_BONUSES[newStreak];
    }

    // Update user
    t.update(userRef, {
      streakDays: newStreak,
      lastActiveDate: today,
      xp: admin.firestore.FieldValue.increment(bonus.xp),
      coins: admin.firestore.FieldValue.increment(bonus.coins),
    });

    console.log(`Daily check-in by ${uid}: streak ${newStreak}, bonus ${bonus.xp} XP`);

    return {
      streakDays: newStreak,
      bonus,
      milestone: STREAK_BONUSES[newStreak] !== undefined,
    };
  });
});

// ============================================
// CALLABLE: Purchase Store Item
// ============================================

exports.purchaseItem = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'User must be logged in');
  }

  const {itemId} = request.data;
  const uid = request.auth.uid;

  if (!itemId) {
    throw new HttpsError('invalid-argument', 'itemId is required');
  }

  // Get item details
  const itemDoc = await db.collection('store').doc('items').collection('all').doc(itemId).get();

  if (!itemDoc.exists) {
    throw new HttpsError('not-found', 'Item not found');
  }

  const item = itemDoc.data();
  const price = item.price;

  // Transaction: Check balance, deduct coins, add to inventory
  return await db.runTransaction(async (t) => {
    const userRef = db.collection('users').doc(uid);
    const userDoc = await t.get(userRef);
    const userData = userDoc.data();

    // Check sufficient coins
    if (userData.coins < price) {
      throw new HttpsError('failed-precondition', 'Insufficient coins');
    }

    // Check if already owned
    const inventoryRef = userRef.collection('inventory').doc(itemId);
    const inventoryDoc = await t.get(inventoryRef);

    if (inventoryDoc.exists) {
      throw new HttpsError('already-exists', 'Item already owned');
    }

    // Deduct coins
    t.update(userRef, {
      coins: admin.firestore.FieldValue.increment(-price),
    });

    // Add to inventory
    t.set(inventoryRef, {
      itemId,
      itemType: item.type,
      purchasedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`Item ${itemId} purchased by ${uid} for ${price} coins`);

    return {
      success: true,
      coinsRemaining: userData.coins - price,
      itemId,
    };
  });
});

// ============================================
// SCHEDULED: Update Daily Leaderboard
// ============================================

exports.updateLeaderboard = onSchedule({
  schedule: '0 0 * * *', // Every day at midnight
  timeZone: 'Asia/Kolkata',
}, async (context) => {
  console.log('Starting leaderboard update...');

  const today = new Date().toISOString().split('T')[0];
  const seasonId = today.slice(0, 7); // "2025-01"

  try {
    // Get top 100 users by XP
    const usersSnapshot = await db.collection('users')
      .orderBy('xp', 'desc')
      .limit(100)
      .get();

    const rankings = usersSnapshot.docs.map((doc, index) => {
      const data = doc.data();
      return {
        rank: index + 1,
        uid: doc.id,
        displayName: data.displayName || 'Player',
        xp: data.xp,
        level: data.level,
        avatarUrl: data.avatarUrl || null,
      };
    });

    // Get total user count
    const totalUsersSnapshot = await db.collection('users').count().get();
    const totalUsers = totalUsersSnapshot.data().count;

    // Save snapshot to Firestore
    await db.collection('leaderboards').doc(seasonId).set({
      seasonId,
      period: 'monthly',
      rankings,
      updatedAt: new Date().toISOString(),
      totalUsers,
    });

    // Also update Realtime Database for live leaderboard
    await rtdb.ref('leaderboards/live').set({
      top100: rankings,
      updatedAt: Date.now(),
    });

    console.log(`Leaderboard updated: ${rankings.length} users, total ${totalUsers}`);
  } catch (error) {
    console.error('Error updating leaderboard:', error);
    throw error;
  }
});

// ============================================
// SCHEDULED: Reset Broken Streaks
// ============================================

exports.resetStreaks = onSchedule({
  schedule: '0 4 * * *', // Every day at 4 AM (after midnight)
  timeZone: 'Asia/Kolkata',
}, async (context) => {
  console.log('Starting streak reset check...');

  const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
  const twoDaysAgo = new Date(Date.now() - 172800000).toISOString().split('T')[0];

  try {
    // Find users who haven't checked in since 2+ days ago
    const usersSnapshot = await db.collection('users')
      .where('lastActiveDate', '<', yesterday)
      .where('streakDays', '>', 0)
      .get();

    const batch = db.batch();
    let resetCount = 0;

    usersSnapshot.docs.forEach((doc) => {
      batch.update(doc.ref, {streakDays: 0});
      resetCount++;
    });

    await batch.commit();

    console.log(`Reset ${resetCount} broken streaks`);
  } catch (error) {
    console.error('Error resetting streaks:', error);
    throw error;
  }
});

console.log('Finstar Cloud Functions loaded successfully');
