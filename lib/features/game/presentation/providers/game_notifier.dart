import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess/core/enums.dart';
import 'package:chess/core/services/sound_service.dart';
import '../../domain/entities/board_position.dart';
import '../../domain/entities/chess_piece.dart';
import '../../domain/services/chess_engine_service.dart';
import 'game_state.dart';

class GameNotifier extends StateNotifier<GameState> {
  final ChessEngineService _engine;
  final SoundService? _soundService;
  final bool Function() _isSoundEnabled;
  final bool Function() _isHapticEnabled;
  Timer? _hintTimer;
  int _gameInstanceId = 0;

  GameNotifier(
    this._engine, {
    SoundService? soundService,
    bool Function()? isSoundEnabled,
    bool Function()? isHapticEnabled,
  })  : _soundService = soundService,
        _isSoundEnabled = isSoundEnabled ?? (() => true),
        _isHapticEnabled = isHapticEnabled ?? (() => true),
        super(GameState(
          board: List.generate(8, (_) => List.filled(8, null)),
        )) {
    _startNewGame();
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }

  void _startNewGame() {
    try {
      _engine.newGame();
      _syncStateFromEngine();
    } catch (e) {
      state = GameState(
        board: List.generate(8, (_) => List<ChessPiece?>.filled(8, null)),
        status: GameStatus.idle,
      );
    }
  }

  /// Configure game for AI mode
  void configureAiGame({
    required PlayerSide playerSide,
    required int difficulty,
  }) {
    _hintTimer?.cancel();
    _gameInstanceId++;
    try {
      _engine.newGame();
      state = GameState(
        board: _engine.getBoard(),
        currentTurn: PlayerSide.white,
        status: GameStatus.playing,
        gameMode: GameMode.ai,
        playerSide: playerSide,
        aiDifficulty: difficulty,
        boardFlipped: playerSide == PlayerSide.black,
        hintsRemaining: 4,
      );

      // If player is black, AI (white) moves first
      if (playerSide == PlayerSide.black) {
        _scheduleAiMoveIfNeeded();
      }
    } catch (e) {
      state = GameState(
        board: List.generate(8, (_) => List<ChessPiece?>.filled(8, null)),
        status: GameStatus.idle,
      );
    }
  }

  void restartGame() {
    _hintTimer?.cancel();
    _gameInstanceId++;
    final savedMode = state.gameMode;
    final savedSide = state.playerSide;
    final savedDifficulty = state.aiDifficulty;

    try {
      _engine.newGame();
      state = GameState(
        board: _engine.getBoard(),
        currentTurn: PlayerSide.white,
        status: GameStatus.playing,
        gameMode: savedMode,
        playerSide: savedSide,
        aiDifficulty: savedDifficulty,
        boardFlipped: savedMode == GameMode.ai && savedSide == PlayerSide.black,
        hintsRemaining: 4,
      );

      // If AI mode and player is black, AI moves first
      if (savedMode == GameMode.ai && savedSide == PlayerSide.black) {
        _scheduleAiMoveIfNeeded();
      }
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

    // Block interaction while AI is thinking
    if (state.isAiThinking) return;

    // In AI mode, only allow player to move their pieces
    if (state.gameMode == GameMode.ai &&
        state.currentTurn != state.playerSide) {
      return;
    }

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

      // Clear hint on move
      _hintTimer?.cancel();

      state = state.copyWith(
        board: _engine.getBoard(),
        currentTurn: _engine.getCurrentTurn(),
        status: newStatus,
        clearSelection: true,
        clearHint: true,
        lastMove: move,
        moveHistory: _engine.getMoveHistory(),
        capturedByWhite: capturedByWhite,
        capturedByBlack: capturedByBlack,
        awaitingPromotion: false,
      );

      // Play sound effects
      _playMoveSound(newStatus, move.capturedPiece != null);

      // Haptic feedback
      if (_isHapticEnabled()) {
        HapticFeedback.mediumImpact();
      }

      // Trigger AI move if needed
      _scheduleAiMoveIfNeeded();
    } catch (e) {
      state = state.copyWith(
        clearSelection: true,
        awaitingPromotion: false,
      );
    }
  }

  // --- AI Logic ---

  void _scheduleAiMoveIfNeeded() {
    if (state.gameMode != GameMode.ai) return;
    if (state.currentTurn == state.playerSide) return;
    if (_isGameOver(state.status)) return;

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _makeAiMove();
    });
  }

  bool _isGameOver(GameStatus status) {
    return status == GameStatus.checkmate ||
        status == GameStatus.stalemate ||
        status == GameStatus.draw ||
        status == GameStatus.resigned;
  }

  Future<void> _makeAiMove() async {
    if (!mounted) return;
    if (_isGameOver(state.status)) return;

    final instanceId = _gameInstanceId;
    state = state.copyWith(isAiThinking: true);

    try {
      // Small delay for natural feel
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted || _gameInstanceId != instanceId) return;

      final bestMove = await _engine.getBestMove(
        difficulty: state.aiDifficulty,
      );
      if (!mounted || _gameInstanceId != instanceId) return;

      if (bestMove == null) {
        state = state.copyWith(isAiThinking: false);
        return;
      }

      final (from, to) = bestMove;

      // Check for promotion — AI always promotes to queen
      bool isPromo = false;
      try {
        isPromo = _engine.isPromotionMove(from, to);
      } catch (_) {}

      // Clear AI thinking flag before executing move
      state = state.copyWith(isAiThinking: false);

      if (isPromo) {
        _executeMove(from, to, promotion: PieceType.queen);
      } else {
        _executeMove(from, to);
      }
    } catch (e) {
      if (mounted && _gameInstanceId == instanceId) {
        state = state.copyWith(isAiThinking: false);
      }
    }
  }

  // --- Sound ---

  void _playMoveSound(GameStatus status, bool isCapture) {
    if (!_isSoundEnabled() || _soundService == null) return;

    if (status == GameStatus.checkmate ||
        status == GameStatus.stalemate ||
        status == GameStatus.draw) {
      _soundService.playGameOver();
    } else if (status == GameStatus.check) {
      _soundService.playCheck();
    } else if (isCapture) {
      _soundService.playCapture();
    } else {
      _soundService.playMove();
    }
  }

  // --- Undo ---

  void undoMove() {
    if (state.moveHistory.isEmpty) return;
    if (state.awaitingPromotion) return;
    if (state.isAiThinking) return;

    // In AI mode, undo both AI move and human move
    if (state.gameMode == GameMode.ai && state.moveHistory.length >= 2) {
      _undoSingleMove(); // Undo AI's last move
      _undoSingleMove(); // Undo human's last move
    } else {
      _undoSingleMove();
    }
  }

  void _undoSingleMove() {
    if (state.moveHistory.isEmpty) return;

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

  // --- Resign & Draw ---

  void resignGame() {
    if (_isGameOver(state.status)) return;
    if (state.isAiThinking) return;
    _hintTimer?.cancel();
    _gameInstanceId++;
    state = state.copyWith(status: GameStatus.resigned);
  }

  void offerDraw() {
    if (_isGameOver(state.status)) return;
    if (state.isAiThinking) return;
    // In AI mode, AI accepts draw if position is roughly equal or losing
    if (state.gameMode == GameMode.ai) {
      _hintTimer?.cancel();
      _gameInstanceId++;
      state = state.copyWith(status: GameStatus.draw);
    }
    // In offline mode, just accept draw immediately (both players at same device)
    if (state.gameMode == GameMode.offline) {
      _hintTimer?.cancel();
      _gameInstanceId++;
      state = state.copyWith(status: GameStatus.draw);
    }
  }

  // --- Board ---

  void flipBoard() {
    state = state.copyWith(boardFlipped: !state.boardFlipped);
  }

  // --- Hints ---

  /// Request a hint from the AI engine
  Future<void> requestHint() async {
    if (state.hintsRemaining <= 0) return;
    if (state.isLoadingHint) return;
    if (state.isAiThinking) return;
    if (state.status != GameStatus.playing &&
        state.status != GameStatus.check) {
      return;
    }

    state = state.copyWith(isLoadingHint: true, clearHint: true);

    try {
      final bestMove = await _engine.getBestMove();
      if (bestMove == null || !mounted) {
        if (mounted) state = state.copyWith(isLoadingHint: false);
        return;
      }

      final (from, to) = bestMove;

      state = state.copyWith(
        hintFrom: from,
        hintTo: to,
        hintsRemaining: state.hintsRemaining - 1,
        isLoadingHint: false,
      );

      // Auto-clear hint after 3 seconds
      _hintTimer?.cancel();
      _hintTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          clearHint();
        }
      });
    } catch (e) {
      if (mounted) state = state.copyWith(isLoadingHint: false);
    }
  }

  void clearHint() {
    _hintTimer?.cancel();
    state = state.copyWith(clearHint: true);
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
