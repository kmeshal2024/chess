import 'package:flutter/material.dart';
import 'package:chess/app/theme.dart';
import 'package:chess/core/enums.dart';
import '../../domain/entities/chess_piece.dart';

class CapturedPiecesWidget extends StatelessWidget {
  final List<ChessPiece> pieces;
  final PlayerSide side;
  final int materialAdvantage;

  const CapturedPiecesWidget({
    super.key,
    required this.pieces,
    required this.side,
    required this.materialAdvantage,
  });

  @override
  Widget build(BuildContext context) {
    final advantage =
        side == PlayerSide.white ? materialAdvantage : -materialAdvantage;

    return SizedBox(
      height: 28,
      child: Row(
        children: [
          Expanded(
            child: pieces.isEmpty
                ? const SizedBox.shrink()
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: pieces.map((piece) {
                        return Text(
                          _getPieceSymbol(piece.type),
                          style: TextStyle(
                            fontSize: 16,
                            color: piece.side == PlayerSide.white
                                ? const Color(0xFFD0D0C8)
                                : const Color(0xFF4A4A4A),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
          if (advantage > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '+$advantage',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getPieceSymbol(PieceType type) {
    switch (type) {
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
      case PieceType.king:
        return '♚';
    }
  }
}
