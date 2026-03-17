import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess/core/enums.dart';
import '../../domain/entities/board_position.dart';
import '../../domain/entities/chess_piece.dart';
import '../../domain/services/chess_engine_service.dart';
import 'game_state.dart';

class GameNotifier extends StateNotifier<GameState> {
  final ChessEngineService _engine;

  GameNotifier(this._engine)
      : super(GameState(
          board: List.generate(8, (_) => List.filled(8, null)),
        )) {
    _startNewGame();
  }

  void _startNewGame() {
    try {
      _engine.newGame();
      _syncStateFromEngine();
    } catch (e) {
      // If engine fails, set up an empty board so the UI doesn't crash
      state = GameState(
        board: List.generate(8, (_) => List<ChessPiece?>.filled(8, null)),
        status: GameStatus.idle,
      );
    }
  }

  void restartGame() {
    try {
      _engine.newGame();
      state = GameState(
        board: _engine.getBoard(),
        currentTurn: PlayerSide.white,
        status: GameStatus.playing,
        gameId: state.gameId,
        boardFlipped: state.boardFlipped,
      );
    } catch (e) {
      state = GameState(
        board: List.generate(8, (_) => List<ChessPiece?>.filled(8, null)),
        status: GameStatus.idle,
        boardFlipped: state.boardFlipped,
      );
    }
  }

  void selectSquare(BoardPosition position) {
    if (state.status == GameStatus.checkmate ||
        state.status == GameStatus.stalemate ||
        state.status == GameStatus.draw ||
        state.status == GameStatus.idle) {
      return;
    }

    if (state.awaitingPromotion) return;

    final piece = state.board[position.row][position.col];

    // If a square is selected and we tap a valid move target
    if (state.selectedSquare != null &&
        state.validMoves.contains(position)) {
      _handleMoveAttempt(state.selectedSquare!, position);
      return;
    }

    // If tapping own piece, select it
    if (piece != null && piece.side == state.currentTurn) {
      try {
        final moves = _engine.getLegalMoves(position);
        state = state.copyWith(
          selectedSquare: position,
          validMoves: moves.toSet(),
        );
      } catch (e) {
        state = state.copyWith(clearSelection: true);
      }
      return;
    }

    // Deselect
    state = state.copyWith(clearSelection: true);
  }

  void _handleMoveAttempt(BoardPosition from, BoardPosition to) {
    try {
      // Check if this is a promotion move
      if (_engine.isPromotionMove(from, to)) {
        state = state.copyWith(
          awaitingPromotion: true,
          promotionFrom: from,
          promotionTo: to,
          clearSelection: true,
        );
        return;
      }
    } catch (e) {
      // If promotion check fails, try to make the move anyway
    }

    _executeMove(from, to);
  }

  void completePromotion(PieceType promotionPiece) {
    if (!state.awaitingPromotion ||
        state.promotionFrom == null ||
        state.promotionTo == null) {
      return;
    }

    _executeMove(
      state.promotionFrom!,
      state.promotionTo!,
      promotion: promotionPiece,
    );
  }

  void cancelPromotion() {
    state = state.copyWith(
      awaitingPromotion: false,
      clearSelection: true,
    );
  }

  void _executeMove(BoardPosition from, BoardPosition to,
      {PieceType? promotion}) {
    try {
      final move = _engine.makeMove(from, to, promotion: promotion);
      if (move == null) {
        state = state.copyWith(
          clearSelection: true,
          awaitingPromotion: false,
        );
        return;
      }

      // Track captures
      final capturedByWhite = List<ChessPiece>.from(state.capturedByWhite);
      final capturedByBlack = List<ChessPiece>.from(state.capturedByBlack);

      if (move.capturedPiece != null) {
        if (move.piece.side == PlayerSide.white) {
          capturedByWhite.add(move.capturedPiece!);
          capturedByWhite.sort((a, b) =>
              b.type.materialValue.compareTo(a.type.materialValue));
        } else {
          capturedByBlack.add(move.capturedPiece!);
          capturedByBlack.sort((a, b) =>
              b.type.materialValue.compareTo(a.type.materialValue));
        }
      }

      GameStatus newStatus = GameStatus.playing;
      if (_engine.isCheckmate()) {
        newStatus = GameStatus.checkmate;
      } else if (_engine.isStalemate()) {
        newStatus = GameStatus.stalemate;
      } else if (_engine.isDraw()) {
        newStatus = GameStatus.draw;
      } else if (_engine.isCheck()) {
        newStatus = GameStatus.check;
      }

      state = state.copyWith(
        board: _engine.getBoard(),
        currentTurn: _engine.getCurrentTurn(),
        status: newStatus,
        clearSelection: true,
        lastMove: move,
        moveHistory: _engine.getMoveHistory(),
        capturedByWhite: capturedByWhite,
        capturedByBlack: capturedByBlack,
        awaitingPromotion: false,
      );
    } catch (e) {
      state = state.copyWith(
        clearSelection: true,
        awaitingPromotion: false,
      );
    }
  }

  void undoMove() {
    if (state.moveHistory.isEmpty) return;
    if (state.awaitingPromotion) return;

    try {
      final lastMove = state.moveHistory.last;

      _engine.undoMove();

      final capturedByWhite = List<ChessPiece>.from(state.capturedByWhite);
      final capturedByBlack = List<ChessPiece>.from(state.capturedByBlack);

      if (lastMove.capturedPiece != null) {
        if (lastMove.piece.side == PlayerSide.white) {
          capturedByWhite.remove(lastMove.capturedPiece!);
        } else {
          capturedByBlack.remove(lastMove.capturedPiece!);
        }
      }

      final history = _engine.getMoveHistory();

      GameStatus newStatus = GameStatus.playing;
      if (_engine.isCheck()) {
        newStatus = GameStatus.check;
      }

      state = state.copyWith(
        board: _engine.getBoard(),
        currentTurn: _engine.getCurrentTurn(),
        status: newStatus,
        clearSelection: true,
        lastMove: history.isNotEmpty ? history.last : null,
        clearLastMove: history.isEmpty,
        moveHistory: history,
        capturedByWhite: capturedByWhite,
        capturedByBlack: capturedByBlack,
      );
    } catch (e) {
      // Undo failed, don't crash
    }
  }

  void flipBoard() {
    state = state.copyWith(boardFlipped: !state.boardFlipped);
  }

  void _syncStateFromEngine() {
    try {
      state = state.copyWith(
        board: _engine.getBoard(),
        currentTurn: _engine.getCurrentTurn(),
        status: GameStatus.playing,
      );
    } catch (e) {
      // Keep current state if sync fails
    }
  }
}
