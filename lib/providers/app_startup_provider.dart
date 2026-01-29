import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/supabase_functions_service.dart';
import 'package:flutter/foundation.dart';

/// Provider that handles app startup tasks when user is authenticated
/// - Generates/fetches daily challenges
/// - Performs daily check-in
/// - Updates streak status
final appStartupProvider = FutureProvider.autoDispose<AppStartupResult>((ref) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return AppStartupResult(
      success: false,
      message: 'User not authenticated',
    );
  }

  final supabaseService = SupabaseFunctionsService();
  final results = <String, dynamic>{};

  try {
    // 1. Daily Check-in with Challenges (this generates challenges if needed)
    final checkInResult = await supabaseService.dailyCheckInWithChallenges();
    results['checkIn'] = checkInResult;

    return AppStartupResult(
      success: true,
      message: 'Startup tasks completed',
      checkInResult: checkInResult,
      challenges: checkInResult['challenges'],
      streakDays: checkInResult['streakDays'],
      xpAwarded: checkInResult['xpAwarded'],
      coinsAwarded: checkInResult['coinsAwarded'],
    );
  } catch (e) {
    // If Supabase fails, don't block the app - just log it
    debugPrint('App startup tasks failed: $e');
    return AppStartupResult(
      success: false,
      message: 'Startup tasks failed: $e',
    );
  }
});

/// Provider to manually trigger challenge generation
final generateChallengesProvider = FutureProvider.family<Map<String, dynamic>, bool>((ref, forceRegenerate) async {
  final supabaseService = SupabaseFunctionsService();
  return await supabaseService.generateDailyChallenges(forceRegenerate: forceRegenerate);
});

/// Result of app startup tasks
class AppStartupResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? checkInResult;
  final List<dynamic>? challenges;
  final int? streakDays;
  final int? xpAwarded;
  final int? coinsAwarded;

  AppStartupResult({
    required this.success,
    required this.message,
    this.checkInResult,
    this.challenges,
    this.streakDays,
    this.xpAwarded,
    this.coinsAwarded,
  });

  bool get isFirstCheckInToday => (xpAwarded ?? 0) > 0 || (coinsAwarded ?? 0) > 0;
}