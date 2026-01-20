import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/design_tokens.dart';

/// Quick stats row showing games played, lessons, achievements
class QuickStatsRow extends StatelessWidget {
  final int gamesPlayed;
  final int lessonsCompleted;
  final int achievementsUnlocked;

  const QuickStatsRow({
    super.key,
    this.gamesPlayed = 0,
    this.lessonsCompleted = 0,
    this.achievementsUnlocked = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _StatPill(
            icon: Icons.sports_esports_rounded,
            value: gamesPlayed,
            label: 'Games',
            gradientColors: const [Color(0xFF2E5BFF), Color(0xFF00D4FF)],
          ),
          const SizedBox(width: 12),
          _StatPill(
            icon: Icons.flash_on_rounded,
            value: lessonsCompleted,
            label: 'Points',
            gradientColors: const [Color(0xFF5F8724), Color(0xFF4A6A1C)],
          ),
          const SizedBox(width: 12),
          _StatPill(
            icon: Icons.emoji_events_rounded,
            value: achievementsUnlocked,
            label: 'Badges',
            gradientColors: const [Color(0xFFFFD45D), Color(0xFFFF914D)],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final List<Color> gradientColors;

  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              // Stats
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: DesignTokens.textDarkPrimary,
                      height: 1,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: DesignTokens.textDarkSecondary,
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
