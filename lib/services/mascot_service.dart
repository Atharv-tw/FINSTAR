import 'package:flutter/material.dart';

/// Service to handle mascot interactions and feedback
/// This provides visual feedback during quiz games
class MascotService {
  // Singleton pattern
  static final MascotService _instance = MascotService._internal();
  factory MascotService() => _instance;
  MascotService._internal();

  /// Shows mascot feedback overlay during quiz
  void showQuizFeedback(BuildContext context, bool isCorrect) {
    // Show a simple snackbar for now
    // Can be enhanced with animated mascot overlays later
    final message = isCorrect ? '🎉 Correct!' : '💭 Keep trying!';
    final color = isCorrect ? Colors.green : Colors.orange;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Shows mascot celebration for achievements
  void showCelebration(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.purple,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
