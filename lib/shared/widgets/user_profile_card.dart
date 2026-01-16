import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design_tokens.dart';
import '../../providers/user_provider.dart';

class UserProfileCard extends StatelessWidget {
  final UserProfile user;

  const UserProfileCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 195, // Decreased height
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7db5e3), // New lighter blue
            const Color(0xFF6B9EC8), // New darker blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B9EC8).withOpacity(0.5), // Updated shadow color
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorations
          Stack(
            children: [
              // Partial Circle Decoration
              Positioned(
                bottom: -130, // Adjusted size and offset
                right: -130, // Adjusted size and offset
                child: Container(
                  width: 260, // Adjusted width
                  height: 260, // Adjusted height
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Tilted Bars for Shiny Effect
              Positioned(
                top: -90, // Adjusted position
                left: -90, // Adjusted position
                child: Transform.rotate(
                  angle: -math.pi / 4,
                  child: Container(
                    width: 300,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.5],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Transform.rotate(
                  angle: -math.pi / 4,
                  child: Container(
                    width: 300,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.5],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 90, // Adjusted position
                left: 90, // Adjusted position
                child: Transform.rotate(
                  angle: -math.pi / 4,
                  child: Container(
                    width: 300,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.5],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20.0), // Decreased padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chip
                    SizedBox(
                      width: 50,
                      height: 35,
                      child: CustomPaint(
                        painter: _ChipPainter(),
                      ),
                    ),
                    Text(
                      'FINSTAR',
                      style: GoogleFonts.orbitron(
                        color: DesignTokens.textPrimary,
                        fontSize: 20, // Decreased font size
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 2,
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // XP and Level Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${user.xp} XP',
                      style: GoogleFonts.orbitron(
                        color: DesignTokens.textPrimary.withOpacity(0.9),
                        fontSize: 24, // Decreased font size for XP
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'LVL ${user.level}', // Added Level
                      style: GoogleFonts.orbitron(
                        color: DesignTokens.textPrimary.withOpacity(0.9),
                        fontSize: 14, // Decreased font size for Level
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                // Cardholder Name & Streaks
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CARD HOLDER',
                          style: TextStyle(
                            color: DesignTokens.textPrimary.withOpacity(0.7),
                            fontSize: 9, // Decreased font size
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.displayName.toUpperCase(),
                          style: GoogleFonts.orbitron(
                            color: DesignTokens.textPrimary,
                            fontSize: 12, // Decreased font size
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'STREAKS',
                          style: TextStyle(
                            color: DesignTokens.textPrimary.withOpacity(0.7),
                            fontSize: 9, // Decreased font size
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${user.streakDays} DAYS',
                          style: GoogleFonts.orbitron(
                            color: DesignTokens.textPrimary,
                            fontSize: 12, // Decreased font size
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE0B971)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(6),
      ),
      paint,
    );

    final linePaint = Paint()
      ..color = const Color(0xFFFDD835).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw some lines on the chip
    canvas.drawLine(Offset(size.width * 0.2, 0), Offset(size.width * 0.2, size.height), linePaint);
    canvas.drawLine(Offset(size.width * 0.8, 0), Offset(size.width * 0.8, size.height), linePaint);
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
