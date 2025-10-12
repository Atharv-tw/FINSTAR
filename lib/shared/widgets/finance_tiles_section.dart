import 'dart:ui';
import 'package:flutter/material.dart';
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
      },
      {
        'title': 'Earning & Career',
        'image': 'assets/images/earning_career_icon.png',
        'gradientColors': [DesignTokens.secondaryStart, DesignTokens.secondaryEnd],
      },
      {
        'title': 'Banking & Institutes',
        'image': 'assets/images/banking_icon.png',
        'gradientColors': [DesignTokens.accentStart, DesignTokens.accentEnd],
      },
      {
        'title': 'Investing & Growth',
        'image': 'assets/images/investing_icon.png',
        'gradientColors': [const Color(0xFFFF6B9D), const Color(0xFFC06C84)],
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

            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0B0D).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: const Color.fromARGB(255, 233, 131, 165).withValues(alpha: 0.6),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon
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
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
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
