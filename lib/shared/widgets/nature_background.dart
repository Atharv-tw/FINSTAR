import 'package:flutter/material.dart';

class NatureBackground extends StatelessWidget {
  const NatureBackground({super.key});

  // Warm Light Colors (Retro/Pastel)
  final List<Color> _gradientColors = const [
    Color(0xFFFAFAF7), // Primary light background
    Color(0xFFF5F5F0), // Slightly darker warm grey
    Color(0xFFEBEBE5), // Muted warm grey
  ];

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
    );
  }
}
