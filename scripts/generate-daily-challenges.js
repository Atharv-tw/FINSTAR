import { db } from './firebase-init.js';

const CHALLENGE_TYPES = [
  {
    type: 'playGames',
    target: 3,
    reward: { coins: 50, xp: 75 },
    title: 'Play 3 games',
    description: 'Play any 3 games today',
  },
  {
    type: 'earnCoins',
    target: 100,
    reward: { coins: 60, xp: 80 },
    title: 'Earn 100 coins',
    description: 'Earn 100 coins from playing games',
  },
  {
    type: 'completeLesson',
    target: 2,
    reward: { coins: 70, xp: 100 },
    title: 'Complete 2 lessons',
    description: 'Complete any 2 learning lessons',
  },
  {
    type: 'earnXp',
    target: 200,
    reward: { coins: 80, xp: 120 },
    title: 'Earn 200 XP',
    description: 'Earn 200 XP from any activities',
  },
  {
    type: 'perfectScore',
    target: 1,
    reward: { coins: 100, xp: 150 },
    title: 'Get a perfect score',
    description: 'Get 100% on any quiz or game',
  },
];

function shuffleArray(array) {
  const shuffled = [...array];
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
  }
  return shuffled;
}

async function generateDailyChallenges() {
  const today = new Date().toISOString().split('T')[0];
  console.log(`Generating daily challenges for ${today}...`);

  // Get all users
  const usersSnapshot = await db.collection('users').get();
  console.log(`Found ${usersSnapshot.size} users`);

  let generated = 0;
  let skipped = 0;

  for (const userDoc of usersSnapshot.docs) {
    const userId = userDoc.id;

    // Check if challenges already exist for today
    const existing = await db
      .collection('users')
      .doc(userId)
      .collection('dailyChallenges')
      .where('createdDate', '==', today)
      .limit(1)
      .get();

    if (!existing.empty) {
      skipped++;
      continue;
    }

    // Pick 3 random challenges
    const shuffled = shuffleArray(CHALLENGE_TYPES);
    const selected = shuffled.slice(0, 3);

    // Create challenges in a batch
    const batch = db.batch();

    for (const challenge of selected) {
      const ref = db.collection('users').doc(userId).collection('dailyChallenges').doc();
      batch.set(ref, {
        type: challenge.type,
        title: challenge.title,
        description: challenge.description,
        target: challenge.target,
        reward: challenge.reward,
        progress: 0,
        completed: false,
        claimed: false,
        createdDate: today,
        createdAt: new Date().toISOString(),
      });
    }

    await batch.commit();
    generated++;
  }

  console.log(`Generated challenges for ${generated} users, skipped ${skipped} (already had challenges)`);
}

generateDailyChallenges()
  .then(() => {
    console.log('Daily challenges generation complete');
    process.exit(0);
  })
  .catch((error) => {
    console.error('Error generating daily challenges:', error);
    process.exit(1);
  });
