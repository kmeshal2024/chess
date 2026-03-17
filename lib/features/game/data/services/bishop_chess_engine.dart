import 'package:bishop/bishop.dart' as bishop;
import 'package:chess/core/enums.dart';
import '../../domain/entities/board_position.dart';
import '../../domain/entities/chess_move.dart';
import '../../domain/entities/chess_piece.dart';
import '../../domain/services/chess_engine_service.dart';

class BishopChessEngine implements ChessEngineService {
  late bishop.Game _game;
  final List<ChessMove> _moveHistory = [];
  final List<_CaptureRecord> _captureStack = [];

  BishopChessEngine() {
    _game = bishop.Game(variant: bishop.Variant.standard());
  }

  @override
  void newGame() {
    _game = bishop.Game(variant: bishop.Variant.standard());
    _moveHistory.clear();
    _captureStack.clear();
  }

  @override
  void loadFen(String fen) {
    _game = bishop.Game(variant: bishop.Variant.standard(), fen: fen);
    _moveHistory.clear();
    _captureStack.clear();
  }

  @override
  String getFen() => _game.fen;

  @override
  List<List<ChessPiece?>> getBoard() {
    final board = List.generate(8, (_) => List<ChessPiece?>.filled(8, null));
    final bishopBoard = _game.board;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final idx = row * 16 + col;
        final sq = bishopBoard[idx];
        if (sq.isNotEmpty) {
          board[row][col] = _convertPiece(sq);
        }
      }
    }
    return board;
  }

  @override
  PlayerSide getCurrentTurn() =>
      _game.turn == 0 ? PlayerSide.white : PlayerSide.black;

  @override
  List<BoardPosition> getLegalMoves(BoardPosition from) {
    final bishopFrom = from.row * 16 + from.col;
    final moves = _game.generateLegalMoves();
    final validTargets = <BoardPosition>[];

    for (final move in moves) {
      if (move.from == bishopFrom) {
        final toRow = move.to ~/ 16;
        final toCol = move.to % 16;
        final pos = BoardPosition(toRow, toCol);
        if (!validTargets.contains(pos)) {
          validTargets.add(pos);
        }
      }
    }
    return validTargets;
  }

  @override
  bool isPromotionMove(BoardPosition from, BoardPosition to) {
    final bishopFrom = from.row * 16 + from.col;
    final bishopTo = to.row * 16 + to.col;
    final moves = _game.generateLegalMoves();

    for (final move in moves) {
      if (move.from == bishopFrom && move.to == bishopTo && move.promotion) {
        return true;
      }
    }
    return false;
  }

  @override
  ChessMove? makeMove(
    BoardPosition from,
    BoardPosition to, {
    PieceType? promotion,
  }) {
    final bishopFrom = from.row * 16 + from.col;
    final bishopTo = to.row * 16 + to.col;
    final moves = _game.generateLegalMoves();

    bishop.Move? selectedMove;
    for (final move in moves) {
      if (move.from == bishopFrom && move.to == bishopTo) {
        if (move.promotion) {
          if (promotion != null &&
              move.promoPiece == _pieceTypeToBishop(promotion)) {
            selectedMove = move;
            break;
          }
        } else if (!move.promotion) {
          selectedMove = move;
          break;
        }
      }
    }

    if (selectedMove == null) return null;

    final boardBefore = _game.board;
    final pieceAtFrom = boardBefore[bishopFrom];
    final pieceAtTo = boardBefore[bishopTo];
    final movingPiece = _convertPiece(pieceAtFrom);

    ChessPiece? capturedPiece;
    if (pieceAtTo.isNotEmpty) {
      capturedPiece = _convertPiece(pieceAtTo);
    }

    // En passant capture detection
    if (movingPiece.type == PieceType.pawn &&
        from.col != to.col &&
        capturedPiece == null) {
      // This is en passant
      final epRow = from.row;
      final epCol = to.col;
      final epIdx = epRow * 16 + epCol;
      final epPiece = boardBefore[epIdx];
      if (epPiece.isNotEmpty) {
        capturedPiece = _convertPiece(epPiece);
      }
    }

    final san = _game.toSan(selectedMove);
    _game.makeMove(selectedMove);

    final isCheck = _game.inCheck;
    final isCheckmate = _game.checkmate;
    final isCastling = _isCastlingMove(movingPiece, from, to);
    final isEnPassant = movingPiece.type == PieceType.pawn &&
        from.col != to.col &&
        pieceAtTo.isEmpty;

    final moveNumber = (_moveHistory.length ~/ 2) + 1;

    final chessMove = ChessMove(
      from: from,
      to: to,
      piece: movingPiece,
      capturedPiece: capturedPiece,
      san: san,
      isCheck: isCheck,
      isCheckmate: isCheckmate,
      isCastling: isCastling,
      isEnPassant: isEnPassant,
      isPromotion: selectedMove.promotion,
      promotionPiece: promotion,
      moveNumber: moveNumber,
    );

    _moveHistory.add(chessMove);
    _captureStack.add(_CaptureRecord(capturedPiece));

    return chessMove;
  }

  @override
  bool undoMove() {
    if (_moveHistory.isEmpty) return false;
    _game.undo();
    _moveHistory.removeLast();
    _captureStack.removeLast();
    return true;
  }

  @override
  bool isCheck() => _game.inCheck;

  @override
  bool isCheckmate() => _game.checkmate;

  @override
  bool isStalemate() => _game.stalemate;

  @override
  bool isDraw() => _game.drawn;

  @override
  bool isGameOver() => _game.gameOver;

  @override
  List<ChessMove> getMoveHistory() => List.unmodifiable(_moveHistory);

  @override
  Future<(BoardPosition, BoardPosition)?> getBestMove() async {
    try {
      if (_game.gameOver) return null;

      final engine = bishop.Engine(game: _game);
      final result = await engine.search();

      final bestMove = result.move;
      if (bestMove == null) return null;

      final fromRow = bestMove.from ~/ 16;
      final fromCol = bestMove.from % 16;
      final toRow = bestMove.to ~/ 16;
      final toCol = bestMove.to % 16;

      return (BoardPosition(fromRow, fromCol), BoardPosition(toRow, toCol));
    } catch (e) {
      return null;
    }
  }

  // --- Helpers ---

  bool _isCastlingMove(ChessPiece piece, BoardPosition from, BoardPosition to) {
    if (piece.type != PieceType.king) return false;
    return (from.col - to.col).abs() == 2;
  }

  ChessPiece _convertPiece(bishop.Square sq) {
    return ChessPiece(
      type: _bishopToPieceType(sq.type),
      side: sq.colour == 0 ? PlayerSide.white : PlayerSide.black,
    );
  }

  PieceType _bishopToPieceType(int type) {
    switch (type) {
      case 1:
        return PieceType.pawn;
      case 2:
        return PieceType.knight;
      case 3:
        return PieceType.bishop;
      case 4:
        return PieceType.rook;
      case 5:
        return PieceType.queen;
      case 6:
        return PieceType.king;
      default:
        return PieceType.pawn;
    }
  }

  int _pieceTypeToBishop(PieceType type) {
    switch (type) {
      case PieceType.pawn:
        return 1;
      case PieceType.knight:
        return 2;
      case PieceType.bishop:
        return 3;
      case PieceType.rook:
        return 4;
      case PieceType.queen:
        return 5;
      case PieceType.king:
        return 6;
    }
  }
}

class _CaptureRecord {
  final ChessPiece? captured;
  const _CaptureRecord(this.captured);
}
