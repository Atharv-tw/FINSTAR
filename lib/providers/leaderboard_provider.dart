import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

/// Leaderboard entry model
class LeaderboardEntry {
  final String userId;
  final String displayName;
  final String? photoURL;
  final int xp;
  final int level;
  final int coins;
  final bool isPremium;
  final int rank; // Calculated based on position
  final List<String> badges;

  LeaderboardEntry({
    required this.userId,
    required this.displayName,
    this.photoURL,
    required this.xp,
    required this.level,
    required this.coins,
    this.isPremium = false,
    required this.rank,
    this.badges = const [],
  });

  factory LeaderboardEntry.fromFirestore(DocumentSnapshot doc, int rank) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardEntry(
      userId: doc.id,
      displayName: data['displayName'] ?? 'User',
      photoURL: data['photoURL'],
      xp: data['xp'] ?? 0,
      level: data['level'] ?? 1,
      coins: data['coins'] ?? 200,
      isPremium: data['isPremium'] ?? false,
      rank: rank,
      badges: List<String>.from(data['badges'] ?? []),
    );
  }
}

/// Provider for leaderboard data - fetches all users sorted by XP
final leaderboardProvider = StreamProvider<List<LeaderboardEntry>>((ref) {
  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('users')
      .orderBy('xp', descending: true)
      .limit(100) // Top 100 users
      .snapshots()
      .map((snapshot) {
    final entries = <LeaderboardEntry>[];
    for (int i = 0; i < snapshot.docs.length; i++) {
      entries.add(LeaderboardEntry.fromFirestore(snapshot.docs[i], i + 1));
    }
    return entries;
  });
});

/// Provider for current user's rank
final currentUserRankProvider = FutureProvider<int?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final firestore = FirebaseFirestore.instance;

  // Get user's XP
  final userDoc = await firestore.collection('users').doc(userId).get();
  if (!userDoc.exists) return null;

  final userXp = userDoc.data()?['xp'] ?? 0;

  // Count users with more XP (to determine rank)
  final higherRankedCount = await firestore
      .collection('users')
      .where('xp', isGreaterThan: userXp)
      .count()
      .get();

  return higherRankedCount.count! + 1; // Rank is count + 1
});

/// Provider for user's position in leaderboard
final userLeaderboardPositionProvider = Provider<int?>((ref) {
  final leaderboard = ref.watch(leaderboardProvider);
  final userId = ref.watch(currentUserIdProvider);

  return leaderboard.when(
    data: (entries) {
      final index = entries.indexWhere((entry) => entry.userId == userId);
      return index >= 0 ? index : null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
