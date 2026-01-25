import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedGameBackground extends StatefulWidget {
  const AnimatedGameBackground({super.key});

  @override
  State<AnimatedGameBackground> createState() => _AnimatedGameBackgroundState();
}

class _AnimatedGameBackgroundState extends State<AnimatedGameBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  List<_MovingShape>? _shapes;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Initialize shapes here with the correct size
      _shapes ??= List.generate(30, (_) => _MovingShape(_random, constraints.biggest));

      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _BackgroundPainter(_controller.value, _shapes!),
            child: Container(),
          );
        },
      );
    });
  }
}

class _BackgroundPainter extends CustomPainter {
  final double _animationValue;
  final List<_MovingShape> _shapes;

  _BackgroundPainter(this._animationValue, this._shapes);

  @override
  void paint(Canvas canvas, Size size) {
    for (var shape in _shapes) {
      final offset = shape.getOffset(_animationValue, size);
      final paint = Paint()..color = shape.color.withOpacity(0.5);
      canvas.drawCircle(offset, shape.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) {
    return oldDelegate._animationValue != _animationValue;
  }
}

class _MovingShape {
  final Random _random;
  final Color color;
  final double size;
  final double speed;
  final double initialX;
  final double initialY;

  _MovingShape(this._random, Size canvasSize)
      : color = Colors.white.withOpacity(_random.nextDouble() * 0.2 + 0.05),
        size = _random.nextDouble() * 20 + 10,
        speed = _random.nextDouble() * 50 + 20,
        initialX = _random.nextDouble() * canvasSize.width,
        initialY = _random.nextDouble() * canvasSize.height;

  Offset getOffset(double animationValue, Size canvasSize) {
    final double dx = (initialX + animationValue * speed) % canvasSize.width;
    final double dy = (initialY + animationValue * speed * 0.5) % canvasSize.height;
    return Offset(dx, dy);
  }
}
