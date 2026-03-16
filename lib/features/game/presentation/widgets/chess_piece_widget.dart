import 'package:flutter/material.dart';
import 'package:chess/core/enums.dart';
import '../../domain/entities/chess_piece.dart';

class ChessPieceWidget extends StatelessWidget {
  final ChessPiece piece;
  final double size;

  const ChessPieceWidget({
    super.key,
    required this.piece,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final isWhite = piece.side == PlayerSide.white;

    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          _getPieceChar(piece),
          style: TextStyle(
            fontSize: size * 0.72,
            height: 1.0,
            color: isWhite
                ? const Color(0xFFF5F0E0) // Warm cream white
                : const Color(0xFF1A1A1A), // Deep black
            shadows: [
              // Main shadow for depth
              Shadow(
                color: Colors.black.withOpacity(isWhite ? 0.5 : 0.6),
                blurRadius: 3,
                offset: const Offset(1, 1.5),
              ),
              // Subtle glow for white pieces
              if (isWhite)
                Shadow(
                  color: Colors.white.withOpacity(0.15),
                  blurRadius: 1,
                  offset: const Offset(-0.5, -0.5),
                ),
              // Subtle rim highlight for black pieces
              if (!isWhite)
                Shadow(
                  color: Colors.white.withOpacity(0.08),
                  blurRadius: 1,
                  offset: const Offset(-0.5, -0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPieceChar(ChessPiece piece) {
    switch (piece.type) {
      case PieceType.king:
        return '♚';
      case PieceType.queen:
        return '♛';
      case PieceType.rook:
        return '♜';
      case PieceType.bishop:
        return '♝';
      case PieceType.knight:
        return '♞';
      case PieceType.pawn:
        return '♟';
    }
  }
}
