import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

/// Achievement model
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconPath;
  final int coinsReward;
  final int xpReward;
  final bool unlocked;
  final DateTime? unlockedAt;
  final AchievementType type;
  final int targetValue; // e.g., 10 games, 7 day streak
  final int currentProgress; // Current progress towards target

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.coinsReward,
    required this.xpReward,
    required this.unlocked,
    this.unlockedAt,
    required this.type,
    required this.targetValue,
    this.currentProgress = 0,
  });

  double get progressPercentage {
    if (targetValue <= 0) return 0.0;
    return (currentProgress / targetValue).clamp(0.0, 1.0);
  }

  /// Get icon for achievement type
  IconData get icon {
    switch (type) {
      case AchievementType.firstSteps:
        return Icons.school;
      case AchievementType.streak:
        return Icons.local_fire_department;
      case AchievementType.games:
        return Icons.videogame_asset;
      case AchievementType.learning:
        return Icons.menu_book;
      case AchievementType.coins:
        return Icons.monetization_on;
      case AchievementType.social:
        return Icons.people;
      case AchievementType.other:
        return Icons.emoji_events;
    }
  }

  /// Get color for achievement type
  Color get color {
    switch (type) {
      case AchievementType.firstSteps:
        return const Color(0xFF4A90E2);
      case AchievementType.streak:
        return const Color(0xFFFF6B35);
      case AchievementType.games:
        return const Color(0xFF9B59B6);
      case AchievementType.learning:
        return const Color(0xFF5F8724);
      case AchievementType.coins:
        return const Color(0xFFFFD93D);
      case AchievementType.social:
        return const Color(0xFFFF6B9D);
      case AchievementType.other:
        return const Color(0xFF4A90E2);
    }
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  factory Achievement.fromFirestore(String id, Map<String, dynamic> data) {
    return Achievement(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      iconPath: data['iconPath'] ?? 'assets/icons/achievement_default.png',
      coinsReward: _toInt(data['coinsReward'], fallback: 50),
      xpReward: _toInt(data['xpReward'], fallback: 100),
      unlocked: data['unlocked'] ?? false,
      unlockedAt: _toDateTime(data['unlockedAt']),
      type: AchievementType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => AchievementType.other,
      ),
      targetValue: _toInt(data['targetValue'], fallback: 1),
      currentProgress: _toInt(data['currentProgress'], fallback: 0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'iconPath': iconPath,
      'coinsReward': coinsReward,
      'xpReward': xpReward,
      'unlocked': unlocked,
      'unlockedAt': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
      'type': type.name,
      'targetValue': targetValue,
      'currentProgress': currentProgress,
    };
  }
}

/// Achievement types
enum AchievementType {
  firstSteps, // Complete first lesson/game
  streak, // Daily streak milestones
  games, // Game completion milestones
  learning, // Learning milestones
  coins, // Coin collection milestones
  social, // Friend-related
  other,
}

/// Default achievements template
final defaultAchievements = [
  {
    'id': 'first_game',
    'title': 'First Steps',
    'description': 'Complete your first game',
    'iconPath': 'assets/icons/first_steps.png',
    'coinsReward': 50,
    'xpReward': 100,
    'type': 'firstSteps',
    'targetValue': 1,
  },
  {
    'id': 'streak_3',
    'title': '3-Day Streak',
    'description': 'Log in for 3 consecutive days',
    'iconPath': 'assets/icons/streak_3.png',
    'coinsReward': 75,
    'xpReward': 150,
    'type': 'streak',
    'targetValue': 3,
  },
  {
    'id': 'streak_7',
    'title': 'Week Warrior',
    'description': 'Maintain a 7-day streak',
    'iconPath': 'assets/icons/streak_7.png',
    'coinsReward': 150,
    'xpReward': 300,
    'type': 'streak',
    'targetValue': 7,
  },
  {
    'id': 'games_10',
    'title': 'Game Master',
    'description': 'Complete 10 games',
    'iconPath': 'assets/icons/games_10.png',
    'coinsReward': 200,
    'xpReward': 500,
    'type': 'games',
    'targetValue': 10,
  },
  {
    'id': 'lessons_5',
    'title': 'Knowledge Seeker',
    'description': 'Complete 5 lessons',
    'iconPath': 'assets/icons/lessons_5.png',
    'coinsReward': 150,
    'xpReward': 400,
    'type': 'learning',
    'targetValue': 5,
  },
  {
    'id': 'coins_1000',
    'title': 'Coin Collector',
    'description': 'Earn 1000 coins',
    'iconPath': 'assets/icons/coins_1000.png',
    'coinsReward': 250,
    'xpReward': 600,
    'type': 'coins',
    'targetValue': 1000,
  },
];

/// Provider for user's achievements
final achievementsProvider = StreamProvider<List<Achievement>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value([]);
  }

  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('users')
      .doc(userId)
      .collection('achievements')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => Achievement.fromFirestore(doc.id, doc.data()))
        .toList()
      ..sort((a, b) {
        // Sort: unlocked first, then by XP reward
        if (a.unlocked && !b.unlocked) return -1;
        if (!a.unlocked && b.unlocked) return 1;
        return b.xpReward.compareTo(a.xpReward);
      });
  });
});

/// Provider for unlocking achievements
final unlockAchievementProvider = Provider((ref) {
  return (String achievementId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) throw Exception('User not authenticated');

    final firestore = FirebaseFirestore.instance;
    final achievementRef = firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .doc(achievementId);

    final achievementDoc = await achievementRef.get();
    if (!achievementDoc.exists) {
      throw Exception('Achievement not found');
    }

    final achievement = Achievement.fromFirestore(achievementId, achievementDoc.data()!);

    if (achievement.unlocked) {
      return; // Already unlocked
    }

    final batch = firestore.batch();

    // Unlock achievement
    batch.update(achievementRef, {
      'unlocked': true,
      'unlockedAt': FieldValue.serverTimestamp(),
    });

    // Award rewards
    final userRef = firestore.collection('users').doc(userId);
    batch.update(userRef, {
      'xp': FieldValue.increment(achievement.xpReward),
      'coins': FieldValue.increment(achievement.coinsReward),
    });

    await batch.commit();
    debugPrint('Achievement unlocked: $achievementId - +${achievement.xpReward} XP, +${achievement.coinsReward} coins');
  };
});

/// Provider to check and unlock achievements automatically
final checkAchievementsProvider = Provider((ref) {
  return () async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final firestore = FirebaseFirestore.instance;

    // Get user stats
    final userDoc = await firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return;

    final userData = userDoc.data()!;
    final streakDays = userData['streakDays'] ?? 0;
    final coins = userData['coins'] ?? 0;

    // Get achievements
    final achievementsSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .get();

    final unlockService = ref.read(unlockAchievementProvider);

    // Check each achievement
    for (var doc in achievementsSnapshot.docs) {
      final achievement = Achievement.fromFirestore(doc.id, doc.data());

      if (achievement.unlocked) continue;

      bool shouldUnlock = false;

      switch (achievement.type) {
        case AchievementType.streak:
          shouldUnlock = streakDays >= achievement.targetValue;
          break;
        case AchievementType.coins:
          shouldUnlock = coins >= achievement.targetValue;
          break;
        default:
          // Other types checked via currentProgress
          shouldUnlock = achievement.currentProgress >= achievement.targetValue;
      }

      if (shouldUnlock) {
        await unlockService(doc.id);
      }
    }
  };
});

/// Initialize achievements for new users
Future<void> initializeAchievementsForUser(String userId) async {
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();

  for (var achievementData in defaultAchievements) {
    final docRef = firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .doc(achievementData['id'] as String);

    batch.set(docRef, {
      ...achievementData,
      'unlocked': false,
      'currentProgress': 0,
    }..remove('id')); // Remove id from data, it's the doc ID
  }

  await batch.commit();
  debugPrint('Initialized ${defaultAchievements.length} achievements for user $userId');
}
