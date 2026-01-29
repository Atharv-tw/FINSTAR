import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/achievements_provider.dart';
import '../../shared/widgets/progress_card.dart'; // Import ProgressCard

/// Profile Detail Screen - Shows user stats, achievements, and progress
class ProfileDetailScreen extends ConsumerStatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  ConsumerState<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends ConsumerState<ProfileDetailScreen> {

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return userProfileAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No user data found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await ref.read(authServiceProvider).signOut();
                      if (context.mounted) context.go('/login');
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFAFAF7), // Primary light background
                  Color(0xFFF5F5F0), // Slightly darker warm grey
                  Color(0xFFEBEBE5), // Muted warm grey
                ],
              ),
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

                          // Header with logout
                          _buildHeader(user),

                          const SizedBox(height: 32),

                          // Progress Card
                          ProgressCard(user: user),

                          const SizedBox(height: 24),

                          _buildStatsSection(user),

                          const SizedBox(height: 24),

                          _buildAchievementsSection(),

                          const SizedBox(height: 60), // Bottom spacing
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(authServiceProvider).signOut();
                  if (context.mounted) context.go('/login');
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(UserProfile user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Your Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: DesignTokens.textDarkPrimary,
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -4),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.logout, color: DesignTokens.textDarkSecondary),
                  onPressed: () async {
                    await ref.read(authServiceProvider).signOut();
                    if (mounted) context.go('/login');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.settings, color: DesignTokens.textDarkSecondary),
                  onPressed: () {
                    // Navigate to settings
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(UserProfile user) {
    final stats = [
      _StatTileData(
        label: 'Level',
        value: '${user.level}',
        icon: Icons.school,
        gradient: const LinearGradient(
          colors: [DesignTokens.primaryStart, DesignTokens.primaryEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _StatTileData(
        label: 'XP',
        value: '${user.xp}',
        icon: Icons.auto_awesome,
        gradient: const LinearGradient(
          colors: [DesignTokens.secondaryStart, DesignTokens.secondaryEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _StatTileData(
        label: 'Coins',
        value: '${user.coins}',
        icon: Icons.monetization_on_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3B0), Color(0xFFFFC857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _StatTileData(
        label: 'Streak',
        value: '${user.streakDays}',
        icon: Icons.local_fire_department,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB55A), Color(0xFFFF7A2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stats Snapshot',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: DesignTokens.textDarkPrimary,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: stats
                  .map((stat) => SizedBox(
                        width: cardWidth,
                        height: 92,
                        child: _buildStatTile(stat),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatTile(_StatTileData stat) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            stat.gradient.colors.first.withValues(alpha: 0.18),
            stat.gradient.colors.last.withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: DesignTokens.textDarkPrimary.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: stat.gradient.colors.first.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 10,
            bottom: 10,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: stat.gradient.colors.first.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                stat.icon,
                size: 18,
                color: DesignTokens.textDarkPrimary.withValues(alpha: 0.8),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.label.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: DesignTokens.textDarkSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  stat.value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: DesignTokens.textDarkPrimary,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    final achievementsAsync = ref.watch(achievementsProvider);

    return achievementsAsync.when(
      data: (achievements) {
        final visibleAchievements = achievements
            .where((a) => a.title.trim().isNotEmpty)
            .toList();
        final unlocked = visibleAchievements.where((a) => a.unlocked).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading remains separate
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Achievements',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: DesignTokens.textDarkPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: DesignTokens.primarySolid.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: DesignTokens.primarySolid.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    '${unlocked.length}/${visibleAchievements.length} unlocked',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.textDarkPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Single box for all achievements
            Container(
              constraints: const BoxConstraints(minHeight: 200), // Smaller height
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, // Reverted color
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: DesignTokens.textDarkPrimary.withValues(alpha: 0.12),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                  BoxShadow(
                    color: DesignTokens.surfaceCardLight,
                    blurRadius: 10,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Column( // Changed from Stack to Column
                mainAxisAlignment: MainAxisAlignment.center, // Center trophy and chips vertically
                crossAxisAlignment: CrossAxisAlignment.center, // Center trophy and chips horizontally
                children: [
                  // Background trophy icon with glow
                  Stack( // Keep trophy in a Stack for glow effect
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 120,
                        color: Colors.amber.withOpacity(0.1),
                      ),
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 100,
                        color: Colors.amber.withOpacity(0.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16), // Space between trophy and chips

                  // Grid of all achievements
                  if (visibleAchievements.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        'Your achievements will appear here. Keep playing!',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: DesignTokens.textDarkSecondary,
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: visibleAchievements.map((achievement) {
                        switch (achievement.type) {
                          case AchievementType.streak:
                            return _buildStreakChip(achievement);
                          case AchievementType.games:
                          case AchievementType.learning:
                          case AchievementType.firstSteps:
                          default:
                            if (achievement.unlocked) {
                              return _buildBadgeChip(achievement);
                            } else {
                              return _buildProgressCard(achievement);
                            }
                        }
                      }).toList(),
                    ),
                ],
              ),
            )
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: DesignTokens.surfaceCardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: DesignTokens.textDarkDisabled.withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          'Achievements are temporarily unavailable. Try again later.',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: DesignTokens.textDarkSecondary,
          ),
        ),
      ),
    );
  }

  // _buildAchievementRail is now removed

  Widget _buildBadgeChip(Achievement achievement) {
    final baseColor = achievement.color;
    return Container(
      width: 110,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: baseColor.withValues(alpha: 0.16),
        border: Border.all(color: baseColor.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.8),
              border: Border.all(color: baseColor.withValues(alpha: 0.5)),
            ),
            child: Icon(
              achievement.icon,
              color: baseColor,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: DesignTokens.textDarkPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakChip(Achievement achievement) {
    final baseColor = achievement.color;
    final progress = achievement.progressPercentage;
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            baseColor.withValues(alpha: 0.22),
            baseColor.withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: baseColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: baseColor.withValues(alpha: 0.2),
                ),
                child: Icon(
                  achievement.icon,
                  color: baseColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  achievement.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.textDarkPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${achievement.currentProgress}/${achievement.targetValue} days',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: DesignTokens.textDarkSecondary,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.6),
              valueColor: AlwaysStoppedAnimation<Color>(baseColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(Achievement achievement) {
    final baseColor = achievement.color;
    final progress = achievement.progressPercentage;
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: DesignTokens.surfaceCardLight,
        border: Border.all(color: baseColor.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            achievement.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: DesignTokens.textDarkPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            achievement.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              color: DesignTokens.textDarkSecondary,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(achievement.icon, size: 16, color: baseColor),
              const SizedBox(width: 6),
              Text(
                '${achievement.currentProgress}/${achievement.targetValue}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  color: DesignTokens.textDarkSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: DesignTokens.textDarkDisabled.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(baseColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTileData {
  final String label;
  final String value;
  final IconData icon;
  final LinearGradient gradient;

  const _StatTileData({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });
}
