import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design_tokens.dart';

/// Featured hero card for daily challenge or recommended content
class FeaturedHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const FeaturedHeroCard({
    super.key,
    this.title = 'Fun Quest',
    this.subtitle = 'Complete today\'s quiz to earn bonus XP!',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap?.call();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 140, // Slightly reduced height
            decoration: BoxDecoration(
              gradient: DesignTokens.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: DesignTokens.textPrimary.withValues(alpha: 0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.primarySolid.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Large Star Overlay (Floating effect)
                Positioned(
                  right: -80,
                  top: -60,
                  child: Transform.rotate(
                    angle: -0.2, // Tilted
                    child: Icon(
                      Icons.star_rounded,
                      size: 300, // Bigger
                      color: Colors.white.withValues(alpha: 0.15), // Increased opacity for better contrast
                    ),
                  ),
                ),

                // Hero image on right side - SCALED DOWN
                Positioned(
                  right: 10,
                  bottom: -3, // Moved down by 3 pixels
                  child: Image.asset(
                    'assets/images/dailychallengepanda.png',
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
                // Text content on left
                Positioned(
                  left: 20,
                  top: 12,
                  right: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF393027), // Dark Cocoa color
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4), // Reduced from 8
                      // Subtitle
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.3,
                        ),
                        maxLines: 2, // Reduced from 3 to save space
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8), // Reduced from 12
                      // CTA button
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF393027), // Dark Cocoa background
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'START NOW',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.white, // White text
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
