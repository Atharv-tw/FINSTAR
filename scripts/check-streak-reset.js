import { db } from './firebase-init.js';

async function checkStreakReset() {
  console.log('Checking for streak resets...');

  const now = new Date();
  const today = now.toISOString().split('T')[0];

  // Calculate yesterday's date
  const yesterday = new Date(now);
  yesterday.setDate(yesterday.getDate() - 1);
  const yesterdayStr = yesterday.toISOString().split('T')[0];

  // Get all users with active streaks
  const usersSnapshot = await db.collection('users').get();
  console.log(`Checking ${usersSnapshot.size} users for streak resets`);

  let resetCount = 0;
  let activeCount = 0;
  let batchCount = 0;
  let batch = db.batch();

  for (const userDoc of usersSnapshot.docs) {
    const data = userDoc.data();
    const lastActiveDate = data.lastActiveDate;
    const currentStreak = data.streakDays || 0;

    // Skip users with no streak or no last active date
    if (!lastActiveDate || currentStreak === 0) {
      continue;
    }

    // If they were active today or yesterday, their streak is fine
    if (lastActiveDate === today || lastActiveDate === yesterdayStr) {
      activeCount++;
      continue;
    }

    // More than 1 day has passed - reset streak
    batch.update(userDoc.ref, { streakDays: 0 });
    resetCount++;
    batchCount++;

    // Firestore batches have a limit of 500 operations
    if (batchCount >= 450) {
      await batch.commit();
      batch = db.batch();
      batchCount = 0;
    }
  }

  // Commit any remaining updates
  if (batchCount > 0) {
    await batch.commit();
  }

  console.log(`Streak check complete:`);
  console.log(`  - Active streaks preserved: ${activeCount}`);
  console.log(`  - Streaks reset to 0: ${resetCount}`);
}

checkStreakReset()
  .then(() => {
    console.log('Streak reset check complete');
    process.exit(0);
  })
  .catch((error) => {
    console.error('Error checking streak resets:', error);
    process.exit(1);
  });
