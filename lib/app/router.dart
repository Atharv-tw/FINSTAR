import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/basic_home_screen.dart';
import '../features/home/play_game_screen.dart';
import '../features/learn/learn_screen.dart';
import '../features/rewards/rewards_screen.dart';
import '../features/friends/friends_screen.dart';
import '../features/profile/profile_screen.dart';

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

      // Rewards & Badges
      GoRoute(
        path: '/rewards',
        name: 'rewards',
        builder: (context, state) => const RewardsScreen(),
      ),

      // Friends
      GoRoute(
        path: '/friends',
        name: 'friends',
        builder: (context, state) => const FriendsScreen(),
      ),

      // Profile
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Games (placeholders for now)
      GoRoute(
        path: '/game/life-swipe',
        name: 'life-swipe',
        builder: (context, state) => const Placeholder(), // TODO: LifeSwipeScreen
      ),
      GoRoute(
        path: '/game/quiz-battle',
        name: 'quiz-battle',
        builder: (context, state) => const Placeholder(), // TODO: QuizBattleScreen
      ),
      GoRoute(
        path: '/game/market-explorer',
        name: 'market-explorer',
        builder: (context, state) => const Placeholder(), // TODO: MarketExplorerScreen
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
