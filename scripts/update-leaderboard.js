import { db, rtdb } from './firebase-init.js';

async function updateLeaderboard() {
  console.log('Updating live leaderboard snapshot...');

  // Get top 100 users by XP from Firestore
  const usersSnapshot = await db
    .collection('users')
    .orderBy('xp', 'desc')
    .limit(100)
    .get();

  console.log(`Found ${usersSnapshot.size} top users by XP`);

  const leaderboardData = {};
  let rank = 1;

  for (const userDoc of usersSnapshot.docs) {
    const data = userDoc.data();
    const xp = data.xp || 0;

    // Only include users with some activity
    if (xp === 0) continue;

    leaderboardData[userDoc.id] = {
      uid: userDoc.id,
      name: data.displayName || 'Anonymous',
      score: xp,
      level: data.level || 1,
      avatarUrl: data.avatarUrl || null,
      rank: rank++,
      updatedAt: Date.now(),
    };
  }

  // Write to Realtime Database
  await rtdb.ref('leaderboards/live').set(leaderboardData);

  console.log(`Leaderboard updated with ${Object.keys(leaderboardData).length} users`);
}

updateLeaderboard()
  .then(() => {
    console.log('Leaderboard update complete');
    process.exit(0);
  })
  .catch((error) => {
    console.error('Error updating leaderboard:', error);
    process.exit(1);
  });
