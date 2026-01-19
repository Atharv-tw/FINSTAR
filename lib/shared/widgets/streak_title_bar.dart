import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Streak-based title bar that displays user achievement level
class StreakTitleBar extends StatefulWidget {
  final int streakDays;
  final String? userPhotoUrl;
  final int currentXp;
  final int nextLevelXp;

  const StreakTitleBar({
    super.key,
    this.streakDays = 0,
    this.userPhotoUrl,
    this.currentXp = 0,
    this.nextLevelXp = 1000,
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
        color: const Color(0xFF5F8724), // Brand Green
        gradient: const LinearGradient(
          colors: [Color(0xFF5F8724), Color(0xFF4A6A1C)],
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
        emoji: '',
        color: const Color(0xFF95A5A6), // Gray
        gradient: const LinearGradient(
          colors: [Color(0xFF95A5A6), Color(0xFF7F8C8D)],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final streakTitle = _getStreakTitle();

    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAF7),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4.0),
            const SizedBox(height: 6),
            // Top row: User Profile (Left) & Title/Emoji (Right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // User Profile Button (Replaces "0" streak counter)
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: AnimatedBuilder(
                    animation: _glowController,
                    builder: (context, child) {
                      return Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF5F8724), // Brand Green border
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5F8724).withValues(
                                alpha: 0.1,
                              ),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFFF3F3ED),
                      backgroundImage: widget.userPhotoUrl != null
                          ? NetworkImage(widget.userPhotoUrl!)
                          : null,
                      child: widget.userPhotoUrl == null
                          ? const Icon(Icons.person, color: Color(0xFF393027))
                          : null,
                    ),
                  ),
                ),

                // Title and emoji (right)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF393027).withValues(alpha: 0.04),
                    border: Border.all(
                      color: const Color(0xFF393027).withValues(alpha: 0.08),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (streakTitle.emoji.isNotEmpty) ...[
                        Text(
                          streakTitle.emoji,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        streakTitle.title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF393027),
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
