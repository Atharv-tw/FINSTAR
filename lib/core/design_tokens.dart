import 'package:flutter/material.dart';

/// Design tokens for FINSTAR app based on Nixtio-inspired design system
class DesignTokens {
  DesignTokens._();

  // ===== COLORS =====

  // Primary
  static const Color primaryStart = Color(0xFF2E5BFF);
  static const Color primaryEnd = Color(0xFF00D4FF);
  static const Color primarySolid = Color(0xFF2E5BFF);

  // Secondary
  static const Color secondaryStart = Color(0xFFA9FF68);
  static const Color secondaryEnd = Color(0xFF4AE56B);
  static const Color secondarySolid = Color(0xFFA9FF68);

  // Accent
  static const Color accentStart = Color(0xFFFFD45D);
  static const Color accentEnd = Color(0xFFFF914D);
  static const Color accentSolid = Color(0xFFFFD45D);

  // Background
  static const Color backgroundPrimary = Color(0xFF0B0B0D);
  static const Color backgroundSecondary = Color(0xFF15151A);

  // Surface
  static const Color surfaceCard = Color(0x0B0B0B0D); // rgba(11, 11, 13, 0.7)
  static const Color surfaceCardLight = Color(0x1AFFFFFF); // rgba(255, 255, 255, 0.1)
  static const Color surfaceOverlay = Color(0x80000000); // rgba(0, 0, 0, 0.5)

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // rgba(255, 255, 255, 0.7)
  static const Color textTertiary = Color(0x80FFFFFF); // rgba(255, 255, 255, 0.5)
  static const Color textDisabled = Color(0x4DFFFFFF); // rgba(255, 255, 255, 0.3)

  // Semantic
  static const Color success = Color(0xFF2FD176);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFFD45D);
  static const Color info = Color(0xFF00D4FF);

  // ===== GRADIENTS =====

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryStart, primaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryStart, secondaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentStart, accentEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundPrimary, backgroundSecondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient diagonalGradient = LinearGradient(
    colors: [accentStart, secondaryStart, primaryStart],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Game-specific gradients
  static const LinearGradient needsGradient = LinearGradient(
    colors: [Color(0xFFFF3B30), Color(0xFFFF6B66)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient wantsGradient = LinearGradient(
    colors: [Color(0xFFFFD45D), Color(0xFFFFB84D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient savingsGradient = LinearGradient(
    colors: [Color(0xFF2FD176), Color(0xFF6FE5A6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient investGradient = LinearGradient(
    colors: [Color(0xFF2E5BFF), Color(0xFF5E8BFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ===== SPACING =====

  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  static const double spacingXXXL = 64.0;
  static const double spacingGrid = 8.0;
  static const double spacingSafeArea = 24.0;
  static const double spacingCardGap = 16.0;
  static const double spacingSectionGap = 32.0;

  // ===== CORNER RADIUS =====

  static const double radiusXS = 8.0;
  static const double radiusSM = 12.0;
  static const double radiusMD = 24.0;
  static const double radiusLG = 40.0;
  static const double radiusPill = 9999.0;

  static const BorderRadius borderRadiusXS = BorderRadius.all(Radius.circular(radiusXS));
  static const BorderRadius borderRadiusSM = BorderRadius.all(Radius.circular(radiusSM));
  static const BorderRadius borderRadiusMD = BorderRadius.all(Radius.circular(radiusMD));
  static const BorderRadius borderRadiusLG = BorderRadius.all(Radius.circular(radiusLG));
  static const BorderRadius borderRadiusPill = BorderRadius.all(Radius.circular(radiusPill));

  // ===== SHADOWS =====

  static List<BoxShadow> elevation1() => [
        BoxShadow(
          offset: const Offset(0, 2),
          blurRadius: 4,
          spreadRadius: 0,
          color: Colors.black.withValues(alpha: 0.1),
        ),
      ];

  static List<BoxShadow> elevation2() => [
        BoxShadow(
          offset: const Offset(0, 4),
          blurRadius: 8,
          spreadRadius: 0,
          color: Colors.black.withValues(alpha: 0.15),
        ),
      ];

  static List<BoxShadow> elevation3() => [
        BoxShadow(
          offset: const Offset(0, 8),
          blurRadius: 16,
          spreadRadius: 0,
          color: Colors.black.withValues(alpha: 0.2),
        ),
      ];

  static List<BoxShadow> elevation4() => [
        BoxShadow(
          offset: const Offset(0, 12),
          blurRadius: 24,
          spreadRadius: 0,
          color: Colors.black.withValues(alpha: 0.25),
        ),
      ];

  static List<BoxShadow> elevation5() => [
        BoxShadow(
          offset: const Offset(0, 16),
          blurRadius: 32,
          spreadRadius: 0,
          color: Colors.black.withValues(alpha: 0.3),
        ),
      ];

  static List<BoxShadow> elevation6() => [
        BoxShadow(
          offset: const Offset(0, 24),
          blurRadius: 48,
          spreadRadius: 0,
          color: Colors.black.withValues(alpha: 0.4),
        ),
      ];

  // Glow shadows
  static List<BoxShadow> primaryGlow([double opacity = 0.4]) => [
        BoxShadow(
          offset: Offset.zero,
          blurRadius: 24,
          spreadRadius: 0,
          color: primaryStart.withValues(alpha: opacity),
        ),
      ];

  static List<BoxShadow> secondaryGlow([double opacity = 0.4]) => [
        BoxShadow(
          offset: Offset.zero,
          blurRadius: 24,
          spreadRadius: 0,
          color: secondaryStart.withValues(alpha: opacity),
        ),
      ];

  static List<BoxShadow> accentGlow([double opacity = 0.4]) => [
        BoxShadow(
          offset: Offset.zero,
          blurRadius: 24,
          spreadRadius: 0,
          color: accentStart.withValues(alpha: opacity),
        ),
      ];

  // Combined elevation + glow
  static List<BoxShadow> elevationWithGlow(int level, Color glowColor, [double glowOpacity = 0.4]) {
    List<BoxShadow> shadows;
    switch (level) {
      case 1:
        shadows = elevation1();
        break;
      case 2:
        shadows = elevation2();
        break;
      case 3:
        shadows = elevation3();
        break;
      case 4:
        shadows = elevation4();
        break;
      case 5:
        shadows = elevation5();
        break;
      case 6:
        shadows = elevation6();
        break;
      default:
        shadows = elevation3();
    }
    return [
      ...shadows,
      BoxShadow(
        offset: Offset.zero,
        blurRadius: 24,
        spreadRadius: 0,
        color: glowColor.withValues(alpha: glowOpacity),
      ),
    ];
  }

  // ===== BLUR =====

  static const double blurLight = 8.0;
  static const double blurMedium = 16.0;
  static const double blurHeavy = 24.0;
  static const double blurGlassmorphic = 24.0;

  // ===== ICON SIZES =====

  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;
  static const double iconXXL = 64.0;

  // ===== HIT AREAS =====

  static const double hitAreaMinimum = 48.0;
  static const double hitAreaComfortable = 56.0;
  static const double hitAreaLarge = 64.0;
}
