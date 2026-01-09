import 'dart:math' as math;
import 'package:flutter/material.dart';

class LoginBackground extends StatefulWidget {
  const LoginBackground({super.key});

  @override
  State<LoginBackground> createState() => _LoginBackgroundState();
}

class _LoginBackgroundState extends State<LoginBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Calm, premium fintech colors - Light Dark Blue Palette
  final Color _color1 = const Color(0xFF141E30); // Dark Midnight Blue
  final Color _color2 = const Color(0xFF1B2E44); // Deep Navy Blue
  final Color _color3 = const Color(0xFF243B55); // Light Dark Blue

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_color1, _color2, _color3],
            ),
          ),
        ),
        
        // Animated subtle waves/shapes
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _DriftingShapesPainter(
                animationValue: _controller.value,
                color: Colors.white.withValues(alpha: 0.03), // Very subtle
              ),
              size: Size.infinite,
            );
          },
        ),
        
        // Vignette for focus
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.3),
              ],
              stops: const [0.6, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

class _DriftingShapesPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  _DriftingShapesPainter({
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Slow diagonal drift calculation
    final dx = animationValue * 50;
    final dy = animationValue * 30;

    // Shape 1: Large soft circle top-left
    canvas.drawCircle(
      Offset(size.width * 0.2 + dx, size.height * 0.3 + dy),
      size.width * 0.4,
      paint,
    );

    // Shape 2: Large soft circle bottom-right
    canvas.drawCircle(
      Offset(size.width * 0.8 - dx, size.height * 0.7 - dy),
      size.width * 0.5,
      paint,
    );

    // Shape 3: Crossing element
    final path = Path();
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.5 + dx, 
      size.height * 0.5 + dy, 
      size.width, 
      size.height * 0.8
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    // Use a separate paint for the wave to be even more subtle
    final wavePaint = Paint()
      ..color = color.withValues(alpha: color.a * 0.5)
      ..style = PaintingStyle.fill;
      
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant _DriftingShapesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
