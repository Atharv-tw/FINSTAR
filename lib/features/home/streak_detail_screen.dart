import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens.dart';

/// Streak Detail Screen - Shows detailed streak information
class StreakDetailScreen extends StatelessWidget {
  final int streakDays;

  const StreakDetailScreen({
    super.key,
    this.streakDays = 0,
  });

  @override
  Widget build(BuildContext context) {
    final currentTitle = _getCurrentTitle();
    final allLevels = _getAllLevels();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: DesignTokens.vibrantBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Streak Card
                      _buildCurrentStreakCard(currentTitle),

                      const SizedBox(height: 24),

                      // Streak Stats
                      _buildStreakStats(),

                      const SizedBox(height: 24),

                      // All Levels Section
                      _buildAllLevelsSection(allLevels),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0D).withValues(alpha: 0.85),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          const Spacer(),
          // Centered title
          const Text(
            'Streak Progress',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          // Invisible spacer for centering
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildCurrentStreakCard(StreakTitleData currentTitle) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0B0B0D).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: currentTitle.color.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: currentTitle.color.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Flame icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF6B4A),
                      Color(0xFFFF8C00),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B4A).withValues(alpha: 0.5),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),

              const SizedBox(height: 16),

              // Streak number
              Text(
                '$streakDays',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                ),
              ),

              const SizedBox(height: 8),

              // "Day Streak" text
              Text(
                streakDays == 1 ? 'Day Streak' : 'Days Streak',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),

              const SizedBox(height: 24),

              // Current title badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: currentTitle.gradientColors),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentTitle.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      currentTitle.title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
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
    );
  }

  Widget _buildStreakStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Longest Streak',
            '$streakDays',
            Icons.trending_up,
            const Color(0xFF2ECC71),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Days',
            '$streakDays',
            Icons.calendar_today,
            const Color(0xFF3498DB),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0B0B0D).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllLevelsSection(List<StreakTitleData> allLevels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Achievement Levels',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...allLevels.map((level) => _buildLevelCard(level)).toList(),
      ],
    );
  }

  Widget _buildLevelCard(StreakTitleData level) {
    final isUnlocked = streakDays >= level.daysRequired;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0B0B0D).withValues(alpha: isUnlocked ? 0.6 : 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUnlocked
                    ? level.color.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: isUnlocked
                        ? LinearGradient(colors: level.gradientColors)
                        : LinearGradient(
                            colors: [
                              Colors.grey.withValues(alpha: 0.3),
                              Colors.grey.withValues(alpha: 0.2),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      level.emoji,
                      style: TextStyle(
                        fontSize: 28,
                        color: isUnlocked ? null : Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Title and requirement
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.title,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isUnlocked
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        level.daysRequired == 0
                            ? 'Starting level'
                            : '${level.daysRequired} days required',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),

                // Status
                if (isUnlocked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: level.gradientColors),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'UNLOCKED',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.lock_outline,
                    color: Colors.white.withValues(alpha: 0.3),
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  StreakTitleData _getCurrentTitle() {
    if (streakDays >= 90) {
      return StreakTitleData(
        title: 'Finance Pro',
        emoji: '👑',
        color: const Color(0xFFFFD700),
        gradientColors: const [Color(0xFFFFD700), Color(0xFFFFAA00)],
        daysRequired: 90,
      );
    } else if (streakDays >= 60) {
      return StreakTitleData(
        title: 'Money Master',
        emoji: '💎',
        color: const Color(0xFF9B59B6),
        gradientColors: const [Color(0xFF9B59B6), Color(0xFF8E44AD)],
        daysRequired: 60,
      );
    } else if (streakDays >= 30) {
      return StreakTitleData(
        title: 'Budget Boss',
        emoji: '🌟',
        color: const Color(0xFF3498DB),
        gradientColors: const [Color(0xFF3498DB), Color(0xFF2980B9)],
        daysRequired: 30,
      );
    } else if (streakDays >= 14) {
      return StreakTitleData(
        title: 'Savings Star',
        emoji: '⭐',
        color: const Color(0xFF2ECC71),
        gradientColors: const [Color(0xFF2ECC71), Color(0xFF27AE60)],
        daysRequired: 14,
      );
    } else if (streakDays >= 7) {
      return StreakTitleData(
        title: 'Smart Spender',
        emoji: '💰',
        color: const Color(0xFFF39C12),
        gradientColors: const [Color(0xFFF39C12), Color(0xFFE67E22)],
        daysRequired: 7,
      );
    } else if (streakDays >= 3) {
      return StreakTitleData(
        title: 'Rookie Earner',
        emoji: '🌱',
        color: const Color(0xFF1ABC9C),
        gradientColors: const [Color(0xFF1ABC9C), Color(0xFF16A085)],
        daysRequired: 3,
      );
    } else {
      return StreakTitleData(
        title: 'Beginner',
        emoji: '🔰',
        color: const Color(0xFF95A5A6),
        gradientColors: const [Color(0xFF95A5A6), Color(0xFF7F8C8D)],
        daysRequired: 0,
      );
    }
  }

  List<StreakTitleData> _getAllLevels() {
    return [
      StreakTitleData(
        title: 'Finance Pro',
        emoji: '👑',
        color: const Color(0xFFFFD700),
        gradientColors: const [Color(0xFFFFD700), Color(0xFFFFAA00)],
        daysRequired: 90,
      ),
      StreakTitleData(
        title: 'Money Master',
        emoji: '💎',
        color: const Color(0xFF9B59B6),
        gradientColors: const [Color(0xFF9B59B6), Color(0xFF8E44AD)],
        daysRequired: 60,
      ),
      StreakTitleData(
        title: 'Budget Boss',
        emoji: '🌟',
        color: const Color(0xFF3498DB),
        gradientColors: const [Color(0xFF3498DB), Color(0xFF2980B9)],
        daysRequired: 30,
      ),
      StreakTitleData(
        title: 'Savings Star',
        emoji: '⭐',
        color: const Color(0xFF2ECC71),
        gradientColors: const [Color(0xFF2ECC71), Color(0xFF27AE60)],
        daysRequired: 14,
      ),
      StreakTitleData(
        title: 'Smart Spender',
        emoji: '💰',
        color: const Color(0xFFF39C12),
        gradientColors: const [Color(0xFFF39C12), Color(0xFFE67E22)],
        daysRequired: 7,
      ),
      StreakTitleData(
        title: 'Rookie Earner',
        emoji: '🌱',
        color: const Color(0xFF1ABC9C),
        gradientColors: const [Color(0xFF1ABC9C), Color(0xFF16A085)],
        daysRequired: 3,
      ),
      StreakTitleData(
        title: 'Beginner',
        emoji: '🔰',
        color: const Color(0xFF95A5A6),
        gradientColors: const [Color(0xFF95A5A6), Color(0xFF7F8C8D)],
        daysRequired: 0,
      ),
    ];
  }
}

/// Data class for streak titles
class StreakTitleData {
  final String title;
  final String emoji;
  final Color color;
  final List<Color> gradientColors;
  final int daysRequired;

  StreakTitleData({
    required this.title,
    required this.emoji,
    required this.color,
    required this.gradientColors,
    required this.daysRequired,
  });
}
