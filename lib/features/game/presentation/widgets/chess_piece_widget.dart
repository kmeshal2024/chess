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
    final char = _getPieceChar(piece);
    final fontSize = size * 0.78;

    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: isWhite
            ? _buildWhitePiece(char, fontSize)
            : _buildBlackPiece(char, fontSize),
      ),
    );
  }

  /// White pieces: outlined Unicode chars with white fill + dark stroke
  Widget _buildWhitePiece(String char, double fontSize) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Dark outline/stroke layer
        Text(
          char,
          style: TextStyle(
            fontSize: fontSize,
            height: 1.0,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.2
              ..color = const Color(0xFF2A2A2A),
          ),
        ),
        // White fill layer
        Text(
          char,
          style: TextStyle(
            fontSize: fontSize,
            height: 1.0,
            color: const Color(0xFFFFFEF5), // Bright white
            shadows: [
              Shadow(
                color: const Color(0xFF000000).withValues(alpha: 0.5),
                blurRadius: 3,
                offset: const Offset(1, 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Black pieces: filled Unicode chars in solid black
  Widget _buildBlackPiece(String char, double fontSize) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Subtle lighter edge for visibility on dark squares
        Text(
          char,
          style: TextStyle(
            fontSize: fontSize,
            height: 1.0,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.8
              ..color = const Color(0xFF555555),
          ),
        ),
        // Solid black fill
        Text(
          char,
          style: TextStyle(
            fontSize: fontSize,
            height: 1.0,
            color: const Color(0xFF1A1A1A), // Deep black
            shadows: [
              Shadow(
                color: const Color(0xFF000000).withValues(alpha: 0.6),
                blurRadius: 3,
                offset: const Offset(1, 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getPieceChar(ChessPiece piece) {
    final isWhite = piece.side == PlayerSide.white;

    switch (piece.type) {
      case PieceType.king:
        return isWhite ? '\u2654' : '\u265A'; // ♔ vs ♚
      case PieceType.queen:
        return isWhite ? '\u2655' : '\u265B'; // ♕ vs ♛
      case PieceType.rook:
        return isWhite ? '\u2656' : '\u265C'; // ♖ vs ♜
      case PieceType.bishop:
        return isWhite ? '\u2657' : '\u265D'; // ♗ vs ♝
      case PieceType.knight:
        return isWhite ? '\u2658' : '\u265E'; // ♘ vs ♞
      case PieceType.pawn:
        return isWhite ? '\u2659' : '\u265F'; // ♙ vs ♟
    }
  }
}
