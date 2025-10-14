import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design_tokens.dart';
import '../../core/motion_tokens.dart';

/// Circular progress indicator for XP/Level display with animations
class XpRing extends StatefulWidget {
  final int currentXp;
  final int xpForNextLevel;
  final int level;
  final double size;
  final double strokeWidth;
  final Gradient? gradient;
  final bool showLevel;
  final Color? levelTextColor;

  const XpRing({
    super.key,
    required this.currentXp,
    required this.xpForNextLevel,
    required this.level,
    this.size = 48,
    this.strokeWidth = 4,
    this.gradient,
    this.showLevel = true,
    this.levelTextColor,
  });

  @override
  State<XpRing> createState() => _XpRingState();
}

class _XpRingState extends State<XpRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: MotionTokens.reward,
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0,
      end: _calculateProgress(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: MotionTokens.easeOutQuart,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(XpRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentXp != widget.currentXp ||
        oldWidget.xpForNextLevel != widget.xpForNextLevel) {
      final oldProgress = oldWidget.currentXp / oldWidget.xpForNextLevel;
      final newProgress = _calculateProgress();

      _progressAnimation = Tween<double>(
        begin: oldProgress,
        end: newProgress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: MotionTokens.easeOutQuart,
      ));
      _controller.forward(from: 0);

      // Check for level-up
      if (widget.level > oldWidget.level) {
        _playLevelUpAnimation();
      }
    }
  }

  double _calculateProgress() {
    if (widget.xpForNextLevel == 0) return 0.0;
    return (widget.currentXp / widget.xpForNextLevel).clamp(0.0, 1.0);
  }

  void _playLevelUpAnimation() {
    HapticFeedback.heavyImpact();
    // TODO: Add sound effect: AudioService.play('victory_short.wav');
    // TODO: Add particle effects
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Progress ring
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: XpRingPainter(
                  progress: _progressAnimation.value,
                  strokeWidth: widget.strokeWidth,
                  gradient: widget.gradient ?? DesignTokens.primaryGradient,
                ),
              ),
              // Level number
              if (widget.showLevel)
                Text(
                  '${widget.level}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: widget.size * 0.4,
                    fontWeight: FontWeight.bold,
                    color: widget.levelTextColor ?? DesignTokens.textPrimary,
                    height: 1.0,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom painter for XP ring with gradient support
class XpRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Gradient gradient;

  XpRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background track
    final trackPaint = Paint()
      ..color = DesignTokens.textDisabled
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Draw progress arc with gradient
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradientPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -90 * (3.14159 / 180); // Start at top (12 o'clock)
      final sweepAngle = 360 * progress * (3.14159 / 180);

      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        gradientPaint,
      );
    }
  }

  @override
  bool shouldRepaint(XpRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
