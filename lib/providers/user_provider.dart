import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

/// Model for user profile data
class UserProfile {
  final String id;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final int xp;
  final int level;
  final int coins;
  final int streakDays;
  final int lessonsCompleted;
  final String lastActiveDate;
  final bool isPremium;
  final DateTime? joinDate;

  UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    required this.xp,
    required this.level,
    required this.coins,
    required this.streakDays,
    required this.lessonsCompleted,
    required this.lastActiveDate,
    this.isPremium = false,
    this.joinDate,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      displayName: data['displayName'] ?? 'User',
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'],
      xp: data['xp'] ?? 0,
      level: data['level'] ?? 1,
      coins: data['coins'] ?? 200,
      streakDays: data['streakDays'] ?? 0,
      lessonsCompleted: data['lessonsCompleted'] ?? 0,
      lastActiveDate: data['lastActiveDate'] ?? '',
      isPremium: data['isPremium'] ?? false,
      joinDate: data['joinDate'] != null
          ? (data['joinDate'] as Timestamp).toDate()
          : null,
    );
  }

  // Helper getters
  int get xpForNextLevel => level * 1000;
  int get currentXpInLevel => xp % 1000;
  double get xpProgress => currentXpInLevel / xpForNextLevel;
}

/// Provider for the current user's profile data
/// Returns null if not authenticated or data doesn't exist
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return Stream.value(null);
  }

  return ref
      .watch(authServiceProvider)
      .getUserProfile(userId)
      .map((doc) {
        if (!doc.exists) return null;
        return UserProfile.fromFirestore(doc);
      });
});

/// Provider for refreshing user profile
final refreshUserProfileProvider = FutureProvider.family<void, String>((ref, userId) async {
  // This will force a refresh of the user profile
  await ref.read(authServiceProvider).getUserProfileOnce(userId);
});
