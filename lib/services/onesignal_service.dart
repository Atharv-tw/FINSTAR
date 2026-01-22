import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// OneSignal Push Notification Service
///
/// Free tier: Unlimited push notifications
/// Replaces Firebase Cloud Messaging for scheduled notifications
class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isInitialized = false;

  // TODO: Replace with your OneSignal App ID from dashboard
  static const String _appId = 'YOUR_ONESIGNAL_APP_ID';

  /// Initialize OneSignal
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set log level for debugging (remove in production)
      if (kDebugMode) {
        OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      }

      // Initialize with App ID
      OneSignal.initialize(_appId);

      // Request notification permission
      await OneSignal.Notifications.requestPermission(true);

      // Handle notification clicks
      OneSignal.Notifications.addClickListener(_handleNotificationClick);

      // Handle foreground notifications
      OneSignal.Notifications.addForegroundWillDisplayListener(_handleForegroundNotification);

      _isInitialized = true;
      debugPrint('OneSignalService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing OneSignalService: $e');
    }
  }

  /// Link OneSignal player to Firebase user
  /// Call this after successful sign in
  Future<void> setExternalUserId(String? userId) async {
    try {
      if (userId != null) {
        // Log in with Firebase UID as external user ID
        await OneSignal.login(userId);

        // Save OneSignal player ID to Firestore for targeting
        final playerId = OneSignal.User.pushSubscription.id;
        if (playerId != null) {
          await _firestore.collection('users').doc(userId).update({
            'oneSignalPlayerId': playerId,
          });
          debugPrint('OneSignal user linked: $userId, playerId: $playerId');
        }
      } else {
        // Log out on sign out
        await OneSignal.logout();
        debugPrint('OneSignal user logged out');
      }
    } catch (e) {
      debugPrint('Error setting OneSignal external user ID: $e');
    }
  }

  /// Set user tags for segmentation
  /// Call this after user data is loaded to enable targeted notifications
  Future<void> setUserTags({
    required int level,
    required int streakDays,
    bool isPremium = false,
  }) async {
    try {
      await OneSignal.User.addTags({
        'level': level.toString(),
        'streakDays': streakDays.toString(),
        'isPremium': isPremium.toString(),
      });
      debugPrint('OneSignal tags updated: level=$level, streak=$streakDays');
    } catch (e) {
      debugPrint('Error setting OneSignal tags: $e');
    }
  }

  /// Handle notification click (app opened from notification)
  void _handleNotificationClick(OSNotificationClickEvent event) {
    debugPrint('Notification clicked: ${event.notification.additionalData}');

    final data = event.notification.additionalData;
    if (data == null) return;

    final type = data['type'];
    switch (type) {
      case 'friend_request':
        debugPrint('Navigate to friends screen');
        // TODO: Navigate to friends screen
        break;
      case 'streak_reminder':
        debugPrint('Navigate to home screen');
        // TODO: Navigate to home screen
        break;
      case 'daily_challenge':
        debugPrint('Navigate to challenges screen');
        // TODO: Navigate to challenges screen
        break;
      case 'achievement':
        debugPrint('Navigate to achievements screen');
        // TODO: Navigate to achievements screen
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }

  /// Handle foreground notification display
  void _handleForegroundNotification(OSNotificationWillDisplayEvent event) {
    debugPrint('Foreground notification received: ${event.notification.title}');
    // Display the notification (default behavior)
    event.notification.display();
  }
}
