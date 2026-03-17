import 'package:chess/core/enums.dart';
import '../entities/board_position.dart';
import '../entities/chess_move.dart';
import '../entities/chess_piece.dart';

abstract class ChessEngineService {
  void newGame();

  void loadFen(String fen);

  String getFen();

  List<List<ChessPiece?>> getBoard();

  PlayerSide getCurrentTurn();

  List<BoardPosition> getLegalMoves(BoardPosition from);

  ChessMove? makeMove(
    BoardPosition from,
    BoardPosition to, {
    PieceType? promotion,
  });

  bool undoMove();

  bool isCheck();

  bool isCheckmate();

  bool isStalemate();

  bool isDraw();

  bool isGameOver();

  bool isPromotionMove(BoardPosition from, BoardPosition to);

  List<ChessMove> getMoveHistory();

  /// Get the best move from the AI engine
  /// [difficulty] ranges from 1 (beginner) to 5 (expert)
  Future<(BoardPosition from, BoardPosition to)?> getBestMove({int difficulty = 5});
}
