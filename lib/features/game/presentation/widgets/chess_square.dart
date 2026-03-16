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
    Color bgColor = isLightSquare ? AppColors.boardLight : AppColors.boardDark;

    if (isSelected) {
      bgColor = AppColors.selectedSquare;
    } else if (isCheckSquare) {
      bgColor = AppColors.checkSquare;
    } else if (isLastMoveTo) {
      bgColor = Color.lerp(bgColor, AppColors.lastMoveTo, 0.5)!;
    } else if (isLastMoveFrom) {
      bgColor = Color.lerp(bgColor, AppColors.lastMoveFrom, 0.4)!;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        color: bgColor,
        child: Stack(
          children: [
            // Valid move indicator
            if (isValidMove && piece == null)
              Center(
                child: Container(
                  width: size * 0.28,
                  height: size * 0.28,
                  decoration: const BoxDecoration(
                    color: AppColors.validMoveDot,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            // Capture indicator (valid move on enemy piece)
            if (isValidMove && piece != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.validMoveCapture,
                      width: size * 0.08,
                    ),
                    shape: BoxShape.circle,
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
