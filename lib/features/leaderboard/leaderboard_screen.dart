import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens.dart';
import '../../providers/leaderboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/nature_background.dart'; // Add this import

/// Leaderboard Screen - Shows top players rankings with REAL Firebase data
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
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
      body: Stack(
        children: [
          // Background Gradient (Deep Atmospheric Teal)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    DesignTokens.primaryStart, // Green from home screen
                    DesignTokens.primaryEnd, // Green from home screen
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Top 3 Podium
                _buildPodium(),

                // Leaderboard List
                Expanded(
                  child: _buildLeaderboardList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Centered Title
          const Text(
            'Leaderboard',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),

          // Left and Right Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Rank display (Left)
              Consumer(
                builder: (context, ref, child) {
                  final userRank = ref.watch(currentUserRankProvider);
                  return userRank.when(
                    data: (rank) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: DesignTokens.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.emoji_events, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '#${rank ?? "?"}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    loading: () => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: DesignTokens.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.emoji_events, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    error: (_, __) => const SizedBox(),
                  );
                },
              ),

              // Friends button (Right)
              GestureDetector(
                onTap: () => context.push('/friends'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Friends',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodium() {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return leaderboardAsync.when(
      data: (leaderboard) {
        final top3 = leaderboard.take(3).toList();
        if (top3.length < 3) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text(
                'Not enough players yet!',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          );
        }

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
                _buildPodiumCard(top3[1], 2, 110, value),
                const SizedBox(width: 12),
                // 1st Place
                _buildPodiumCard(top3[0], 1, 150, value),
                const SizedBox(width: 12),
                // 3rd Place
                _buildPodiumCard(top3[2], 3, 90, value),
              ],
            ),
          ),
        );
      },
    );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(60),
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'Error loading leaderboard',
            style: TextStyle(color: Colors.red.shade300, fontSize: 16),
          ),
        ),
      ),
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
                    entry.displayName[0].toUpperCase(),
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
            entry.displayName,
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
                    '${entry.xp} XP',
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
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    return leaderboardAsync.when(
      data: (leaderboard) {
        final remainingEntries = leaderboard.skip(3).toList();

        if (remainingEntries.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text(
                'No more players yet!',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          );
        }

        // Animated slide-up for the card container
        final cardSlideAnimation = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic),
        ));

        return SlideTransition(
          position: cardSlideAnimation,
          child: Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: DesignTokens.backgroundPrimary.withOpacity(0.7),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 20, 12, 100),
                    itemCount: remainingEntries.length,
                    itemBuilder: (context, index) {
                      final entry = remainingEntries[index];
                      final isCurrentUser = entry.userId == currentUserId;
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
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(60),
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'Error loading leaderboard',
            style: TextStyle(color: Colors.red.shade300, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardCard(LeaderboardEntry entry, bool isCurrentUser) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? DesignTokens.primarySolid.withValues(alpha: 0.3)
            : const Color(0xFF4A90E2).withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser
              ? DesignTokens.primarySolid.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.15),
          width: isCurrentUser ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                    entry.displayName[0].toUpperCase(),
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
                            entry.displayName,
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
                    '${entry.xp}',
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
    );
  }
}
