import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'game_logic_service.dart';
import 'notification_service.dart';
import '../providers/achievements_provider.dart';

/// Firebase Service - Free Tier Only
///
/// Optimized for Spark Plan (no billing required)
/// - Authentication ✅
/// - Firestore ✅
/// - Realtime Database ✅
/// - NO Cloud Functions (using GameLogicService instead)
/// - NO Cloud Storage (using Cloudinary instead)
class FirebaseServiceFree {
  // Singleton pattern
  static final FirebaseServiceFree _instance = FirebaseServiceFree._internal();
  factory FirebaseServiceFree() => _instance;
  FirebaseServiceFree._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _rtdb = FirebaseDatabase.instance;
  // Use explicit initialize() to pass serverClientId where required.
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleSignInInitialized = false;

  // Game logic service (client-side)
  final GameLogicService _gameLogic = GameLogicService();

  // ============================================
  // INITIALIZATION
  // ============================================

  /// Initialize Firebase with optimal settings
  Future<void> initialize() async {
    // Enable offline persistence for Firestore (CRITICAL for low latency)
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Configure RTDB for low latency
    if (!kIsWeb) {
      _rtdb.setPersistenceEnabled(true);
      _rtdb.setPersistenceCacheSizeBytes(10000000); // 10MB cache
    }

    await _googleSignIn.initialize(
      serverClientId:
          '479746642557-0u721aiehm5hcfjen542u156jnqstijq.apps.googleusercontent.com',
    );
    _googleSignInInitialized = true;

    debugPrint('Firebase initialized with offline persistence (Free tier)');
  }

  // ============================================
  // AUTHENTICATION
  // ============================================

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      if (!_googleSignInInitialized) {
        await _googleSignIn.initialize(
          serverClientId:
              '479746642557-0u721aiehm5hcfjen542u156jnqstijq.apps.googleusercontent.com',
        );
        _googleSignInInitialized = true;
      }

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        // The user canceled the sign-in
        throw FirebaseAuthException(code: 'sign-in-canceled', message: 'Google sign-in was cancelled');
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: null, // accessToken is not available for web in this flow
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      // Create user profile if new user
      await _createUserProfileIfNeeded(userCredential.user!);

      // Save FCM token for push notifications
      await NotificationService().saveTokenAfterLogin();

      debugPrint('Google sign-in successful: ${userCredential.user?.uid}');
      return userCredential;
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      rethrow;
    }
  }

  /// Sign in with email/password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Save FCM token for push notifications
    await NotificationService().saveTokenAfterLogin();

    return userCredential;
  }

  /// Register with email/password
  Future<UserCredential> registerWithEmail(
      String email, String password, String displayName) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update display name
    await userCredential.user?.updateDisplayName(displayName);

    // Create user profile in Firestore
    await _createUserProfile(
      userCredential.user!,
      displayName: displayName,
    );

    // Save FCM token for push notifications
    await NotificationService().saveTokenAfterLogin();

    return userCredential;
  }

  /// Create user profile if it doesn't exist
  Future<void> _createUserProfileIfNeeded(User user) async {
    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      await _createUserProfile(user);
    }
  }

  /// Create user profile
  Future<void> _createUserProfile(User user, {String? displayName}) async {
    await _firestore.collection('users').doc(user.uid).set({
      'displayName': displayName ?? user.displayName ?? 'User',
      'email': user.email,
      'avatarUrl': null, // Will be set via Cloudinary
      'xp': 0,
      'level': 1,
      'coins': 200, // Starter coins
      'streakDays': 0,
      'lastActiveDate': DateTime.now().toIso8601String().split('T')[0],
      'joinDate': FieldValue.serverTimestamp(),
      'isPremium': false,
      'notificationsEnabled': true,
      'gamesPlayed': 0,
      'lessonsCompleted': 0,
    });

    // Initialize achievements for new user
    await initializeAchievementsForUser(user.uid);
  }

  /// Sign out
  Future<void> signOut() async {
    // Remove FCM token before signing out
    await NotificationService().removeToken();
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ============================================
  // USER PROFILE
  // ============================================

  /// Get user profile stream (cache-first for low latency)
  Stream<DocumentSnapshot> getUserProfile(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots(includeMetadataChanges: true);
  }

  /// Get user profile once
  Future<DocumentSnapshot> getUserProfileOnce(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  /// Update user profile (safe fields only)
  Future<void> updateProfile(String uid, Map<String, dynamic> updates) async {
    // Remove server-managed fields if accidentally included
    updates.remove('xp');
    updates.remove('level');
    updates.remove('coins');
    updates.remove('rank');

    await _firestore.collection('users').doc(uid).update(updates);
  }

  /// Update avatar URL (after Cloudinary upload)
  Future<void> updateAvatarUrl(String uid, String cloudinaryPublicId) async {
    await _firestore.collection('users').doc(uid).update({
      'avatarUrl': cloudinaryPublicId, // Store public_id, not full URL
    });
  }

  // ============================================
  // GAME PROGRESS (using client-side logic)
  // ============================================

  /// Submit Life Swipe result
  Future<Map<String, dynamic>> submitLifeSwipe({
    required int seed,
    required Map<String, int> allocations,
    required int score,
    List<dynamic>? eventChoices,
  }) async {
    return await _gameLogic.submitLifeSwipe(
      seed: seed,
      allocations: allocations,
      score: score,
      eventChoices: eventChoices,
    );
  }

  /// Submit Budget Blitz result
  Future<Map<String, dynamic>> submitBudgetBlitz({
    required int score,
    required int level,
    required int correctDecisions,
    required int totalDecisions,
  }) async {
    return await _gameLogic.submitBudgetBlitz(
      score: score,
      level: level,
      correctDecisions: correctDecisions,
      totalDecisions: totalDecisions,
    );
  }

  /// Get game progress
  Stream<DocumentSnapshot> getGameProgress(String uid, String gameId) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('progress')
        .doc(gameId)
        .snapshots();
  }

  /// Get all game progress
  Stream<QuerySnapshot> getAllGameProgress(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('progress')
        .snapshots();
  }

  // ============================================
  // LEARNING
  // ============================================

  /// Get all lessons
  Stream<QuerySnapshot> getLessons() {
    return _firestore
        .collection('lessons')
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots();
  }

  /// Get lessons by module
  Stream<QuerySnapshot> getLessonsByModule(String moduleId) {
    return _firestore
        .collection('lessons')
        .where('moduleId', isEqualTo: moduleId)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots();
  }

  /// Complete lesson (using client-side logic)
  Future<Map<String, dynamic>> completeLesson(
      String lessonId, int quizScore) async {
    return await _gameLogic.completeLesson(lessonId, quizScore);
  }

  /// Get lesson progress
  Stream<QuerySnapshot> getLessonProgress(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('lessonProgress')
        .snapshots();
  }

  // ============================================
  // STREAK & CHECK-IN
  // ============================================

  /// Daily check-in (using client-side logic)
  Future<Map<String, dynamic>> dailyCheckIn() async {
    return await _gameLogic.dailyCheckIn();
  }

  // ============================================
  // STORE & PURCHASES
  // ============================================

  /// Get store items
  Stream<QuerySnapshot> getStoreItems() {
    return _firestore
        .collection('store')
        .doc('items')
        .collection('all')
        .snapshots();
  }

  /// Purchase item (using client-side logic with transaction)
  Future<Map<String, dynamic>> purchaseItem(String itemId) async {
    return await _gameLogic.purchaseItem(itemId);
  }

  /// Get user inventory
  Stream<QuerySnapshot> getUserInventory(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('inventory')
        .snapshots();
  }

  // ============================================
  // LEADERBOARD
  // ============================================

  /// Get current month leaderboard
  Stream<DocumentSnapshot> getLeaderboard() {
    final seasonId = DateTime.now().toIso8601String().substring(0, 7);
    return _firestore.collection('leaderboards').doc(seasonId).snapshots();
  }

  /// Get live leaderboard from RTDB (real-time)
  Stream<DatabaseEvent> getLiveLeaderboard() {
    return _rtdb.ref('leaderboards/live').onValue;
  }

  /// Update live leaderboard (client-side)
  Future<void> updateLiveLeaderboard(int score) async {
    final uid = currentUser!.uid;
    final userDoc = await getUserProfileOnce(uid);

    await _rtdb.ref('leaderboards/live/$uid').set({
      'uid': uid,
      'name': userDoc.get('displayName'),
      'score': score,
      'level': userDoc.get('level'),
      'updatedAt': ServerValue.timestamp,
    });
  }

  // ============================================
  // FRIENDS
  // ============================================

  /// Send friend request
  Future<void> sendFriendRequest(String friendUid) async {
    final uid = currentUser!.uid;

    await _firestore
        .collection('friends')
        .doc(uid)
        .collection('requests')
        .doc(friendUid)
        .set({
      'status': 'pending',
      'sentAt': FieldValue.serverTimestamp(),
    });
  }

  /// Accept friend request
  Future<void> acceptFriendRequest(String friendUid) async {
    final uid = currentUser!.uid;

    await _firestore
        .collection('friends')
        .doc(friendUid)
        .collection('requests')
        .doc(uid)
        .update({
      'status': 'accepted',
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get friend requests
  Stream<QuerySnapshot> getFriendRequests(String uid) {
    return _firestore
        .collection('friends')
        .doc(uid)
        .collection('requests')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  /// Get friends list
  Stream<QuerySnapshot> getFriends(String uid) {
    return _firestore
        .collection('friends')
        .doc(uid)
        .collection('requests')
        .where('status', isEqualTo: 'accepted')
        .snapshots();
  }

  // ============================================
  // BADGES & ACHIEVEMENTS
  // ============================================

  /// Get all badges
  Stream<QuerySnapshot> getBadges() {
    return _firestore.collection('badges').snapshots();
  }

  /// Get user achievements
  Stream<QuerySnapshot> getUserAchievements(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('achievements')
        .orderBy('unlockedAt', descending: true)
        .snapshots();
  }

  /// Check achievements (client-side)
  Future<void> checkAchievements() async {
    await _gameLogic.checkAchievements();
  }

  // ============================================
  // QUIZ ROOMS (Real-time)
  // ============================================

  /// Create quiz room
  Future<String> createQuizRoom() async {
    final uid = currentUser!.uid;
    final userData = await getUserProfileOnce(uid);

    final roomRef = _firestore.collection('rooms').doc();

    await roomRef.set({
      'hostUid': uid,
      'status': 'waiting',
      'createdAt': FieldValue.serverTimestamp(),
      'players': {
        uid: {
          'name': userData.get('displayName'),
          'avatar': userData.get('avatarUrl'),
          'ready': false,
          'score': 0,
        }
      },
      'currentQuestion': 0,
    });

    // Also create in RTDB for real-time updates
    await _rtdb.ref('rooms/${roomRef.id}').set({
      'hostUid': uid,
      'status': 'waiting',
      'players': {
        uid: {
          'name': userData.get('displayName'),
          'ready': false,
          'score': 0,
        }
      },
    });

    return roomRef.id;
  }

  /// Join quiz room
  Future<void> joinQuizRoom(String roomId) async {
    final uid = currentUser!.uid;
    final userData = await getUserProfileOnce(uid);

    await _firestore.collection('rooms').doc(roomId).update({
      'players.$uid': {
        'name': userData.get('displayName'),
        'avatar': userData.get('avatarUrl'),
        'ready': false,
        'score': 0,
      }
    });

    // Also update RTDB
    await _rtdb.ref('rooms/$roomId/players/$uid').set({
      'name': userData.get('displayName'),
      'ready': false,
      'score': 0,
    });
  }

  /// Listen to quiz room updates (RTDB for low latency)
  Stream<DatabaseEvent> watchQuizRoom(String roomId) {
    return _rtdb.ref('rooms/$roomId').onValue;
  }
}
