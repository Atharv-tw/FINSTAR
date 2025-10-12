import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/basic_home_screen.dart';
import '../features/home/play_game_screen.dart';
import '../features/learn/learn_screen.dart';
import '../features/leaderboard/leaderboard_screen.dart';
import '../features/friends/friends_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/learning/module_detail_screen.dart';
import '../features/learning/lesson_screen.dart';
import '../features/games/life_swipe/screens/life_swipe_game_screen.dart';
import '../features/games/quiz_battle/screens/quiz_battle_screen.dart';
import '../features/games/market_explorer/screens/market_explorer_allocation_screen.dart';

/// App routing configuration using GoRouter
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Basic Home route
      GoRoute(
        path: '/',
        name: 'basic-home',
        builder: (context, state) => const BasicHomeScreen(),
      ),

      // Game route (card screen with panda)
      GoRoute(
        path: '/game',
        name: 'game',
        builder: (context, state) => const PlayGameScreen(),
      ),

      // Learn module
      GoRoute(
        path: '/learn',
        name: 'learn',
        builder: (context, state) => const LearnScreen(),
      ),

      // Leaderboard
      GoRoute(
        path: '/rewards',
        name: 'rewards',
        builder: (context, state) => const LeaderboardScreen(),
      ),

      // Friends
      GoRoute(
        path: '/friends',
        name: 'friends',
        builder: (context, state) => const FriendsListScreen(),
      ),

      // Profile
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileDetailScreen(),
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
        path: '/game/quiz-battle',
        name: 'quiz-battle',
        builder: (context, state) => const QuizBattleScreen(),
      ),
      GoRoute(
        path: '/game/market-explorer',
        name: 'market-explorer',
        builder: (context, state) => const MarketExplorerAllocationScreen(),
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
