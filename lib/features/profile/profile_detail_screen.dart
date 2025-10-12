import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens.dart';
import '../../shared/widgets/blur_dock.dart';
import '../../shared/widgets/xp_ring.dart';
import '../../models/user_profile.dart';
import '../../data/user_data.dart';

/// Profile Detail Screen - Shows user stats, achievements, and progress
class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final user = UserData.currentUser;

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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Header
                      _buildHeader(),

                      const SizedBox(height: 32),

                      // Profile Card
                      _buildProfileCard(),

                      const SizedBox(height: 24),

                      // Stats Grid
                      _buildStatsGrid(),

                      const SizedBox(height: 24),

                      // Achievements Section
                      _buildAchievementsSection(),

                      const SizedBox(height: 120), // Space for bottom nav
                    ],
                  ),
                ),
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
                selectedIndex: 3,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            // TODO: Navigate to settings
          },
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      DesignTokens.primarySolid.withValues(alpha: 0.2),
                      DesignTokens.primarySolid.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: DesignTokens.primarySolid.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: DesignTokens.primarySolid.withValues(alpha: 0.2),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar and XP Ring
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        XpRing(
                          currentXp: user.currentXp,
                          xpForNextLevel: user.xpForNextLevel,
                          level: user.level,
                          size: 120,
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: DesignTokens.primaryGradient,
                          ),
                          child: Center(
                            child: Text(
                              user.username[0].toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Username
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Rank and XP
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.emoji_events,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Rank #${user.rank}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                '${user.totalXp} XP',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Streak
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_fire_department,
                              color: Color(0xFFFF6B35), size: 24),
                          const SizedBox(width: 8),
                          Text(
                            '${user.streakDays} Day Streak',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      {'icon': Icons.school, 'label': 'Modules', 'value': '${user.completedModules}/4'},
      {'icon': Icons.quiz, 'label': 'Quizzes', 'value': '${user.quizzesCompleted}'},
      {'icon': Icons.videogame_asset, 'label': 'Games', 'value': '${user.gamesPlayed}'},
      {
        'icon': Icons.monetization_on,
        'label': 'Coins',
        'value': '${user.coins}'
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        final delay = index * 0.1;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final staggerValue =
                (_animationController.value - delay).clamp(0.0, 1.0);
            return Transform.scale(
              scale: staggerValue,
              child: Opacity(
                opacity: staggerValue,
                child: child,
              ),
            );
          },
          child: _buildStatCard(stat),
        );
      },
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                stat['icon'] as IconData,
                color: DesignTokens.primarySolid,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                stat['value'] as String,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                stat['label'] as String,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsSection() {
    final achievements = UserData.achievements;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Achievements',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            final delay = index * 0.08;

            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final staggerValue =
                    (_animationController.value - delay).clamp(0.0, 1.0);
                return Transform.scale(
                  scale: staggerValue,
                  child: Opacity(
                    opacity: staggerValue,
                    child: child,
                  ),
                );
              },
              child: _buildAchievementCard(achievement),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: achievement.isUnlocked
                ? achievement.color.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: achievement.isUnlocked
                  ? achievement.color.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? achievement.color.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  achievement.icon,
                  color: achievement.isUnlocked
                      ? achievement.color
                      : Colors.white.withValues(alpha: 0.3),
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                achievement.title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: achievement.isUnlocked
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.3),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
