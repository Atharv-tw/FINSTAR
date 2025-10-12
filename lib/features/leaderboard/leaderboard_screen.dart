import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens.dart';
import '../../shared/widgets/blur_dock.dart';
import '../../models/user_profile.dart';
import '../../data/user_data.dart';

/// Leaderboard Screen - Shows top players rankings
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      // Scroll to current user position
      Future.delayed(const Duration(milliseconds: 500), () {
        final currentUserIndex = UserData.leaderboard
            .indexWhere((entry) => entry.userId == UserData.currentUser.id);
        if (currentUserIndex > 3 && mounted) {
          _scrollController.animateTo(
            (currentUserIndex - 3) * 100.0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutQuart,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF000000),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Top 3 Podium
                  _buildPodium(),

                  const SizedBox(height: 24),

                  // Leaderboard List
                  Expanded(
                    child: _buildLeaderboardList(),
                  ),
                ],
              ),
            ),

            // Bottom navigation
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BlurDock(
                items: const [
                  NavItem(icon: Icons.home_rounded, label: 'Home', route: '/'),
                  NavItem(
                      icon: Icons.videogame_asset_rounded,
                      label: 'Play Games',
                      route: '/game'),
                  NavItem(
                      icon: Icons.leaderboard_rounded,
                      label: 'Leaderboard',
                      route: '/rewards'),
                  NavItem(
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      route: '/profile'),
                ],
                selectedIndex: 2,
                showFab: false,
                onItemTap: (index) {
                  final routes = ['/', '/game', '/rewards', '/profile'];
                  context.go(routes[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Text(
            'Leaderboard',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          // Friends button
          GestureDetector(
            onTap: () => context.push('/friends'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Friends',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: DesignTokens.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Rank #${UserData.currentUser.rank}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium() {
    final top3 = UserData.leaderboard.take(3).toList();
    if (top3.length < 3) return const SizedBox();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 2nd Place
                _buildPodiumCard(top3[1], 2, 140, value),
                const SizedBox(width: 12),
                // 1st Place
                _buildPodiumCard(top3[0], 1, 180, value),
                const SizedBox(width: 12),
                // 3rd Place
                _buildPodiumCard(top3[2], 3, 120, value),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPodiumCard(
      LeaderboardEntry entry, int rank, double height, double animValue) {
    final colors = {
      1: [const Color(0xFFFFD700), const Color(0xFFFFA500)], // Gold
      2: [const Color(0xFFC0C0C0), const Color(0xFF808080)], // Silver
      3: [const Color(0xFFCD7F32), const Color(0xFF8B4513)], // Bronze
    };

    return Expanded(
      child: Column(
        children: [
          // Avatar with rank badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: colors[rank]!,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors[rank]![0].withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    entry.username[0].toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors[rank]!),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Username
          Text(
            entry.username,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // Podium
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: height * animValue,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors[rank]!,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stars, color: Colors.white, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    '${entry.totalXp} XP',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList() {
    final remainingEntries = UserData.leaderboard.skip(3).toList();

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      itemCount: remainingEntries.length,
      itemBuilder: (context, index) {
        final entry = remainingEntries[index];
        final isCurrentUser = entry.userId == UserData.currentUser.id;
        final delay = index * 0.05;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final staggerValue =
                (_animationController.value - delay).clamp(0.0, 1.0);
            return Transform.translate(
              offset: Offset(0, 20 * (1 - staggerValue)),
              child: Opacity(
                opacity: staggerValue,
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildLeaderboardCard(entry, isCurrentUser),
          ),
        );
      },
    );
  }

  Widget _buildLeaderboardCard(LeaderboardEntry entry, bool isCurrentUser) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? DesignTokens.primarySolid.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrentUser
                  ? DesignTokens.primarySolid.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.1),
              width: isCurrentUser ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Rank
              SizedBox(
                width: 32,
                child: Text(
                  '#${entry.rank}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCurrentUser
                        ? DesignTokens.primarySolid
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isCurrentUser ? DesignTokens.primaryGradient : null,
                  color: isCurrentUser
                      ? null
                      : Colors.white.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Text(
                    entry.username[0].toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            entry.username,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: DesignTokens.primaryGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'YOU',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Level ${entry.level}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ...entry.badges.take(3).map((badge) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.verified,
                                size: 14,
                                color: DesignTokens.primarySolid
                                    .withValues(alpha: 0.7),
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              ),

              // XP
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${entry.totalXp}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'XP',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
