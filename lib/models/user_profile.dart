import 'package:flutter/material.dart';

/// User Profile Model
class UserProfile {
  final String id;
  final String username;
  final String avatarUrl;
  final int level;
  final int currentXp;
  final int xpForNextLevel;
  final int totalXp;
  final int coins;
  final int rank;
  final List<String> achievements;
  final Map<String, int> moduleProgress; // moduleId -> completed lessons
  final int gamesPlayed;
  final int quizzesCompleted;
  final int streakDays;
  final DateTime joinDate;

  UserProfile({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.level,
    required this.currentXp,
    required this.xpForNextLevel,
    required this.totalXp,
    required this.coins,
    required this.rank,
    required this.achievements,
    required this.moduleProgress,
    required this.gamesPlayed,
    required this.quizzesCompleted,
    required this.streakDays,
    required this.joinDate,
  });

  double get levelProgress => currentXp / xpForNextLevel;

  int get completedModules => moduleProgress.values.where((lessons) => lessons > 0).length;
}

/// Leaderboard Entry Model
class LeaderboardEntry {
  final String userId;
  final String username;
  final String avatarUrl;
  final int rank;
  final int totalXp;
  final int level;
  final List<String> badges;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.rank,
    required this.totalXp,
    required this.level,
    required this.badges,
  });
}

/// Achievement/Badge Model
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final DateTime? unlockedDate;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
    this.unlockedDate,
  });
}
