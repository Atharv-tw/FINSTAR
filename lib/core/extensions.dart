import 'package:flutter/material.dart';

extension ColorExtension on Color {
  /// Returns a new color with the given alpha value.
  Color withValues({int? red, int? green, int? blue, int? alpha}) {
    return Color.fromARGB(
      alpha ?? this.alpha,
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
    );
  }
}
