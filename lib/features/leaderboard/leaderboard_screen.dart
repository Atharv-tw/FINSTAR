import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design_tokens.dart';
import '../../providers/leaderboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/nature_background.dart';

const Color brownVanDyke = Color(0xFF393027);

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
          // Calm Nature Background (match Home)
          const NatureBackground(),
          // Subtle grid overlay (match Play Game energy)
          Positioned.fill(
            child: CustomPaint(
              painter: _LeaderboardGridPainter(),
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
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LEADERBOARD',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.textPrimary,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: DesignTokens.surfaceCard.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: DesignTokens.textDisabled.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: DesignTokens.elevation1(),
                    ),
                    child: Text(
                      'THIS MONTH',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.textPrimary,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
                        color: DesignTokens.surfaceCard.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: DesignTokens.textDisabled.withValues(alpha: 0.35),
                          width: 1,
                        ),
                        boxShadow: DesignTokens.elevation1(),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.emoji_events, color: DesignTokens.primaryEnd, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '#${rank ?? "?"}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: DesignTokens.primaryEnd,
                            ),
                          ),
                        ],
                      ),
                    ),
                    loading: () => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: DesignTokens.surfaceCard.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: DesignTokens.textDisabled.withValues(alpha: 0.35),
                          width: 1,
                        ),
                        boxShadow: DesignTokens.elevation1(),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.emoji_events, color: DesignTokens.primaryEnd, size: 12),
                          SizedBox(width: 4),
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: DesignTokens.primaryEnd,
                            ),
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
                  padding: const EdgeInsets.all(8), // Adjusted padding for circle
                  decoration: BoxDecoration(
                    color: DesignTokens.surfaceCard.withValues(alpha: 0.7),
                    shape: BoxShape.circle, // Make it a circle
                    border: Border.all(
                      color: DesignTokens.textDisabled.withValues(alpha: 0.35),
                      width: 1,
                    ),
                    boxShadow: DesignTokens.elevation1(),
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1,
                    color: DesignTokens.primaryEnd,
                    size: 20,
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

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            // Use a curve for a more dynamic effect
            final animValue =
                Curves.easeOutQuart.transform(_animationController.value);

            return Transform.scale(
              scale: animValue,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 2nd Place
                    _buildPodiumCard(top3[1], 2, 110, animValue),
                    const SizedBox(width: 12),
                    // 1st Place
                    _buildPodiumCard(top3[0], 1, 150, animValue),
                    const SizedBox(width: 12),
                    // 3rd Place
                    _buildPodiumCard(top3[2], 3, 90, animValue),
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
          child: CircularProgressIndicator(color: brownVanDyke),
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
      1: [const Color(0xFFFFE7A3), const Color(0xFFFFD277)], // Pastel gold
      2: [const Color(0xFFE7EEF6), const Color(0xFFD5DEE8)], // Pastel silver
      3: [const Color(0xFFF2D2B6), const Color(0xFFE3B892)], // Pastel bronze
    };

    return Expanded(
      child: Column(
        children: [
          // Avatar with rank badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: colors[rank]!,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors[rank]![0].withValues(alpha: 0.55),
                      blurRadius: 22,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    entry.displayName[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.textPrimary,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors[rank]!),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: DesignTokens.textPrimary,
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
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DesignTokens.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // Podium
          Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              widthFactor: 0.83,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: height * animValue,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors[rank]!.map((c) => c.withValues(alpha: 0.9)).toList(),
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      border: Border(
                        top: BorderSide(color: Colors.white.withValues(alpha: 0.4), width: 1),
                      ),
                      boxShadow: [
                        ...DesignTokens.elevation2(),
                        BoxShadow(
                          color: colors[rank]![0].withValues(alpha: 0.4),
                          blurRadius: 24,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.workspace_premium,
                          color: DesignTokens.textPrimary,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ),
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
          child: Transform.translate(
            offset: Offset.zero,
            child: Container(
              margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF93A840).withValues(alpha: 0.2),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  border: Border.all(
                    color: const Color(0xFF393027).withValues(alpha: 0.4),
                  ),
                  boxShadow: DesignTokens.elevation4(),
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
          child: CircularProgressIndicator(color: brownVanDyke),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? DesignTokens.primaryStart.withValues(alpha: 0.18)
            : DesignTokens.surfaceCardLight.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentUser
              ? DesignTokens.primaryEnd.withValues(alpha: 0.6)
              : DesignTokens.textDisabled.withValues(alpha: 0.3),
          width: isCurrentUser ? 2 : 1,
        ),
        boxShadow: DesignTokens.elevation2(),
      ),
      child: Row(
            children: [
              // Rank
              Container(
                width: 36,
                height: 32,
                decoration: BoxDecoration(
                  color: DesignTokens.surfaceCard.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: DesignTokens.textDisabled.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '#${entry.rank}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isCurrentUser
                          ? DesignTokens.primaryEnd
                          : DesignTokens.textSecondary,
                    ),
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
                  color: DesignTokens.surfaceCard.withValues(alpha: 0.85),
                  border: Border.all(
                    color: isCurrentUser
                        ? DesignTokens.primaryEnd
                        : DesignTokens.textDisabled.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    entry.displayName[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.textPrimary,
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
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: DesignTokens.textPrimary,
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
                              color: DesignTokens.primaryStart,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'YOU',
                              style: GoogleFonts.poppins(
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
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: DesignTokens.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ...entry.badges.take(3).map((badge) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.verified,
                                size: 14,
                                color: DesignTokens.primaryEnd
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
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.primaryEnd,
                    ),
                  ),
                  Text(
                    'XP',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: DesignTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }
}

class _LeaderboardGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 48.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
