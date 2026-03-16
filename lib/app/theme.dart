import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Background & surfaces
  static const background = Color(0xFF0A2E1F);
  static const backgroundDark = Color(0xFF071F15);
  static const surface = Color(0xFF143D2B);
  static const surfaceLight = Color(0xFF1B4D37);
  static const card = Color(0xFF174533);

  // Gold & accent
  static const gold = Color(0xFFD4A84B);
  static const goldLight = Color(0xFFE8C97A);
  static const goldDark = Color(0xFFC89B3C);
  static const goldShine = Color(0xFFF5DFA0);

  // Wood tones
  static const woodDark = Color(0xFF4A3208);
  static const woodMedium = Color(0xFF6B4C12);
  static const woodLight = Color(0xFF8B6914);
  static const woodPanel = Color(0xFF5C3D10);

  // Status
  static const error = Color(0xFFE8636F);
  static const success = Color(0xFF4CAF50);

  // Text
  static const textPrimary = Color(0xFFF0ECE0);
  static const textSecondary = Color(0xFFB8C4A8);
  static const textMuted = Color(0xFF6B8060);
  static const textGold = Color(0xFFD4A84B);

  // Board
  static const boardLight = Color(0xFFE8D5B0);
  static const boardDark = Color(0xFF2A2A2A);
  static const boardBorder = Color(0xFF8B6914);
  static const selectedSquare = Color(0xCCF7EC59);
  static const validMoveDot = Color(0x55000000);
  static const validMoveCapture = Color(0x55E8636F);
  static const lastMoveFrom = Color(0x50C8C34D);
  static const lastMoveTo = Color(0x60C8C34D);
  static const checkSquare = Color(0xBBE84040);

  // Divider
  static const divider = Color(0xFF1E5A3F);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.gold,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.goldLight,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      cardColor: AppColors.card,
      dividerColor: AppColors.divider,
      textTheme: GoogleFonts.cinzelTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.goldLight,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cinzel(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.goldLight,
        ),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.cinzel(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.goldLight),
    );
  }
}
