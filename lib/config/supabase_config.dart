/// Supabase Configuration
///
/// Configure your Supabase project settings here
library;

class SupabaseConfig {
  /// Supabase project URL
  /// Replace with your actual Supabase project URL from the dashboard
  static const String projectUrl = 'https://bajbfzwecuzywcdebvgh.supabase.co';

  /// Supabase Edge Functions base URL
  static const String functionsUrl = '$projectUrl/functions/v1';

  /// Individual function endpoints - P0 (Game Submissions)
  static const String submitLifeSwipe = '$functionsUrl/submit-life-swipe';
  static const String submitBudgetBlitz = '$functionsUrl/submit-budget-blitz';
  static const String submitQuizBattle = '$functionsUrl/submit-quiz-battle';
  static const String submitMarketExplorer = '$functionsUrl/submit-market-explorer';

  /// P1 (Learning & Progress)
  static const String completeLesson = '$functionsUrl/complete-lesson';
  static const String dailyCheckin = '$functionsUrl/daily-checkin';
  static const String checkAchievements = '$functionsUrl/check-achievements';
  static const String updateLeaderboard = '$functionsUrl/update-leaderboard';
  static const String generateDailyChallenges = '$functionsUrl/generate-daily-challenges';
  static const String resetStreaks = '$functionsUrl/reset-streaks';

  /// P2 (Social & Notifications)
  static const String searchUsers = '$functionsUrl/search-users';
  static const String sendNotification = '$functionsUrl/send-notification';
  static const String quizMatchmaking = '$functionsUrl/quiz-matchmaking';

  /// Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);

  /// Enable debug logging
  static const bool debugMode = true;
}
