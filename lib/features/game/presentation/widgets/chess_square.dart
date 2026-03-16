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
    // Marble-style colors
    const lightColor = Color(0xFFE8D5B0); // Cream marble
    const darkColor = Color(0xFF1E1E1E); // Dark marble

    Color bgColor = isLightSquare ? lightColor : darkColor;

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
        decoration: BoxDecoration(
          color: bgColor,
          // Subtle marble texture via gradient overlay
          gradient: isSelected || isCheckSquare
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isLightSquare
                      ? [
                          bgColor,
                          Color.lerp(bgColor, Colors.white, 0.06)!,
                          bgColor,
                          Color.lerp(bgColor, Colors.black, 0.04)!,
                        ]
                      : [
                          bgColor,
                          Color.lerp(bgColor, Colors.white, 0.04)!,
                          bgColor,
                          Color.lerp(bgColor, Colors.black, 0.06)!,
                        ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
        ),
        child: Stack(
          children: [
            // Valid move indicator
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
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            // Capture indicator
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
