import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

/// Friend model
class Friend {
  final String userId;
  final String displayName;
  final String? photoURL;
  final int level;
  final int xp;
  final FriendStatus status;
  final DateTime createdAt;

  Friend({
    required this.userId,
    required this.displayName,
    this.photoURL,
    required this.level,
    required this.xp,
    required this.status,
    required this.createdAt,
  });

  factory Friend.fromFirestore(Map<String, dynamic> data) {
    return Friend(
      userId: data['userId'] ?? '',
      displayName: data['displayName'] ?? 'User',
      photoURL: data['photoURL'],
      level: data['level'] ?? 1,
      xp: data['xp'] ?? 0,
      status: FriendStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => FriendStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'displayName': displayName,
      'photoURL': photoURL,
      'level': level,
      'xp': xp,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

enum FriendStatus {
  pending, // Friend request sent/received
  accepted, // Friends
  blocked, // Blocked user
}

/// Provider for user's friends list
final friendsProvider = StreamProvider<List<Friend>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value([]);
  }

  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('users')
      .doc(userId)
      .collection('friends')
      .where('status', isEqualTo: 'accepted')
      .snapshots()
      .asyncMap((snapshot) async {
    final friends = <Friend>[];

    for (var doc in snapshot.docs) {
      final friendData = doc.data();
      final friendId = friendData['userId'];

      // Get friend's current stats
      final friendDoc = await firestore.collection('users').doc(friendId).get();
      if (friendDoc.exists) {
        final friendUserData = friendDoc.data()!;
        friends.add(Friend(
          userId: friendId,
          displayName: friendUserData['displayName'] ?? 'User',
          photoURL: friendUserData['photoURL'],
          level: friendUserData['level'] ?? 1,
          xp: friendUserData['xp'] ?? 0,
          status: FriendStatus.accepted,
          createdAt: (friendData['createdAt'] as Timestamp).toDate(),
        ));
      }
    }

    // Sort by XP (highest first)
    friends.sort((a, b) => b.xp.compareTo(a.xp));
    return friends;
  });
});

/// Provider for pending friend requests
final pendingFriendRequestsProvider = StreamProvider<List<Friend>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value([]);
  }

  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('users')
      .doc(userId)
      .collection('friendRequests')
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .asyncMap((snapshot) async {
    final requests = <Friend>[];

    for (var doc in snapshot.docs) {
      final requestData = doc.data();
      final friendId = requestData['fromUserId'];

      // Get requester's current stats
      final friendDoc = await firestore.collection('users').doc(friendId).get();
      if (friendDoc.exists) {
        final friendUserData = friendDoc.data()!;
        requests.add(Friend(
          userId: friendId,
          displayName: friendUserData['displayName'] ?? 'User',
          photoURL: friendUserData['photoURL'],
          level: friendUserData['level'] ?? 1,
          xp: friendUserData['xp'] ?? 0,
          status: FriendStatus.pending,
          createdAt: (requestData['createdAt'] as Timestamp).toDate(),
        ));
      }
    }

    return requests;
  });
});

/// Send friend request
final sendFriendRequestProvider = Provider((ref) {
  return (String friendId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) throw Exception('User not authenticated');
    if (userId == friendId) throw Exception('Cannot add yourself as friend');

    final firestore = FirebaseFirestore.instance;

    // Check if already friends or request exists
    final existingFriend = await firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .doc(friendId)
        .get();

    if (existingFriend.exists) {
      throw Exception('Already friends or request pending');
    }

    // Get current user data
    final userDoc = await firestore.collection('users').doc(userId).get();
    final userData = userDoc.data()!;

    // Create friend request in recipient's collection
    await firestore
        .collection('users')
        .doc(friendId)
        .collection('friendRequests')
        .doc(userId)
        .set({
      'fromUserId': userId,
      'fromDisplayName': userData['displayName'],
      'fromPhotoURL': userData['photoURL'],
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    print('Friend request sent to $friendId');
  };
});

/// Accept friend request
final acceptFriendRequestProvider = Provider((ref) {
  return (String friendId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) throw Exception('User not authenticated');

    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    // Get both users' data
    final currentUserDoc = await firestore.collection('users').doc(userId).get();
    final friendDoc = await firestore.collection('users').doc(friendId).get();

    if (!currentUserDoc.exists || !friendDoc.exists) {
      throw Exception('User not found');
    }

    final currentUserData = currentUserDoc.data()!;
    final friendData = friendDoc.data()!;

    // Add to current user's friends
    final currentUserFriendRef = firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .doc(friendId);

    batch.set(currentUserFriendRef, {
      'userId': friendId,
      'displayName': friendData['displayName'],
      'photoURL': friendData['photoURL'],
      'level': friendData['level'],
      'xp': friendData['xp'],
      'status': 'accepted',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Add to friend's friends
    final friendFriendRef = firestore
        .collection('users')
        .doc(friendId)
        .collection('friends')
        .doc(userId);

    batch.set(friendFriendRef, {
      'userId': userId,
      'displayName': currentUserData['displayName'],
      'photoURL': currentUserData['photoURL'],
      'level': currentUserData['level'],
      'xp': currentUserData['xp'],
      'status': 'accepted',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Delete friend request
    final requestRef = firestore
        .collection('users')
        .doc(userId)
        .collection('friendRequests')
        .doc(friendId);

    batch.delete(requestRef);

    await batch.commit();
    print('Friend request accepted: $friendId');
  };
});

/// Remove friend
final removeFriendProvider = Provider((ref) {
  return (String friendId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) throw Exception('User not authenticated');

    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    // Remove from current user's friends
    final currentUserFriendRef = firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .doc(friendId);

    batch.delete(currentUserFriendRef);

    // Remove from friend's friends
    final friendFriendRef = firestore
        .collection('users')
        .doc(friendId)
        .collection('friends')
        .doc(userId);

    batch.delete(friendFriendRef);

    await batch.commit();
    print('Friend removed: $friendId');
  };
});

/// Search users by display name
final searchUsersProvider = FutureProvider.family<List<Friend>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final userId = ref.read(currentUserIdProvider);
  if (userId == null) return [];

  final firestore = FirebaseFirestore.instance;

  // Search users with displayName starting with query
  final querySnapshot = await firestore
      .collection('users')
      .where('displayName', isGreaterThanOrEqualTo: query)
      .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
      .limit(20)
      .get();

  final users = <Friend>[];
  for (var doc in querySnapshot.docs) {
    if (doc.id == userId) continue; // Skip current user

    final data = doc.data();
    users.add(Friend(
      userId: doc.id,
      displayName: data['displayName'] ?? 'User',
      photoURL: data['photoURL'],
      level: data['level'] ?? 1,
      xp: data['xp'] ?? 0,
      status: FriendStatus.pending,
      createdAt: DateTime.now(),
    ));
  }

  return users;
});
