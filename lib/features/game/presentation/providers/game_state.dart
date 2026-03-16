import 'package:equatable/equatable.dart';
import 'package:chess/core/enums.dart';
import '../../domain/entities/board_position.dart';
import '../../domain/entities/chess_move.dart';
import '../../domain/entities/chess_piece.dart';

class GameState extends Equatable {
  final List<List<ChessPiece?>> board;
  final PlayerSide currentTurn;
  final GameStatus status;
  final BoardPosition? selectedSquare;
  final Set<BoardPosition> validMoves;
  final ChessMove? lastMove;
  final List<ChessMove> moveHistory;
  final List<ChessPiece> capturedByWhite;
  final List<ChessPiece> capturedByBlack;
  final bool awaitingPromotion;
  final BoardPosition? promotionFrom;
  final BoardPosition? promotionTo;
  final String? gameId;
  final bool boardFlipped;

  const GameState({
    required this.board,
    this.currentTurn = PlayerSide.white,
    this.status = GameStatus.playing,
    this.selectedSquare,
    this.validMoves = const {},
    this.lastMove,
    this.moveHistory = const [],
    this.capturedByWhite = const [],
    this.capturedByBlack = const [],
    this.awaitingPromotion = false,
    this.promotionFrom,
    this.promotionTo,
    this.gameId,
    this.boardFlipped = false,
  });

  GameState copyWith({
    List<List<ChessPiece?>>? board,
    PlayerSide? currentTurn,
    GameStatus? status,
    BoardPosition? selectedSquare,
    bool clearSelection = false,
    Set<BoardPosition>? validMoves,
    ChessMove? lastMove,
    bool clearLastMove = false,
    List<ChessMove>? moveHistory,
    List<ChessPiece>? capturedByWhite,
    List<ChessPiece>? capturedByBlack,
    bool? awaitingPromotion,
    BoardPosition? promotionFrom,
    BoardPosition? promotionTo,
    String? gameId,
    bool? boardFlipped,
  }) {
    return GameState(
      board: board ?? this.board,
      currentTurn: currentTurn ?? this.currentTurn,
      status: status ?? this.status,
      selectedSquare: clearSelection ? null : (selectedSquare ?? this.selectedSquare),
      validMoves: clearSelection ? {} : (validMoves ?? this.validMoves),
      lastMove: clearLastMove ? null : (lastMove ?? this.lastMove),
      moveHistory: moveHistory ?? this.moveHistory,
      capturedByWhite: capturedByWhite ?? this.capturedByWhite,
      capturedByBlack: capturedByBlack ?? this.capturedByBlack,
      awaitingPromotion: awaitingPromotion ?? this.awaitingPromotion,
      promotionFrom: promotionFrom ?? this.promotionFrom,
      promotionTo: promotionTo ?? this.promotionTo,
      gameId: gameId ?? this.gameId,
      boardFlipped: boardFlipped ?? this.boardFlipped,
    );
  }

  int get materialAdvantageWhite {
    int white = 0;
    int black = 0;
    for (final piece in capturedByWhite) {
      white += piece.type.materialValue;
    }
    for (final piece in capturedByBlack) {
      black += piece.type.materialValue;
    }
    return white - black;
  }

  @override
  List<Object?> get props => [
        currentTurn,
        status,
        selectedSquare,
        validMoves,
        lastMove,
        moveHistory.length,
        capturedByWhite.length,
        capturedByBlack.length,
        awaitingPromotion,
        boardFlipped,
      ];
}
