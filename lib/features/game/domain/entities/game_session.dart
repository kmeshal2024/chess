import 'package:equatable/equatable.dart';
import 'package:chess/core/enums.dart';
import 'chess_move.dart';
import 'chess_piece.dart';
import 'match_settings.dart';

class GameSession extends Equatable {
  final String id;
  final MatchSettings settings;
  final PlayerSide currentTurn;
  final GameStatus status;
  final List<List<ChessPiece?>> board;
  final List<ChessMove> moveHistory;
  final List<ChessPiece> capturedByWhite;
  final List<ChessPiece> capturedByBlack;
  final String fen;
  final DateTime createdAt;
  final DateTime? finishedAt;
  final PlayerSide? winner;

  const GameSession({
    required this.id,
    required this.settings,
    required this.currentTurn,
    required this.status,
    required this.board,
    this.moveHistory = const [],
    this.capturedByWhite = const [],
    this.capturedByBlack = const [],
    required this.fen,
    required this.createdAt,
    this.finishedAt,
    this.winner,
  });

  GameSession copyWith({
    PlayerSide? currentTurn,
    GameStatus? status,
    List<List<ChessPiece?>>? board,
    List<ChessMove>? moveHistory,
    List<ChessPiece>? capturedByWhite,
    List<ChessPiece>? capturedByBlack,
    String? fen,
    DateTime? finishedAt,
    PlayerSide? winner,
  }) {
    return GameSession(
      id: id,
      settings: settings,
      currentTurn: currentTurn ?? this.currentTurn,
      status: status ?? this.status,
      board: board ?? this.board,
      moveHistory: moveHistory ?? this.moveHistory,
      capturedByWhite: capturedByWhite ?? this.capturedByWhite,
      capturedByBlack: capturedByBlack ?? this.capturedByBlack,
      fen: fen ?? this.fen,
      createdAt: createdAt,
      finishedAt: finishedAt ?? this.finishedAt,
      winner: winner ?? this.winner,
    );
  }

  @override
  List<Object?> get props => [id, currentTurn, status, fen, moveHistory.length];
}
