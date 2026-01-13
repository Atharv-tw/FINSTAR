import 'dart:math';
import 'package:flutter/material.dart';

class NatureBackground extends StatefulWidget {
  const NatureBackground({super.key});

  @override
  State<NatureBackground> createState() => _NatureBackgroundState();
}

class _NatureBackgroundState extends State<NatureBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<NatureParticle> _particles = [];
  final Random _random = Random();

  // Warm Light Colors (Retro/Pastel)
  final List<Color> _gradientColors = [
    const Color(0xFFFAFAF7), // Primary light background
    const Color(0xFFF5F5F0), // Slightly darker warm grey
    const Color(0xFFEBEBE5), // Muted warm grey
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 1), // Long duration for continuous loop
    )..repeat();

    // Initialize particles
    for (int i = 0; i < 20; i++) {
      _particles.add(_generateParticle());
    }

    _controller.addListener(() {
      setState(() {
        for (var particle in _particles) {
          particle.update();
          if (particle.isDead) {
            particle.reset(_random);
          }
        }
      });
    });
  }

  NatureParticle _generateParticle() {
    return DropletParticle(random: _random);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _gradientColors,
        ),
      ),
      child: CustomPaint(
        painter: NaturePainter(_particles),
        child: Container(),
      ),
    );
  }
}

abstract class NatureParticle {
  void update();
  void reset(Random random);
  bool get isDead;
  void draw(Canvas canvas, Size size);
}

class DropletParticle extends NatureParticle {
  double x;
  double y;
  double speedY;
  double size;
  double opacity;
  double fadeSpeed;

  DropletParticle({required Random random})
      : x = random.nextDouble(),
        y = random.nextDouble() * 0.5, // Start mostly in top half
        speedY = 0.001 + random.nextDouble() * 0.002,
        size = 2.0 + random.nextDouble() * 4.0,
        opacity = random.nextDouble() * 0.5,
        fadeSpeed = 0.0;

  @override
  void update() {
    y += speedY;
    // Fade out near bottom or randomly
    if (y > 0.8) opacity -= 0.005;
  }

  @override
  void reset(Random random) {
    x = random.nextDouble();
    y = -0.1;
    speedY = 0.001 + random.nextDouble() * 0.002;
    opacity = 0.3 + random.nextDouble() * 0.4;
  }

  @override
  bool get isDead => y > 1.0 || opacity <= 0;

  @override
  void draw(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    
    final paint = Paint()
      ..color = const Color(0xFFB6CFE4).withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x * size.width, y * size.height), this.size, paint);
  }
}

class NaturePainter extends CustomPainter {
  final List<NatureParticle> particles;

  NaturePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.draw(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
