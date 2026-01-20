import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../config/supabase_config.dart';

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

  // Supabase project configuration from config file
  static String get _supabaseUrl => SupabaseConfig.functionsUrl;

  /// Get Firebase ID token for authentication
  Future<String?> _getAuthToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  /// Make authenticated POST request to Supabase function
  Future<Map<String, dynamic>> _callFunction(
    String functionName,
    Map<String, dynamic> data,
  ) async {
    final token = await _getAuthToken();
    if (token == null) {
      return {'success': false, 'error': 'User not authenticated'};
    }

    try {
      final response = await http.post(
        Uri.parse('$_supabaseUrl/$functionName'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorBody['error'] ?? 'Request failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Error calling $functionName: $e');
      return {'success': false, 'error': e.toString()};
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

  /// Daily check-in
  Future<Map<String, dynamic>> dailyCheckIn() async {
    return await _callFunction('daily-checkin', {});
  }

  /// Generate daily challenges
  Future<Map<String, dynamic>> generateDailyChallenges({
    bool forceRegenerate = false,
  }) async {
    return await _callFunction('generate-daily-challenges', {
      'forceRegenerate': forceRegenerate,
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

  /// Daily check-in with challenge generation
  Future<Map<String, dynamic>> dailyCheckInWithChallenges() async {
    final checkInResult = await dailyCheckIn();

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
