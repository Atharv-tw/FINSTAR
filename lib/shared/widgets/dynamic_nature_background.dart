import 'package:flutter/material.dart';
import 'dart:math';

class DynamicNatureBackground extends StatelessWidget {
  const DynamicNatureBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF81C784), // Light Green
            Color(0xFFA5D6A7), // Lighter Green
          ],
        ),
      ),
      child: const Stack(
        children: [
          HillsPainter(),
          FallingLeavesAnimation(),
        ],
      ),
    );
  }
}

class HillsPainter extends StatelessWidget {
  const HillsPainter({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HillsPainter(),
      child: Container(),
    );
  }
}

class _HillsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // First hill (background)
    paint.color = Colors.green.shade400;
    final path1 = Path();
    path1.moveTo(0, size.height * 0.7);
    path1.quadraticBezierTo(size.width * 0.25, size.height * 0.6, size.width * 0.5, size.height * 0.7);
    path1.quadraticBezierTo(size.width * 0.75, size.height * 0.8, size.width, size.height * 0.7);
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint);

    // Second hill (foreground)
    paint.color = Colors.green.shade600;
    final path2 = Path();
    path2.moveTo(0, size.height * 0.8);
    path2.quadraticBezierTo(size.width * 0.3, size.height * 0.7, size.width * 0.6, size.height * 0.8);
    path2.quadraticBezierTo(size.width * 0.8, size.height * 0.9, size.width, size.height * 0.8);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class FallingLeavesAnimation extends StatefulWidget {
  const FallingLeavesAnimation({super.key});

  @override
  _FallingLeavesAnimationState createState() => _FallingLeavesAnimationState();
}

class _FallingLeavesAnimationState extends State<FallingLeavesAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Leaf> _leaves = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    for (int i = 0; i < 15; i++) {
      _leaves.add(Leaf(random: _random));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _LeavesPainter(
              leaves: _leaves,
              controllerValue: _controller.value,
              size: constraints,
            ),
            child: Container(),
          );
        },
      );
    });
  }
}

class _LeavesPainter extends CustomPainter {
  final List<Leaf> leaves;
  final double controllerValue;
  final BoxConstraints size;

  _LeavesPainter({required this.leaves, required this.controllerValue, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var leaf in leaves) {
      paint.color = leaf.color;
      final y = (leaf.startY * size.maxHeight + (controllerValue * leaf.speed)) % (size.maxHeight + leaf.size);
      final x = leaf.startX * size.maxWidth;

      canvas.drawCircle(Offset(x, y), leaf.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Leaf {
  final double startX;
  final double startY;
  final double size;
  final double speed;
  final Color color;

  Leaf({required Random random})
      : startX = random.nextDouble(),
        startY = random.nextDouble(),
        size = random.nextDouble() * 4 + 2,
        speed = random.nextDouble() * 30 + 20,
        color = Colors.yellow.withOpacity(random.nextDouble() * 0.5 + 0.3);
}
