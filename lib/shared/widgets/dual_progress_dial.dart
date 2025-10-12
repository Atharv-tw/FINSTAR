import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/design_tokens.dart';

/// Circular dial that shows two progress rings:
/// - Outer ring: Level progress (XP)
/// - Inner ring: Finance journey progress (modules studied)
class DualProgressDial extends StatefulWidget {
  final int currentXp;
  final int xpForNextLevel;
  final int level;
  final double studyProgress; // 0.0 to 1.0
  final double size;

  const DualProgressDial({
    super.key,
    required this.currentXp,
    required this.xpForNextLevel,
    required this.level,
    required this.studyProgress,
    this.size = 160,
  });

  @override
  State<DualProgressDial> createState() => _DualProgressDialState();
}

class _DualProgressDialState extends State<DualProgressDial>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final xpProgress = widget.currentXp / widget.xpForNextLevel;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _DualProgressDialPainter(
              levelProgress: xpProgress * _animation.value,
              studyProgress: widget.studyProgress * _animation.value,
              level: widget.level,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Level number
                  Text(
                    'Level ${widget.level}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // XP text
                  Text(
                    '${widget.currentXp} / ${widget.xpForNextLevel}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Study progress percentage
                  Text(
                    '${(widget.studyProgress * 100).toInt()}%',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6FD4D4),
                    ),
                  ),
                  Text(
                    'Journey',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DualProgressDialPainter extends CustomPainter {
  final double levelProgress;
  final double studyProgress;
  final int level;

  _DualProgressDialPainter({
    required this.levelProgress,
    required this.studyProgress,
    required this.level,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer ring (Level Progress - XP)
    _drawProgressRing(
      canvas: canvas,
      center: center,
      radius: radius - 8,
      strokeWidth: 12,
      progress: levelProgress,
      gradient: DesignTokens.primaryGradient,
      backgroundColor: Colors.white.withValues(alpha: 0.1),
    );

    // Inner ring (Study Progress - Journey)
    _drawProgressRing(
      canvas: canvas,
      center: center,
      radius: radius - 28,
      strokeWidth: 10,
      progress: studyProgress,
      gradient: DesignTokens.secondaryGradient,
      backgroundColor: Colors.white.withValues(alpha: 0.08),
    );
  }

  void _drawProgressRing({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double strokeWidth,
    required double progress,
    required LinearGradient gradient,
    required Color backgroundColor,
  }) {
    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final sweepAngle = 2 * pi * progress;

      // Create gradient shader
      final shader = gradient.createShader(rect);
      final progressPaint = Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Draw arc starting from top (-pi/2) going clockwise
      canvas.drawArc(
        rect,
        -pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );

      // Add glow effect
      final glowPaint = Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        rect,
        -pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_DualProgressDialPainter oldDelegate) {
    return oldDelegate.levelProgress != levelProgress ||
        oldDelegate.studyProgress != studyProgress;
  }
}
