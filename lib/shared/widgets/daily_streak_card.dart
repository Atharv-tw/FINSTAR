import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Daily streak counter card with fire icon and animations
class DailyStreakCard extends StatefulWidget {
  final int streakDays;

  const DailyStreakCard({
    super.key,
    this.streakDays = 0,
  });

  @override
  State<DailyStreakCard> createState() => _DailyStreakCardState();
}

class _DailyStreakCardState extends State<DailyStreakCard>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();

    // Sparkle animation
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Main card
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF6B4A).withValues(alpha: 0.35),
                        const Color(0xFFFF8E53).withValues(alpha: 0.35),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFF6B4A).withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: const Color(0xFFFF6B4A).withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated fire icon with rotating glow
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Rotating glow ring
                          Transform.rotate(
                            angle: _sparkleController.value * 2 * math.pi,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: SweepGradient(
                                  colors: [
                                    const Color(0xFFFF6B4A).withValues(alpha: 0.0),
                                    const Color(0xFFFF6B4A).withValues(alpha: 0.6),
                                    const Color(0xFFFF8E53).withValues(alpha: 0.6),
                                    const Color(0xFFFF6B4A).withValues(alpha: 0.0),
                                  ],
                                  stops: const [0.0, 0.3, 0.7, 1.0],
                                ),
                              ),
                            ),
                          ),
                          // Fire icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF6B4A), Color(0xFFFF8E53)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF6B4A).withValues(alpha: 0.6),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.local_fire_department_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Streak text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Color(0xFFFFFFFF), Color(0xFFFFE4D6)],
                                ).createShader(bounds),
                                child: Text(
                                  '${widget.streakDays}',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Day Streak',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                'Keep it going!',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '🔥',
                                style: TextStyle(
                                  fontSize: 10,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Floating sparkles
            ..._buildSparkles(),
          ],
        );
      },
    );
  }

  List<Widget> _buildSparkles() {
    return List.generate(3, (index) {
      final angle = (index * 120) + (_sparkleController.value * 360);
      final radians = angle * math.pi / 180;
      final distance = 35.0;
      final x = math.cos(radians) * distance;
      final y = math.sin(radians) * distance;

      final opacity = (math.sin(_sparkleController.value * 2 * math.pi + index) + 1) / 2;

      return Positioned(
        left: 20 + x,
        top: 20 + y,
        child: Opacity(
          opacity: opacity * 0.7,
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
