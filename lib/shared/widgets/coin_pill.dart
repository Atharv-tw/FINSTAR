import 'package:flutter/material.dart';
import '../../core/design_tokens.dart';
import '../../core/app_theme.dart';

/// Coin display pill widget for showing coin balance with progress.
class CoinPill extends StatelessWidget {
  final int coins;
  final double height;
  final VoidCallback? onTap;
  final double progress; // Added for progress display

  const CoinPill({
    super.key,
    required this.coins,
    this.height = 30, // Default height adjusted
    this.onTap,
    this.progress = 0.6, // Mock progress, can be changed
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _CoinPillPainter(
          progress: progress,
          pillHeight: height,
        ),
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingSM, // Reduced width
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Coin icon
              Container(
                width: height * 0.7,
                height: height * 0.7,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFE082), Color(0xFFFFC107).withOpacity(0.5)], // Gold icon with reduced orange opacity
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.monetization_on,
                  color: Colors.white.withOpacity(0.8),
                  size: height * 0.45,
                ),
              ),
              const SizedBox(width: DesignTokens.spacingXS), // Reduced spacing
              // Coin count
              Text(
                coins.toString(),
                style: AppTheme.numericStyle(
                  fontSize: height * 0.45,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF393027), // Brown color for text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoinPillPainter extends CustomPainter {
  final double progress;
  final double pillHeight;

  _CoinPillPainter({required this.progress, required this.pillHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final goldGradient = LinearGradient(
      colors: [Color(0xFFFFD700), Color(0xFFFFAA00).withOpacity(0.5)], // Gold background with reduced orange opacity
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final pillRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final pillRRect = RRect.fromRectAndRadius(pillRect, Radius.circular(pillHeight / 2));

    // Draw the background
    final backgroundPaint = Paint()..shader = goldGradient.createShader(pillRect);
    canvas.drawRRect(pillRRect, backgroundPaint);

    // Draw the progress
    final progressWidth = size.width * progress;
    final progressRect = Rect.fromLTWH(0, 0, progressWidth, size.height);
    final progressRRect = RRect.fromRectAndRadius(progressRect, Radius.circular(pillHeight / 2));

    final progressGradient = LinearGradient(
      colors: [
        const Color(0xFFDAA520).withOpacity(0.8), // Darker gold
        const Color(0xFFB8860B).withOpacity(0.8) // Even darker gold
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final progressPaint = Paint()..shader = progressGradient.createShader(progressRect);
    canvas.drawRRect(progressRRect, progressPaint);

    // Draw the border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(pillRRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _CoinPillPainter ||
        oldDelegate.progress != progress ||
        oldDelegate.pillHeight != pillHeight;
  }
}