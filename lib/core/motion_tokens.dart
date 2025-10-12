import 'package:flutter/animation.dart';

/// Motion design tokens for animations, transitions, and micro-interactions
class MotionTokens {
  MotionTokens._();

  // ===== DURATIONS =====

  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration slower = Duration(milliseconds: 800);

  // Specific durations
  static const Duration enter = Duration(milliseconds: 300);
  static const Duration exit = Duration(milliseconds: 200);
  static const Duration tap = Duration(milliseconds: 80);
  static const Duration reward = Duration(milliseconds: 600);
  static const Duration slide = Duration(milliseconds: 450);
  static const Duration confetti = Duration(milliseconds: 800);

  // ===== CURVES =====

  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeInOut = Curves.easeInOut;

  // Custom curves matching design spec
  static const Cubic easeOutQuart = Cubic(0.25, 1.0, 0.5, 1.0);
  static const Cubic easeOutQuad = Cubic(0.25, 0.46, 0.45, 0.94);
  static const Cubic easeInQuad = Cubic(0.55, 0.085, 0.68, 0.53);
  static const Cubic spring = Cubic(0.5, 1.25, 0.75, 1.0);
  static const Cubic bounceOut = Cubic(0.34, 1.56, 0.64, 1.0);

  // ===== SPRING PHYSICS =====

  // Default spring
  static const SpringDescription defaultSpring = SpringDescription(
    mass: 1.0,
    stiffness: 300,
    damping: 30,
  );

  // Gentle spring
  static const SpringDescription gentleSpring = SpringDescription(
    mass: 1.0,
    stiffness: 200,
    damping: 25,
  );

  // Bouncy spring
  static const SpringDescription bouncySpring = SpringDescription(
    mass: 1.0,
    stiffness: 400,
    damping: 20,
  );
}
