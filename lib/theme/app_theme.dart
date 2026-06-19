// =============================================================================
// theme/app_theme.dart
// =============================================================================
// Complete design system for NutriScan — AI-Powered Calorie Tracker.
// Defines all colors, typography, and component themes used across the app.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._(); // Prevent instantiation

  // ---------------------------------------------------------------------------
  // Primary Palette
  // ---------------------------------------------------------------------------
  static const Color primaryMint = Color(0xFF2DD4A8);
  static const Color primaryDark = Color(0xFF1A8A6E);
  static const Color primaryLight = Color(0xFFB2F5E4);

  // ---------------------------------------------------------------------------
  // Secondary / Warning
  // ---------------------------------------------------------------------------
  static const Color secondaryCoral = Color(0xFFFF6B6B);

  // ---------------------------------------------------------------------------
  // Accent Colors
  // ---------------------------------------------------------------------------
  static const Color accentOrange = Color(0xFFFF9F43);
  static const Color accentPurple = Color(0xFF9B59B6);
  static const Color accentBlue = Color(0xFF54A0FF);

  // ---------------------------------------------------------------------------
  // Macro Nutrient Colors
  // ---------------------------------------------------------------------------
  static const Color proteinColor = Color(0xFF6C5CE7);
  static const Color carbsColor = Color(0xFFFFA502);
  static const Color fatsColor = Color(0xFFFF6348);
  static const Color waterColor = Color(0xFF48DBFB);

  // ---------------------------------------------------------------------------
  // Surfaces & Backgrounds
  // ---------------------------------------------------------------------------
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color cardGrey = Color(0xFFF5F6FA);
  static const Color backgroundLight = Color(0xFFF8F9FA);

  // ---------------------------------------------------------------------------
  // Text Colors
  // ---------------------------------------------------------------------------
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textTertiary = Color(0xFFB2BEC3);

  // ---------------------------------------------------------------------------
  // Status Indicators (for 30-day history)
  // ---------------------------------------------------------------------------
  static const Color statusGreen = Color(0xFF00B894);
  static const Color statusYellow = Color(0xFFFDAA5B);
  static const Color statusRed = Color(0xFFFF6B6B);

  // ---------------------------------------------------------------------------
  // Streak
  // ---------------------------------------------------------------------------
  static const Color streakColor = Color(0xFFFF9F43);
  static const Color streakBgColor = Color(0xFFFFF3E0);

  // ---------------------------------------------------------------------------
  // Legacy aliases (for backward compat with existing code)
  // ---------------------------------------------------------------------------
  static const Color primaryColor = primaryMint;
  static const Color secondaryColor = primaryDark;
  static const Color accentColor = accentOrange;
  static const Color backgroundColor = backgroundLight;
  static const Color surfaceColor = surfaceWhite;
  static const Color textPrimaryColor = textPrimary;
  static const Color textSecondaryColor = textSecondary;
  static const Color errorColor = secondaryCoral;
  static const Color successColor = statusGreen;

  // ---------------------------------------------------------------------------
  // Light Theme
  // ---------------------------------------------------------------------------
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryMint,
        secondary: primaryDark,
        tertiary: accentOrange,
        surface: surfaceWhite,
        error: secondaryCoral,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          color: textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        displayMedium: GoogleFonts.outfit(
          color: textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
        headlineMedium: GoogleFonts.outfit(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
        titleLarge: GoogleFonts.inter(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        bodyLarge: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryMint,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.outfit(
          color: textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceWhite,
        selectedItemColor: primaryMint,
        unselectedItemColor: textSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryMint, width: 2),
        ),
        hintStyle: GoogleFonts.inter(color: textSecondary),
      ),
    );
  }
}
