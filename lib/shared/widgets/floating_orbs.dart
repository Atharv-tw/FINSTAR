import 'dart:math';
import 'package:flutter/material.dart';

/// Animated floating orbs background effect
class FloatingOrbs extends StatefulWidget {
  const FloatingOrbs({super.key});

  @override
  State<FloatingOrbs> createState() => _FloatingOrbsState();
}

class _FloatingOrbsState extends State<FloatingOrbs>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Orb> _orbs = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Generate random orbs
    for (int i = 0; i < 8; i++) {
      _orbs.add(Orb(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 80 + _random.nextDouble() * 120,
        speedX: (_random.nextDouble() - 0.5) * 0.3,
        speedY: (_random.nextDouble() - 0.5) * 0.3,
        color: _getRandomColor(),
      ));
    }

    _controller = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _controller.addListener(() {
      setState(() {
        for (var orb in _orbs) {
          orb.update();
        }
      });
    });
  }

  Color _getRandomColor() {
    final colors = [
      const Color(0xFFFF6B9D).withOpacity(0.25), // Pink
      const Color(0xFF9D6BFF).withOpacity(0.25), // Purple
      const Color(0xFF6BCDFF).withOpacity(0.25), // Blue
      const Color(0xFFFFB66B).withOpacity(0.25), // Orange
      const Color(0xFFFFF06B).withOpacity(0.22), // Yellow
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: OrbsPainter(_orbs),
      child: Container(),
    );
  }
}

class Orb {
  double x;
  double y;
  final double size;
  final double speedX;
  final double speedY;
  final Color color;

  Orb({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.color,
  });

  void update() {
    x += speedX * 0.001;
    y += speedY * 0.001;

    // Wrap around screen edges
    if (x > 1.2) x = -0.2;
    if (x < -0.2) x = 1.2;
    if (y > 1.2) y = -0.2;
    if (y < -0.2) y = 1.2;
  }
}

class OrbsPainter extends CustomPainter {
  final List<Orb> orbs;

  OrbsPainter(this.orbs);

  @override
  void paint(Canvas canvas, Size size) {
    for (var orb in orbs) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            orb.color,
            orb.color.withOpacity(0.0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: Offset(orb.x * size.width, orb.y * size.height),
            radius: orb.size,
          ),
        );

      canvas.drawCircle(
        Offset(orb.x * size.width, orb.y * size.height),
        orb.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
