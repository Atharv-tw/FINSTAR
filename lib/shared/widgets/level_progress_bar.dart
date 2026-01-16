import 'package:flutter/material.dart';
import '../../core/design_tokens.dart';
import '../../providers/user_provider.dart';

class LevelProgressBar extends StatelessWidget {
  final UserProfile user;

  const LevelProgressBar({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with real study progress from user data
    const double studyProgress = 0.65;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(20.0), // More rounded
        boxShadow: DesignTokens.elevation1(),
        border: Border.all(color: DesignTokens.backgroundSecondary, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level Progress
          Text(
            'LEVEL ${user.level}',
            style: const TextStyle(
              color: DesignTokens.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8), // Spacing between text and bar
          CustomPaint(
            size: const Size(double.infinity, 8),
            painter: _ProgressBarPainter(
              progress: user.xpProgress,
              gradient: DesignTokens.primaryGradient,
            ),
          ),

          const SizedBox(height: 16), // Spacing between sections

          // Study Progress
          const Text(
            'Study Progress',
            style: TextStyle(
              color: DesignTokens.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8), // Spacing between text and bar
          CustomPaint(
            size: const Size(double.infinity, 8),
            painter: _ProgressBarPainter(
              progress: studyProgress,
              gradient: DesignTokens.secondaryGradient,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  final double progress;
  final Gradient gradient;

  _ProgressBarPainter({required this.progress, required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    // Background track
    final trackPaint = Paint()
      ..color = DesignTokens.backgroundSecondary
      ..style = PaintingStyle.fill;
    final trackRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(6),
    );
    canvas.drawRRect(trackRRect, trackPaint);

    // Progress
    final progressWidth = size.width * progress;
    final progressRect = Rect.fromLTWH(0, 0, progressWidth, size.height);
    final progressPaint = Paint()..shader = gradient.createShader(progressRect);

    final progressRRect = RRect.fromRectAndCorners(
      progressRect,
      topLeft: const Radius.circular(6),
      bottomLeft: const Radius.circular(6),
      topRight: progress == 1.0 ? const Radius.circular(6) : Radius.zero,
      bottomRight: progress == 1.0 ? const Radius.circular(6) : Radius.zero,
    );
    canvas.drawRRect(progressRRect, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _ProgressBarPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.gradient != gradient;
  }
}
