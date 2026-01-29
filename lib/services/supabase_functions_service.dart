import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../config/supabase_config.dart';
import 'package:flutter/foundation.dart';

/// Service for calling Supabase Edge Functions
///
/// Handles all server-side game submissions, achievements, and scheduled tasks
/// while maintaining Firebase authentication
class SupabaseFunctionsService {
  // Singleton pattern
  static final SupabaseFunctionsService _instance =
      SupabaseFunctionsService._internal();
  factory SupabaseFunctionsService() => _instance;
  SupabaseFunctionsService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Request deduplication - prevent duplicate calls within a short window
  final Map<String, DateTime> _lastCallTimes = {};
  final Map<String, Future<Map<String, dynamic>>> _pendingCalls = {};
  static const Duration _deduplicationWindow = Duration(seconds: 5);

  // Supabase project configuration from config file
  static String get _supabaseUrl => SupabaseConfig.functionsUrl;

  // Use basic http client instead of IOClient (for debugging)
  static bool useBasicHttpClient = true;

  /// Get Firebase ID token for authentication
  Future<String?> _getAuthToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  /// Create HTTP client with proper TLS settings
  http.Client _createHttpClient() {
    final httpClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30)
      ..badCertificateCallback = (cert, host, port) => false; // Don't allow bad certs
    return IOClient(httpClient);
  }

  /// Simple connectivity test - call this to debug connection issues
  Future<Map<String, dynamic>> testConnectivity() async {
    debugPrint('=== SUPABASE CONNECTIVITY TEST ===');
    final results = <String, dynamic>{};

    // Test 1: Simple GET to base URL (should work without auth)
    debugPrint('Test 1: Simple HTTP GET to Supabase base URL...');
    try {
      final response = await http.get(
        Uri.parse('${SupabaseConfig.projectUrl}/rest/v1/'),
        headers: {'apikey': 'test'}, // Dummy key just to test connectivity
      ).timeout(const Duration(seconds: 10));
      results['simpleGet'] = 'Status: ${response.statusCode}';
      debugPrint('Test 1 result: ${response.statusCode}');
    } catch (e) {
      results['simpleGet'] = 'Error: $e';
      debugPrint('Test 1 error: $e');
    }

    // Test 2: GET to functions URL (should return error but proves connectivity)
    debugPrint('Test 2: HTTP GET to functions endpoint...');
    try {
      final response = await http.get(
        Uri.parse('${SupabaseConfig.functionsUrl}/generate-daily-challenges'),
      ).timeout(const Duration(seconds: 10));
      results['functionsGet'] = 'Status: ${response.statusCode}, Body: ${response.body.substring(0, response.body.length.clamp(0, 200))}';
      debugPrint('Test 2 result: ${response.statusCode}');
    } catch (e) {
      results['functionsGet'] = 'Error: $e';
      debugPrint('Test 2 error: $e');
    }

    // Test 3: POST to functions URL without auth (should return 401)
    debugPrint('Test 3: HTTP POST without auth...');
    try {
      final response = await http.post(
        Uri.parse('${SupabaseConfig.functionsUrl}/generate-daily-challenges'),
        headers: {'Content-Type': 'application/json'},
        body: '{}',
      ).timeout(const Duration(seconds: 10));
      results['functionsPostNoAuth'] = 'Status: ${response.statusCode}, Body: ${response.body.substring(0, response.body.length.clamp(0, 200))}';
      debugPrint('Test 3 result: ${response.statusCode} - ${response.body}');
    } catch (e) {
      results['functionsPostNoAuth'] = 'Error: $e';
      debugPrint('Test 3 error: $e');
    }

    // Test 4: POST with auth using basic http client (not IOClient)
    debugPrint('Test 4: HTTP POST with auth using basic http client...');
    try {
      final token = await _getAuthToken();
      if (token != null) {
        final response = await http.post(
          Uri.parse('${SupabaseConfig.functionsUrl}/generate-daily-challenges'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: '{"forceRegenerate": false}',
        ).timeout(const Duration(seconds: 15));
        results['functionsPostWithAuth'] = 'Status: ${response.statusCode}, Body: ${response.body.substring(0, response.body.length.clamp(0, 200))}';
        debugPrint('Test 4 result: ${response.statusCode} - ${response.body}');
      } else {
        results['functionsPostWithAuth'] = 'No auth token available';
        debugPrint('Test 4: No auth token');
      }
    } catch (e) {
      results['functionsPostWithAuth'] = 'Error: $e';
      debugPrint('Test 4 error: $e');
    }

    debugPrint('=== CONNECTIVITY TEST COMPLETE ===');
    debugPrint('Results: $results');
    return results;
  }

  /// Test auth verification with minimal function (no Firebase imports)
  Future<Map<String, dynamic>> testAuthOnly() async {
    debugPrint('=== TEST AUTH ONLY ===');
    final stopwatch = Stopwatch()..start();

    try {
      final token = await _getAuthToken();
      debugPrint('Test auth: [${stopwatch.elapsedMilliseconds}ms] Got token: ${token != null}');

      if (token == null) {
        return {'success': false, 'error': 'No auth token'};
      }

      debugPrint('Test auth: [${stopwatch.elapsedMilliseconds}ms] Making request...');
      final response = await http.post(
        Uri.parse('${SupabaseConfig.functionsUrl}/test-auth'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: '{}',
      ).timeout(const Duration(seconds: 15));

      debugPrint('Test auth: [${stopwatch.elapsedMilliseconds}ms] Response: ${response.statusCode}');
      debugPrint('Test auth: Body: ${response.body}');

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Test auth: [${stopwatch.elapsedMilliseconds}ms] Error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Make authenticated POST request to Supabase function
  Future<Map<String, dynamic>> _callFunction(
    String functionName,
    Map<String, dynamic> data,
  ) async {
    final stopwatch = Stopwatch()..start();
    debugPrint('Supabase: Starting call to $functionName');

    // Step 1: Get auth token
    debugPrint('Supabase: [${stopwatch.elapsedMilliseconds}ms] Getting auth token...');
    final token = await _getAuthToken();
    debugPrint('Supabase: [${stopwatch.elapsedMilliseconds}ms] Got auth token: ${token != null ? "yes (${token.length} chars)" : "null"}');

    if (token == null) {
      debugPrint('Supabase: User not authenticated');
      return {'success': false, 'error': 'User not authenticated'};
    }

    final url = '$_supabaseUrl/$functionName';
    debugPrint('Supabase: [${stopwatch.elapsedMilliseconds}ms] URL: $url');

    // Step 2: Make POST request
    debugPrint('Supabase: [${stopwatch.elapsedMilliseconds}ms] Using ${useBasicHttpClient ? "basic http" : "IOClient"}...');

    try {
      debugPrint('Supabase: [${stopwatch.elapsedMilliseconds}ms] Starting POST request...');
      final requestBody = jsonEncode(data);
      debugPrint('Supabase: [${stopwatch.elapsedMilliseconds}ms] Request body: $requestBody');

      http.Response response;
      if (useBasicHttpClient) {
        // Use basic http client (simpler, might work better on some devices)
        response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: requestBody,
        ).timeout(const Duration(seconds: 30));
      } else {
        // Use IOClient with custom settings
        final client = _createHttpClient();
        try {
          response = await client.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: requestBody,
          ).timeout(const Duration(seconds: 30));
        } finally {
          client.close();
        }
      }

      debugPrint('Supabase: [${stopwatch.elapsedMilliseconds}ms] Response received: ${response.statusCode}');
      debugPrint('Supabase: Response body: ${response.body.substring(0, response.body.length.clamp(0, 500))}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        Map<String, dynamic> errorBody = {};
        try {
          errorBody = jsonDecode(response.body);
        } catch (_) {}
        return {
          'success': false,
          'error': errorBody['error'] ?? 'Request failed with ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    } on SocketException catch (e) {
      debugPrint('Supabase: [${stopwatch.elapsedMilliseconds}ms] SocketException: $e');
      return {'success': false, 'error': 'Network error: ${e.message}'};
    } on TimeoutException catch (e) {
      debugPrint('Supabase: [${stopwatch.elapsedMilliseconds}ms] Timeout: $e');
      return {'success': false, 'error': 'Request timed out'};
    } on HandshakeException catch (e) {
      debugPrint('Supabase: [${stopwatch.elapsedMilliseconds}ms] TLS Handshake failed: $e');
      return {'success': false, 'error': 'TLS error: ${e.message}'};
    } catch (e, stackTrace) {
      debugPrint('Supabase: [${stopwatch.elapsedMilliseconds}ms] Error calling $functionName: $e');
      debugPrint('Supabase: Stack trace: $stackTrace');
      return {'success': false, 'error': e.toString()};
    } finally {
      stopwatch.stop();
      debugPrint('Supabase: [${stopwatch.elapsedMilliseconds}ms] Request completed/failed');
    }
  }

  // ============================================
  // GAME SUBMISSION FUNCTIONS
  // ============================================

  /// Submit Life Swipe game result
  Future<Map<String, dynamic>> submitLifeSwipe({
    required int seed,
    required Map<String, int> allocations,
    required int score,
    List<dynamic>? eventChoices,
  }) async {
    return await _callFunction('submit-life-swipe', {
      'seed': seed,
      'allocations': allocations,
      'score': score,
      if (eventChoices != null) 'eventChoices': eventChoices,
    });
  }

  /// Submit Budget Blitz game result
  Future<Map<String, dynamic>> submitBudgetBlitz({
    required int score,
    required int level,
    required int correctDecisions,
    required int totalDecisions,
    int? timeRemaining,
  }) async {
    return await _callFunction('submit-budget-blitz', {
      'score': score,
      'level': level,
      'correctDecisions': correctDecisions,
      'totalDecisions': totalDecisions,
      if (timeRemaining != null) 'timeRemaining': timeRemaining,
    });
  }

  /// Submit Quiz Battle game result
  Future<Map<String, dynamic>> submitQuizBattle({
    required int correctAnswers,
    required int totalQuestions,
    required int timeBonus,
    bool? isWinner,
    String? matchId,
    String? opponentUid,
    String? category,
  }) async {
    return await _callFunction('submit-quiz-battle', {
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'timeBonus': timeBonus,
      if (isWinner != null) 'isWinner': isWinner,
      if (matchId != null) 'matchId': matchId,
      if (opponentUid != null) 'opponentUid': opponentUid,
      if (category != null) 'category': category,
    });
  }

  /// Submit Market Explorer game result
  Future<Map<String, dynamic>> submitMarketExplorer({
    required double portfolioValue,
    required double initialValue,
    required Map<String, double> portfolio,
    required int decisionsCount,
    int? daysSimulated,
    List<dynamic>? trades,
  }) async {
    return await _callFunction('submit-market-explorer', {
      'portfolioValue': portfolioValue,
      'initialValue': initialValue,
      'portfolio': portfolio,
      'decisionsCount': decisionsCount,
      if (daysSimulated != null) 'daysSimulated': daysSimulated,
      if (trades != null) 'trades': trades,
    });
  }

  // ============================================
  // LEARNING FUNCTIONS
  // ============================================

  /// Complete a lesson
  Future<Map<String, dynamic>> completeLesson({
    required String lessonId,
    int? quizScore,
    int? timeSpent,
  }) async {
    return await _callFunction('complete-lesson', {
      'lessonId': lessonId,
      if (quizScore != null) 'quizScore': quizScore,
      if (timeSpent != null) 'timeSpent': timeSpent,
    });
  }

  // ============================================
  // DAILY ACTIVITIES
  // ============================================

  /// Daily check-in (with deduplication)
  Future<Map<String, dynamic>> dailyCheckIn() async {
    return await _callFunctionWithDedup('daily-checkin', {});
  }

  /// Call function with deduplication to prevent duplicate calls
  Future<Map<String, dynamic>> _callFunctionWithDedup(
    String functionName,
    Map<String, dynamic> data,
  ) async {
    final cacheKey = '$functionName:${_auth.currentUser?.uid ?? "anon"}';

    // Check if there's a pending call - return the same future
    if (_pendingCalls.containsKey(cacheKey)) {
      debugPrint('Supabase: [$functionName] Returning pending call (dedup)');
      return await _pendingCalls[cacheKey]!;
    }

    // Check if we called this recently - return cached result indicator
    final lastCall = _lastCallTimes[cacheKey];
    if (lastCall != null &&
        DateTime.now().difference(lastCall) < _deduplicationWindow) {
      debugPrint('Supabase: [$functionName] Skipped - called ${DateTime.now().difference(lastCall).inMilliseconds}ms ago (dedup)');
      return {'success': true, 'deduplicated': true, 'message': 'Already called recently'};
    }

    // Make the actual call and track it
    final future = _callFunction(functionName, data);
    _pendingCalls[cacheKey] = future;
    _lastCallTimes[cacheKey] = DateTime.now();

    try {
      final result = await future;
      return result;
    } finally {
      _pendingCalls.remove(cacheKey);
    }
  }

  /// Generate daily challenges (with deduplication)
  Future<Map<String, dynamic>> generateDailyChallenges({
    bool forceRegenerate = false,
  }) async {
    // Skip deduplication if force regenerating
    if (forceRegenerate) {
      return await _callFunction('generate-daily-challenges', {
        'forceRegenerate': true,
      });
    }
    // Use deduplication for normal calls
    return await _callFunctionWithDedup('generate-daily-challenges', {
      'forceRegenerate': false,
    });
  }

  // ============================================
  // ACHIEVEMENTS & PROGRESS
  // ============================================

  /// Check for new achievements
  Future<Map<String, dynamic>> checkAchievements({String? trigger}) async {
    return await _callFunction('check-achievements', {
      if (trigger != null) 'trigger': trigger,
    });
  }

  /// Update user's leaderboard position
  Future<Map<String, dynamic>> updateLeaderboard() async {
    return await _callFunction('update-leaderboard', {
      'mode': 'user',
    });
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Submit game and check achievements in one call
  Future<Map<String, dynamic>> submitGameWithAchievements({
    required String gameType,
    required Map<String, dynamic> gameData,
  }) async {
    Map<String, dynamic> result;

    // Submit game based on type
    switch (gameType) {
      case 'life_swipe':
        result = await submitLifeSwipe(
          seed: gameData['seed'] as int,
          allocations: Map<String, int>.from(gameData['allocations']),
          score: gameData['score'] as int,
          eventChoices: gameData['eventChoices'],
        );
        break;
      case 'budget_blitz':
        result = await submitBudgetBlitz(
          score: gameData['score'] as int,
          level: gameData['level'] as int,
          correctDecisions: gameData['correctDecisions'] as int,
          totalDecisions: gameData['totalDecisions'] as int,
        );
        break;
      case 'quiz_battle':
        result = await submitQuizBattle(
          correctAnswers: gameData['correctAnswers'] as int,
          totalQuestions: gameData['totalQuestions'] as int,
          timeBonus: gameData['timeBonus'] as int,
          isWinner: gameData['isWinner'] as bool?,
        );
        break;
      case 'market_explorer':
        result = await submitMarketExplorer(
          portfolioValue: (gameData['portfolioValue'] as num).toDouble(),
          initialValue: (gameData['initialValue'] as num).toDouble(),
          portfolio: Map<String, double>.from(
            (gameData['portfolio'] as Map).map(
              (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
            ),
          ),
          decisionsCount: gameData['decisionsCount'] as int,
        );
        break;
      default:
        return {'success': false, 'error': 'Unknown game type: $gameType'};
    }

    // If game submission successful, check achievements
    if (result['success'] == true) {
      final achievementResult = await checkAchievements(trigger: 'game');
      result['achievements'] = achievementResult;

      // Update leaderboard
      final leaderboardResult = await updateLeaderboard();
      result['leaderboard'] = leaderboardResult;
    }

    return result;
  }

  /// Complete lesson and check achievements
  Future<Map<String, dynamic>> completeLessonWithAchievements({
    required String lessonId,
    int? quizScore,
    int? timeSpent,
  }) async {
    final result = await completeLesson(
      lessonId: lessonId,
      quizScore: quizScore,
      timeSpent: timeSpent,
    );

    if (result['success'] == true) {
      final achievementResult = await checkAchievements(trigger: 'lesson');
      result['achievements'] = achievementResult;
    }

    return result;
  }

  /// Daily check-in with challenge generation (with deduplication)
  Future<Map<String, dynamic>> dailyCheckInWithChallenges() async {
    final cacheKey = 'dailyCheckInWithChallenges:${_auth.currentUser?.uid ?? "anon"}';

    // Check if there's a pending call - return the same future
    if (_pendingCalls.containsKey(cacheKey)) {
      debugPrint('Supabase: [dailyCheckInWithChallenges] Returning pending call (dedup)');
      return await _pendingCalls[cacheKey]!;
    }

    // Check if we called this recently
    final lastCall = _lastCallTimes[cacheKey];
    if (lastCall != null &&
        DateTime.now().difference(lastCall) < _deduplicationWindow) {
      debugPrint('Supabase: [dailyCheckInWithChallenges] Skipped - called ${DateTime.now().difference(lastCall).inMilliseconds}ms ago (dedup)');
      return {'success': true, 'deduplicated': true, 'message': 'Already called recently'};
    }

    // Make the call and track it
    final future = _dailyCheckInWithChallengesImpl();
    _pendingCalls[cacheKey] = future;
    _lastCallTimes[cacheKey] = DateTime.now();

    try {
      return await future;
    } finally {
      _pendingCalls.remove(cacheKey);
    }
  }

  /// Implementation of daily check-in with challenges (internal)
  Future<Map<String, dynamic>> _dailyCheckInWithChallengesImpl() async {
    final checkInResult = await dailyCheckIn();

    // Skip follow-up calls if this was already deduplicated
    if (checkInResult['deduplicated'] == true) {
      return checkInResult;
    }

    // Generate daily challenges if check-in successful
    if (checkInResult['success'] == true) {
      final challengesResult = await generateDailyChallenges();
      checkInResult['challenges'] = challengesResult;

      // Check streak achievements
      final achievementResult = await checkAchievements(trigger: 'streak');
      checkInResult['achievements'] = achievementResult;
    }

    return checkInResult;
  }

  // ============================================
  // SOCIAL & NOTIFICATIONS (P2)
  // ============================================

  /// Search users by display name
  Future<Map<String, dynamic>> searchUsers({
    required String query,
    int limit = 20,
  }) async {
    return await _callFunction('search-users', {
      'query': query,
      'limit': limit,
    });
  }

  /// Send push notification to a user
  Future<Map<String, dynamic>> sendNotification({
    required String targetUserId,
    required String title,
    required String body,
    String type = 'general',
    Map<String, dynamic>? data,
  }) async {
    return await _callFunction('send-notification', {
      'targetUserId': targetUserId,
      'title': title,
      'body': body,
      'type': type,
      if (data != null) 'data': data,
    });
  }

  // ============================================
  // MULTIPLAYER QUIZ (P2)
  // ============================================

  /// Find or create a quiz match
  Future<Map<String, dynamic>> findQuizMatch({
    String category = 'general',
  }) async {
    return await _callFunction('quiz-matchmaking', {
      'action': 'find_match',
      'category': category,
    });
  }

  /// Join an existing quiz match
  Future<Map<String, dynamic>> joinQuizMatch({
    required String matchId,
  }) async {
    return await _callFunction('quiz-matchmaking', {
      'action': 'join_match',
      'matchId': matchId,
    });
  }

  /// Set ready status for quiz match
  Future<Map<String, dynamic>> setQuizReady({
    required String matchId,
  }) async {
    return await _callFunction('quiz-matchmaking', {
      'action': 'ready',
      'matchId': matchId,
    });
  }

  /// Submit answer for quiz match
  Future<Map<String, dynamic>> submitQuizAnswer({
    required String matchId,
    required int questionIndex,
    required int answer,
  }) async {
    return await _callFunction('quiz-matchmaking', {
      'action': 'submit_answer',
      'matchId': matchId,
      'questionIndex': questionIndex,
      'answer': answer,
    });
  }

  /// Leave a quiz match
  Future<Map<String, dynamic>> leaveQuizMatch({
    required String matchId,
  }) async {
    return await _callFunction('quiz-matchmaking', {
      'action': 'leave_match',
      'matchId': matchId,
    });
  }

  /// Get quiz match details
  Future<Map<String, dynamic>> getQuizMatch({
    required String matchId,
  }) async {
    return await _callFunction('quiz-matchmaking', {
      'action': 'get_match',
      'matchId': matchId,
    });
  }
}