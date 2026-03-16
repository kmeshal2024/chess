import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFF0F1118);
  static const surface = Color(0xFF1A1D28);
  static const surfaceLight = Color(0xFF242836);
  static const card = Color(0xFF1E2230);
  static const primary = Color(0xFF6C9BDB);
  static const accent = Color(0xFFD4A84B);
  static const accentLight = Color(0xFFE8C97A);
  static const error = Color(0xFFE8636F);
  static const success = Color(0xFF5CB87A);
  static const textPrimary = Color(0xFFF0F0F2);
  static const textSecondary = Color(0xFF8E92A4);
  static const textMuted = Color(0xFF5A5E70);
  static const divider = Color(0xFF2A2E3E);

  // Board
  static const boardLight = Color(0xFFF0D9B5);
  static const boardDark = Color(0xFFB58863);
  static const selectedSquare = Color(0xCCF7EC59);
  static const validMoveDot = Color(0x40000000);
  static const validMoveCapture = Color(0x40E8636F);
  static const lastMoveFrom = Color(0x50C8C34D);
  static const lastMoveTo = Color(0x60C8C34D);
  static const checkSquare = Color(0xBBE8636F);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      cardColor: AppColors.card,
      dividerColor: AppColors.divider,
      textTheme: GoogleFonts.interTextTheme(
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
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
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
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
    );
  }
}
