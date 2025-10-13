import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design_tokens.dart';

class FinanceTilesSection extends StatelessWidget {
  const FinanceTilesSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Define your tile data with gradients matching play game cards
    final List<Map<String, dynamic>> tiles = [
      {
        'title': 'Money Basics',
        'image': 'assets/images/money_basics_icon.png',
        'gradientColors': [DesignTokens.primaryStart, DesignTokens.primaryEnd],
        'moduleId': 'money_basics',
      },
      {
        'title': 'Earning & Career',
        'image': 'assets/images/earning_career_icon.png',
        'gradientColors': [DesignTokens.secondaryStart, DesignTokens.secondaryEnd],
        'moduleId': 'earning_career',
      },
      {
        'title': 'Banking & Institutes',
        'image': 'assets/images/banking_icon.png',
        'gradientColors': [DesignTokens.accentStart, DesignTokens.accentEnd],
        'moduleId': 'banking',
      },
      {
        'title': 'Investing & Growth',
        'image': 'assets/images/investing_icon.png',
        'gradientColors': [const Color(0xFFFF6B9D), const Color(0xFFC06C84)],
        'moduleId': 'investing',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grid of 4 tiles
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tiles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columns
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1, // perfect square tiles
          ),
          itemBuilder: (context, index) {
            final tile = tiles[index];
            final gradientColors = tile['gradientColors'] as List<Color>;

            return GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                context.push('/module/${tile['moduleId']}');
              },
              child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.3),
                        Colors.white.withValues(alpha: 0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF2D7A3E).withValues(alpha: 0.6),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: const Color(0xFF4AE56B).withValues(alpha: 0.35),
                        blurRadius: 24,
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon without background
                      Image.asset(
                        tile['image'],
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 12),
                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          tile['title'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: DesignTokens.textDarkPrimary,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            );
          },
        ),
      ],
    );
  }
}
