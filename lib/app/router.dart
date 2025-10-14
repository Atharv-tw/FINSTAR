import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/basic_home_screen.dart';
import '../features/home/play_game_screen.dart';
import '../features/home/streak_detail_screen.dart';
import '../features/learn/learn_screen.dart';
import '../features/leaderboard/leaderboard_screen.dart';
import '../features/friends/friends_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/learning/module_detail_screen.dart';
import '../features/learning/lesson_screen.dart';
import '../features/games/life_swipe/screens/life_swipe_game_screen.dart';
import '../features/games/life_swipe/screens/life_swipe_result_screen.dart';
import '../features/games/quiz_battle/screens/quiz_battle_screen.dart';
import '../features/games/market_explorer/screens/market_explorer_allocation_screen.dart';
import '../features/games/budget_blitz/screens/budget_blitz_game_screen.dart';
import '../shared/layouts/main_layout.dart';

/// App routing configuration using GoRouter
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Shell route for main navigation screens (with bottom nav bar)
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          // Home
          GoRoute(
            path: '/',
            name: 'basic-home',
            builder: (context, state) => const BasicHomeScreen(),
          ),

          // Play Games
          GoRoute(
            path: '/game',
            name: 'game',
            builder: (context, state) => const PlayGameScreen(),
          ),

          // Leaderboard
          GoRoute(
            path: '/rewards',
            name: 'rewards',
            builder: (context, state) => const LeaderboardScreen(),
          ),

          // Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileDetailScreen(),
          ),
        ],
      ),

      // Routes without bottom navigation bar

      // Learn module
      GoRoute(
        path: '/learn',
        name: 'learn',
        builder: (context, state) => const LearnScreen(),
      ),

      // Friends
      GoRoute(
        path: '/friends',
        name: 'friends',
        builder: (context, state) => const FriendsListScreen(),
      ),

      // Streak Detail
      GoRoute(
        path: '/streak-detail',
        name: 'streak-detail',
        builder: (context, state) {
          final streakDays = state.extra as int? ?? 0;
          return StreakDetailScreen(streakDays: streakDays);
        },
      ),

      // Learning Module Detail
      GoRoute(
        path: '/module/:moduleId',
        name: 'module-detail',
        builder: (context, state) {
          final moduleId = state.pathParameters['moduleId']!;
          return ModuleDetailScreen(moduleId: moduleId);
        },
      ),

      // Lesson Screen
      GoRoute(
        path: '/lesson/:moduleId/:lessonId',
        name: 'lesson',
        builder: (context, state) {
          final moduleId = state.pathParameters['moduleId']!;
          final lessonId = state.pathParameters['lessonId']!;
          return LessonScreen(moduleId: moduleId, lessonId: lessonId);
        },
      ),

      // Games
      GoRoute(
        path: '/game/life-swipe',
        name: 'life-swipe',
        builder: (context, state) => const LifeSwipeGameScreen(),
      ),
      GoRoute(
        path: '/game/life-swipe-result',
        name: 'life-swipe-result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return LifeSwipeResultScreen(
            totalBudget: extra['totalBudget'] as int,
            remainingBudget: extra['remainingBudget'] as int,
            spentMoney: extra['spentMoney'] as int,
            savedMoney: extra['savedMoney'] as int,
            happinessScore: extra['happinessScore'] as int,
            disciplineScore: extra['disciplineScore'] as int,
            socialScore: extra['socialScore'] as int,
            futureScore: extra['futureScore'] as int,
            financialHealth: extra['financialHealth'] as double,
            decisions: extra['decisions'] as List<Map<String, dynamic>>,
            badges: extra['badges'] as List<String>?,
            maxStreak: extra['maxStreak'] as int?,
          );
        },
      ),
      GoRoute(
        path: '/game/quiz-battle',
        name: 'quiz-battle',
        builder: (context, state) => const QuizBattleScreen(),
      ),
      GoRoute(
        path: '/game/market-explorer',
        name: 'market-explorer',
        builder: (context, state) => const MarketExplorerAllocationScreen(),
      ),
      GoRoute(
        path: '/game/budget-blitz',
        name: 'budget-blitz',
        builder: (context, state) => const BudgetBlitzGameScreen(),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
}
