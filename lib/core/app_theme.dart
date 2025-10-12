import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';

/// App theme configuration following FINSTAR design system
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: DesignTokens.backgroundPrimary,

      // Color scheme
      colorScheme: ColorScheme.dark(
        primary: DesignTokens.primarySolid,
        secondary: DesignTokens.secondarySolid,
        tertiary: DesignTokens.accentSolid,
        error: DesignTokens.error,
        surface: DesignTokens.backgroundSecondary,
        onPrimary: DesignTokens.textPrimary,
        onSecondary: DesignTokens.textPrimary,
        onSurface: DesignTokens.textPrimary,
        onError: DesignTokens.textPrimary,
      ),

      // Typography
      textTheme: TextTheme(
        // Display - Poppins Bold 28px
        displayLarge: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: DesignTokens.textPrimary,
          height: 1.2,
        ),
        // Headline 1 - Poppins Bold 24px
        headlineLarge: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: DesignTokens.textPrimary,
          height: 1.2,
        ),
        // Headline 2 - Poppins SemiBold 20px
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: DesignTokens.textPrimary,
          height: 1.2,
        ),
        // Headline 3 - Poppins SemiBold 18px
        headlineSmall: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: DesignTokens.textPrimary,
          height: 1.5,
        ),
        // Body - Inter Regular 14px
        bodyLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: DesignTokens.textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: DesignTokens.textSecondary,
          height: 1.5,
        ),
        // Caption - Inter Regular 12px
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: DesignTokens.textSecondary,
          height: 1.5,
        ),
        // Label - Inter Medium 14px
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: DesignTokens.textPrimary,
          height: 1.5,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: DesignTokens.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.borderRadiusLG,
          side: BorderSide(
            color: DesignTokens.textDisabled,
            width: 1,
          ),
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.primarySolid,
          foregroundColor: DesignTokens.textPrimary,
          elevation: 4,
          shadowColor: DesignTokens.primaryStart.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingLG,
            vertical: DesignTokens.spacingMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: DesignTokens.borderRadiusSM,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
          minimumSize: const Size(0, DesignTokens.hitAreaMinimum),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DesignTokens.textSecondary,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingMD,
            vertical: DesignTokens.spacingSM,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
          minimumSize: const Size(0, DesignTokens.hitAreaMinimum),
        ),
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: DesignTokens.textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: DesignTokens.textPrimary,
          size: DesignTokens.iconMD,
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: DesignTokens.textPrimary,
        size: DesignTokens.iconMD,
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: DesignTokens.textDisabled,
        thickness: 1,
        space: DesignTokens.spacingMD,
      ),
    );
  }

  // Numeric text style (Space Mono)
  static TextStyle numericStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
  }) {
    return GoogleFonts.spaceMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? DesignTokens.textPrimary,
      height: 1.5,
    );
  }

  // Button styles
  static TextStyle buttonTextStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: DesignTokens.textPrimary,
      height: 1.5,
    );
  }
}
