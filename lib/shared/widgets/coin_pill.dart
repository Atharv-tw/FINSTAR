import 'package:flutter/material.dart';
import '../../core/design_tokens.dart';
import '../../core/app_theme.dart';

/// Coin display pill widget for showing coin balance
class CoinPill extends StatelessWidget {
  final int coins;
  final double height;
  final VoidCallback? onTap;

  const CoinPill({
    super.key,
    required this.coins,
    this.height = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingMD,
        ),
        decoration: BoxDecoration(
          gradient: DesignTokens.accentGradient,
          borderRadius: BorderRadius.circular(height / 2),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            ...DesignTokens.elevation2(),
            ...DesignTokens.accentGlow(0.3),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Coin icon
            Container(
              width: height * 0.6,
              height: height * 0.6,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '🪙',
                  style: TextStyle(fontSize: height * 0.4),
                ),
              ),
            ),
            const SizedBox(width: DesignTokens.spacingSM),
            // Coin count
            Text(
              coins.toString(),
              style: AppTheme.numericStyle(
                fontSize: height * 0.4,
                fontWeight: FontWeight.bold,
                color: DesignTokens.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
