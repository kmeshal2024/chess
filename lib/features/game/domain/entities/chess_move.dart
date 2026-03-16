import 'package:equatable/equatable.dart';
import 'package:chess/core/enums.dart';
import 'board_position.dart';
import 'chess_piece.dart';

class ChessMove extends Equatable {
  final BoardPosition from;
  final BoardPosition to;
  final ChessPiece piece;
  final ChessPiece? capturedPiece;
  final String san;
  final bool isCheck;
  final bool isCheckmate;
  final bool isCastling;
  final bool isEnPassant;
  final bool isPromotion;
  final PieceType? promotionPiece;
  final int moveNumber;

  const ChessMove({
    required this.from,
    required this.to,
    required this.piece,
    this.capturedPiece,
    required this.san,
    this.isCheck = false,
    this.isCheckmate = false,
    this.isCastling = false,
    this.isEnPassant = false,
    this.isPromotion = false,
    this.promotionPiece,
    this.moveNumber = 0,
  });

  @override
  List<Object?> get props => [from, to, san, moveNumber];
}
