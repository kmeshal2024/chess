import 'package:flutter/material.dart';
import 'package:chess/app/theme.dart';
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
  final VoidCallback onTap;
  final double size;

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
    required this.onTap,
    required this.size,
  });

  bool get isLightSquare => (row + col) % 2 == 0;

  @override
  Widget build(BuildContext context) {
    // Classic chess board colors - clearly distinct
    const lightColor = Color(0xFFEDD6B0); // Warm tan/cream
    const darkColor = Color(0xFF2C2C2C); // Dark charcoal

    Color bgColor = isLightSquare ? lightColor : darkColor;

    if (isSelected) {
      bgColor = AppColors.selectedSquare;
    } else if (isCheckSquare) {
      bgColor = AppColors.checkSquare;
    } else if (isLastMoveTo) {
      bgColor = isLightSquare
          ? const Color(0xFFC8C878) // Olive highlight on light
          : const Color(0xFF6B8F47); // Green highlight on dark
    } else if (isLastMoveFrom) {
      bgColor = isLightSquare
          ? const Color(0xFFDADA9A) // Subtle olive on light
          : const Color(0xFF5A7A3D); // Subtle green on dark
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
            // Capture indicator - corner triangles
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
