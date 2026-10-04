import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors inspired by MoES/IMD & Atmospheric themes
  static const Color primaryNavy = Color(0xFF0F172A); // Slate 900
  static const Color surfaceNavy = Color(0xFF1E293B); // Slate 800
  static const Color cardNavy = Color(0xFF1E293B);
  static const Color cardBorder = Color(0xFF334155);
  
  static const Color accentCyan = Color(0xFF38BDF8); // Sky blue
  static const Color accentTeal = Color(0xFF2DD4BF); // Teal
  static const Color accentSaffron = Color(0xFFF59E0B); // Amber / Indian saffron alert
  static const Color accentRed = Color(0xFFEF4444); // Severe Warning
  static const Color accentGreen = Color(0xFF10B981); // Emerald Ideal/Safe

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F172A),
      Color(0xFF020617),
    ],
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E293B),
      Color(0xFF0F172A),
    ],
  );

  static const LinearGradient activePersonaGradient = LinearGradient(
    colors: [
      Color(0xFF0284C7),
      Color(0xFF2563EB),
    ],
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryNavy,
      colorScheme: const ColorScheme.dark(
        primary: accentCyan,
        secondary: accentTeal,
        surface: surfaceNavy,
        error: accentRed,
      ),
      textTheme: TextTheme(
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          color: Colors.white60,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceNavy.withAlpha(200),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
        elevation: 0,
      ),
    );
  }
}
