import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'auth_provider.dart';

/// Daily challenge model
class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String iconPath;
  final ChallengeType type;
  final int targetValue;
  final int currentProgress;
  final int coinsReward;
  final int xpReward;
  final DateTime createdDate;
  final bool completed;
  final DateTime? completedAt;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.type,
    required this.targetValue,
    this.currentProgress = 0,
    required this.coinsReward,
    required this.xpReward,
    required this.createdDate,
    this.completed = false,
    this.completedAt,
  });

  double get progressPercentage => (currentProgress / targetValue).clamp(0.0, 1.0);

  factory DailyChallenge.fromFirestore(String id, Map<String, dynamic> data) {
    return DailyChallenge(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      iconPath: data['iconPath'] ?? 'assets/icons/challenge_default.png',
      type: ChallengeType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ChallengeType.other,
      ),
      targetValue: data['targetValue'] ?? 1,
      currentProgress: data['currentProgress'] ?? 0,
      coinsReward: data['coinsReward'] ?? 30,
      xpReward: data['xpReward'] ?? 50,
      createdDate: (data['createdDate'] as Timestamp).toDate(),
      completed: data['completed'] ?? false,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'iconPath': iconPath,
      'type': type.name,
      'targetValue': targetValue,
      'currentProgress': currentProgress,
      'coinsReward': coinsReward,
      'xpReward': xpReward,
      'createdDate': Timestamp.fromDate(createdDate),
      'completed': completed,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}

enum ChallengeType {
  playGames,
  earnCoins,
  completeLesson,
  earnXp,
  perfectScore,
  other,
}

/// Challenge templates for random generation
final challengeTemplates = [
  {
    'type': ChallengeType.playGames,
    'title': 'Game Marathon',
    'description': 'Play 3 games today',
    'iconPath': 'assets/icons/challenge_games.png',
    'targetValue': 3,
    'coinsReward': 50,
    'xpReward': 75,
  },
  {
    'type': ChallengeType.earnCoins,
    'title': 'Coin Hunter',
    'description': 'Earn 100 coins today',
    'iconPath': 'assets/icons/challenge_coins.png',
    'targetValue': 100,
    'coinsReward': 60,
    'xpReward': 80,
  },
  {
    'type': ChallengeType.completeLesson,
    'title': 'Knowledge Quest',
    'description': 'Complete 2 lessons today',
    'iconPath': 'assets/icons/challenge_lessons.png',
    'targetValue': 2,
    'coinsReward': 70,
    'xpReward': 100,
  },
  {
    'type': ChallengeType.earnXp,
    'title': 'XP Boost',
    'description': 'Earn 200 XP today',
    'iconPath': 'assets/icons/challenge_xp.png',
    'targetValue': 200,
    'coinsReward': 80,
    'xpReward': 120,
  },
  {
    'type': ChallengeType.perfectScore,
    'title': 'Perfectionist',
    'description': 'Get a perfect score in any game',
    'iconPath': 'assets/icons/challenge_perfect.png',
    'targetValue': 1,
    'coinsReward': 100,
    'xpReward': 150,
  },
];

/// Provider for today's challenges
final dailyChallengesProvider = StreamProvider<List<DailyChallenge>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value([]);
  }

  final firestore = FirebaseFirestore.instance;
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);

  return firestore
      .collection('users')
      .doc(userId)
      .collection('dailyChallenges')
      .where('createdDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => DailyChallenge.fromFirestore(doc.id, doc.data()))
        .toList()
      ..sort((a, b) => a.completed ? 1 : -1); // Incomplete first
  });
});

/// Generate daily challenges for a user
Future<void> generateDailyChallenges(String userId) async {
  final firestore = FirebaseFirestore.instance;
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);

  // Check if challenges already exist for today
  final existingChallenges = await firestore
      .collection('users')
      .doc(userId)
      .collection('dailyChallenges')
      .where('createdDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .get();

  if (existingChallenges.docs.isNotEmpty) {
    print('Daily challenges already exist for today');
    return;
  }

  // Generate 3 random challenges
  final random = Random();
  final selectedTemplates = <Map<String, dynamic>>[];
  final usedIndices = <int>{};

  while (selectedTemplates.length < 3 && usedIndices.length < challengeTemplates.length) {
    final index = random.nextInt(challengeTemplates.length);
    if (!usedIndices.contains(index)) {
      selectedTemplates.add(Map<String, dynamic>.from(challengeTemplates[index]));
      usedIndices.add(index);
    }
  }

  // Create challenges in Firestore
  final batch = firestore.batch();

  for (var template in selectedTemplates) {
    final docRef = firestore
        .collection('users')
        .doc(userId)
        .collection('dailyChallenges')
        .doc();

    batch.set(docRef, {
      'title': template['title'],
      'description': template['description'],
      'iconPath': template['iconPath'],
      'type': (template['type'] as ChallengeType).name,
      'targetValue': template['targetValue'],
      'currentProgress': 0,
      'coinsReward': template['coinsReward'],
      'xpReward': template['xpReward'],
      'createdDate': FieldValue.serverTimestamp(),
      'completed': false,
    });
  }

  await batch.commit();
  print('Generated ${selectedTemplates.length} daily challenges for user $userId');
}

/// Update challenge progress
final updateChallengeProgressProvider = Provider((ref) {
  return ({
    required String challengeId,
    required int progressIncrement,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) throw Exception('User not authenticated');

    final firestore = FirebaseFirestore.instance;
    final challengeRef = firestore
        .collection('users')
        .doc(userId)
        .collection('dailyChallenges')
        .doc(challengeId);

    final challengeDoc = await challengeRef.get();
    if (!challengeDoc.exists) return;

    final challenge = DailyChallenge.fromFirestore(challengeId, challengeDoc.data()!);
    if (challenge.completed) return;

    final newProgress = challenge.currentProgress + progressIncrement;
    final isNowComplete = newProgress >= challenge.targetValue;

    final batch = firestore.batch();

    // Update challenge progress
    batch.update(challengeRef, {
      'currentProgress': newProgress,
      'completed': isNowComplete,
      if (isNowComplete) 'completedAt': FieldValue.serverTimestamp(),
    });

    // Award rewards if completed
    if (isNowComplete) {
      final userRef = firestore.collection('users').doc(userId);
      batch.update(userRef, {
        'xp': FieldValue.increment(challenge.xpReward),
        'coins': FieldValue.increment(challenge.coinsReward),
      });
    }

    await batch.commit();

    if (isNowComplete) {
      print('Challenge completed: $challengeId - +${challenge.xpReward} XP, +${challenge.coinsReward} coins');
    }
  };
});

/// Provider to check if user needs new challenges
final checkAndGenerateChallengesProvider = Provider((ref) {
  return (String userId) async {
    await generateDailyChallenges(userId);
  };
});
