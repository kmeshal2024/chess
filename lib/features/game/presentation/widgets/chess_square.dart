import 'package:flutter/material.dart';
import 'package:chess/app/theme.dart';
import 'package:chess/features/settings/domain/models/board_theme_data.dart';
import '../../domain/entities/chess_piece.dart';
import 'chess_piece_widget.dart';

class ChessSquare extends StatelessWidget {
  final int row;
  final int col;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isValidMove;
  final bool isLastMoveFrom;
  final bool isLastMoveTo;
  final bool isCheckSquare;
  final bool isHintFrom;
  final bool isHintTo;
  final VoidCallback onTap;
  final double size;
  final BoardThemeData themeData;

  const ChessSquare({
    super.key,
    required this.row,
    required this.col,
    this.piece,
    this.isSelected = false,
    this.isValidMove = false,
    this.isLastMoveFrom = false,
    this.isLastMoveTo = false,
    this.isCheckSquare = false,
    this.isHintFrom = false,
    this.isHintTo = false,
    required this.onTap,
    required this.size,
    required this.themeData,
  });

  bool get isLightSquare => (row + col) % 2 == 0;

  @override
  Widget build(BuildContext context) {
    Color bgColor =
        isLightSquare ? themeData.lightSquare : themeData.darkSquare;

    if (isSelected) {
      bgColor = AppColors.selectedSquare;
    } else if (isCheckSquare) {
      bgColor = AppColors.checkSquare;
    } else if (isLastMoveTo) {
      bgColor = isLightSquare
          ? themeData.lastMoveToLight
          : themeData.lastMoveToDark;
    } else if (isLastMoveFrom) {
      bgColor = isLightSquare
          ? themeData.lastMoveFromLight
          : themeData.lastMoveFromDark;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
        ),
        child: Stack(
          children: [
            // Hint highlight glow
            if (isHintFrom || isHintTo)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90D9).withValues(alpha: 0.35),
                    border: Border.all(
                      color: const Color(0xFF4A90D9).withValues(alpha: 0.7),
                      width: 2,
                    ),
                  ),
                ),
              ),
            // Valid move indicator - dot
            if (isValidMove && piece == null)
              Center(
                child: Container(
                  width: size * 0.3,
                  height: size * 0.3,
                  decoration: BoxDecoration(
                    color: AppColors.validMoveDot,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            // Capture indicator - border
            if (isValidMove && piece != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.validMoveCapture,
                      width: size * 0.08,
                    ),
                  ),
                ),
              ),
            // Chess piece
            if (piece != null)
              Center(child: ChessPieceWidget(piece: piece!, size: size)),
          ],
        ),
      ),
    );
  }
}
