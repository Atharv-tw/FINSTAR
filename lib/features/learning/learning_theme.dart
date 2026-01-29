import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LearningTheme {
  // Color Palette
  static const Color olivine = Color(0xFF9BAD50);
  static const Color columbia = Color(0xFFB6CFE4);
  static const Color vanDyke = Color(0xFF393027);
  static const Color forest = Color(0xFF0F190C);
  static const Color white = Color(0xFFFFFFFF);

  // Text Styles
  static final TextStyle headline1 = GoogleFonts.poppins(
    color: white,
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle headline2 = GoogleFonts.poppins(
    color: white,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle bodyText1 = GoogleFonts.poppins(
    color: columbia,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.6,
  );

  static final TextStyle bodyText2 = GoogleFonts.poppins(
    color: columbia.withOpacity(0.8),
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static final TextStyle button = GoogleFonts.poppins(
    color: white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle caption = GoogleFonts.poppins(
    color: columbia.withOpacity(0.7),
    fontSize: 12,
  );

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [forest, vanDyke],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
