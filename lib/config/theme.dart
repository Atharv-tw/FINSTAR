import 'package:flutter/material.dart';
import '../core/design_tokens.dart';

/// Theme bridge for games - exports design tokens in AppTheme format
/// This allows games to use AppTheme.color syntax while maintaining
/// consistency with the app's design system
class AppTheme {
  // Background Colors
  static const Color backgroundColor = DesignTokens.backgroundPrimary;
  static const Color cardColor = DesignTokens.backgroundSecondary;
  static const Color cardSunken = Color(0xFF1A1A22);
  static const Color dividerColor = DesignTokens.textDisabled;

  // Primary & Secondary Colors
  static const Color primaryColor = DesignTokens.primarySolid;
  static const Color secondaryColor = DesignTokens.secondarySolid;

  // Semantic Colors
  static const Color successColor = DesignTokens.success;
  static const Color errorColor = DesignTokens.error;
  static const Color warningColor = DesignTokens.warning;
  static const Color infoColor = DesignTokens.info;

  // Accent Colors
  static const Color accentYellow = DesignTokens.accentSolid;
  static const Color streakColor = Color(0xFFFF914D);

  // Game-specific Colors
  static const Color gamesColor = Color(0xFF00D4FF);
  static const Color quizColor = Color(0xFF9B59B6);
  static const Color learnColor = Color(0xFF4AE56B);

  // Text Colors
  static const Color textPrimary = DesignTokens.textPrimary;
  static const Color textSecondary = DesignTokens.textSecondary;
  static const Color textDisabled = DesignTokens.textDisabled;

  // Gradients
  static const LinearGradient gradientPrimary = DesignTokens.primaryGradient;
  static const LinearGradient gradientSecondary = DesignTokens.secondaryGradient;
  static const LinearGradient gradientGold = DesignTokens.accentGradient;

  // Shadows
  static final List<BoxShadow> shadow3DSmall = DesignTokens.elevation2();
  static final List<BoxShadow> shadow3DMedium = DesignTokens.elevation3();
  static final List<BoxShadow> shadow3DLarge = DesignTokens.elevation4();
}
