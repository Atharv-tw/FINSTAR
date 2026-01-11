import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Streak-based title bar that displays user achievement level
class StreakTitleBar extends StatefulWidget {
  final int streakDays;

  const StreakTitleBar({
    super.key,
    this.streakDays = 0,
  });

  @override
  State<StreakTitleBar> createState() => _StreakTitleBarState();
}

class _StreakTitleBarState extends State<StreakTitleBar>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressController.forward();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  /// Get title based on streak days
  StreakTitle _getStreakTitle() {
    if (widget.streakDays >= 90) {
      return StreakTitle(
        title: 'Finance Pro',
        emoji: '👑',
        color: const Color(0xFFFFD700), // Gold
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFAA00)],
        ),
      );
    } else if (widget.streakDays >= 60) {
      return StreakTitle(
        title: 'Money Master',
        emoji: '💎',
        color: const Color(0xFF9B59B6), // Purple
        gradient: const LinearGradient(
          colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
        ),
      );
    } else if (widget.streakDays >= 30) {
      return StreakTitle(
        title: 'Budget Boss',
        emoji: '🌟',
        color: const Color(0xFF3498DB), // Blue
        gradient: const LinearGradient(
          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
        ),
      );
    } else if (widget.streakDays >= 14) {
      return StreakTitle(
        title: 'Savings Star',
        emoji: '⭐',
        color: const Color(0xFF2ECC71), // Green
        gradient: const LinearGradient(
          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
        ),
      );
    } else if (widget.streakDays >= 7) {
      return StreakTitle(
        title: 'Smart Spender',
        emoji: '💰',
        color: const Color(0xFFF39C12), // Orange
        gradient: const LinearGradient(
          colors: [Color(0xFFF39C12), Color(0xFFE67E22)],
        ),
      );
    } else if (widget.streakDays >= 3) {
      return StreakTitle(
        title: 'Rookie Earner',
        emoji: '🌱',
        color: const Color(0xFF1ABC9C), // Teal
        gradient: const LinearGradient(
          colors: [Color(0xFF1ABC9C), Color(0xFF16A085)],
        ),
      );
    } else {
      return StreakTitle(
        title: 'Beginner',
        emoji: '🔰',
        color: const Color(0xFF95A5A6), // Gray
        gradient: const LinearGradient(
          colors: [Color(0xFF95A5A6), Color(0xFF7F8C8D)],
        ),
      );
    }
  }

  /// Get next milestone info
  Map<String, dynamic> _getNextMilestone() {
    if (widget.streakDays >= 90) {
      return {'days': 90, 'next': 90, 'title': 'Max Level!'};
    } else if (widget.streakDays >= 60) {
      return {'days': 90 - widget.streakDays, 'next': 90, 'title': 'Finance Pro'};
    } else if (widget.streakDays >= 30) {
      return {'days': 60 - widget.streakDays, 'next': 60, 'title': 'Money Master'};
    } else if (widget.streakDays >= 14) {
      return {'days': 30 - widget.streakDays, 'next': 30, 'title': 'Budget Boss'};
    } else if (widget.streakDays >= 7) {
      return {'days': 14 - widget.streakDays, 'next': 14, 'title': 'Savings Star'};
    } else if (widget.streakDays >= 3) {
      return {'days': 7 - widget.streakDays, 'next': 7, 'title': 'Smart Spender'};
    } else {
      return {'days': 3 - widget.streakDays, 'next': 3, 'title': 'Rookie Earner'};
    }
  }

  double _getProgressToNextLevel() {
    final milestones = [0, 3, 7, 14, 30, 60, 90];
    int currentLevel = 0;

    for (int i = 0; i < milestones.length - 1; i++) {
      if (widget.streakDays >= milestones[i] && widget.streakDays < milestones[i + 1]) {
        currentLevel = i;
        break;
      }
      if (widget.streakDays >= milestones[milestones.length - 1]) {
        return 1.0; // Max level
      }
    }

    final currentMilestone = milestones[currentLevel];
    final nextMilestone = milestones[currentLevel + 1];
    final progress = (widget.streakDays - currentMilestone) / (nextMilestone - currentMilestone);

    return progress.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final streakTitle = _getStreakTitle();
    final nextMilestone = _getNextMilestone();
    final progress = _getProgressToNextLevel();

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowOpacity = 0.3 + (_glowController.value * 0.2);

        return GestureDetector(
          onTap: () => context.push('/streak-detail', extra: widget.streakDays),
          child: Container(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 6, bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withValues(alpha: 0.7),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top row: Flaming streak counter on left, Title and emoji on right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Streak counter - Flaming circle animation (left)
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer flame glow
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        const Color(0xFFFF6B4A).withValues(alpha: 0.3),
                                        const Color(0xFFFF6B4A).withValues(alpha: 0.1),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                    ),
                                  ),
                                ),
                                // Main circle with flame border
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFF6B4A),
                                        Color(0xFFFF8C00),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF6B4A).withValues(alpha: 0.5),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${widget.streakDays}',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black45,
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Title and emoji (right)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white.withValues(alpha: 0.05),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              streakTitle.emoji,
                              style: const TextStyle(
                                fontSize: 17,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              streakTitle.title,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Streak title data class
class StreakTitle {
  final String title;
  final String emoji;
  final Color color;
  final LinearGradient gradient;

  StreakTitle({
    required this.title,
    required this.emoji,
    required this.color,
    required this.gradient,
  });
}
