import 'package:flutter/material.dart';
import 'app_settings.dart';

class BoardThemeData {
  final Color lightSquare;
  final Color darkSquare;
  final Color lastMoveFromLight;
  final Color lastMoveFromDark;
  final Color lastMoveToLight;
  final Color lastMoveToDark;
  final String label;

  const BoardThemeData({
    required this.lightSquare,
    required this.darkSquare,
    required this.lastMoveFromLight,
    required this.lastMoveFromDark,
    required this.lastMoveToLight,
    required this.lastMoveToDark,
    required this.label,
  });

  static BoardThemeData fromEnum(BoardTheme theme) {
    switch (theme) {
      case BoardTheme.classic:
        return const BoardThemeData(
          lightSquare: Color(0xFFEDD6B0),
          darkSquare: Color(0xFF2C2C2C),
          lastMoveFromLight: Color(0xFFDADA9A),
          lastMoveFromDark: Color(0xFF5A7A3D),
          lastMoveToLight: Color(0xFFC8C878),
          lastMoveToDark: Color(0xFF6B8F47),
          label: 'Classic',
        );
      case BoardTheme.marble:
        return const BoardThemeData(
          lightSquare: Color(0xFFF0E6D6),
          darkSquare: Color(0xFF6B7B8D),
          lastMoveFromLight: Color(0xFFD8D4B0),
          lastMoveFromDark: Color(0xFF5A7080),
          lastMoveToLight: Color(0xFFC8C890),
          lastMoveToDark: Color(0xFF4A6070),
          label: 'Marble',
        );
      case BoardTheme.wood:
        return const BoardThemeData(
          lightSquare: Color(0xFFDEB887),
          darkSquare: Color(0xFF8B4513),
          lastMoveFromLight: Color(0xFFD4B07A),
          lastMoveFromDark: Color(0xFF7A3D10),
          lastMoveToLight: Color(0xFFC8A060),
          lastMoveToDark: Color(0xFF6E3508),
          label: 'Wood',
        );
      case BoardTheme.dark:
        return const BoardThemeData(
          lightSquare: Color(0xFF4A4A4A),
          darkSquare: Color(0xFF1A1A1A),
          lastMoveFromLight: Color(0xFF5A5A3A),
          lastMoveFromDark: Color(0xFF2A2A1A),
          lastMoveToLight: Color(0xFF6A6A3A),
          lastMoveToDark: Color(0xFF3A3A1A),
          label: 'Dark',
        );
    }
  }

  static List<BoardTheme> get allThemes => BoardTheme.values;
}
