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
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          _getPieceChar(piece),
          style: TextStyle(
            fontSize: size * 0.68,
            height: 1.0,
            color: piece.side == PlayerSide.white
                ? const Color(0xFFF8F8F0)
                : const Color(0xFF1A1A1A),
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 2,
                offset: const Offset(0.5, 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPieceChar(ChessPiece piece) {
    // Using filled chess symbols for both sides for clearer rendering
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
