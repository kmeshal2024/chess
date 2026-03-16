import 'package:equatable/equatable.dart';
import 'package:chess/core/enums.dart';

class ChessPiece extends Equatable {
  final PieceType type;
  final PlayerSide side;

  const ChessPiece({required this.type, required this.side});

  String get unicode {
    const map = {
      PieceType.king: ['♔', '♚'],
      PieceType.queen: ['♕', '♛'],
      PieceType.rook: ['♖', '♜'],
      PieceType.bishop: ['♗', '♝'],
      PieceType.knight: ['♘', '♞'],
      PieceType.pawn: ['♙', '♟'],
    };
    return map[type]![side == PlayerSide.white ? 0 : 1];
  }

  @override
  List<Object?> get props => [type, side];
}
