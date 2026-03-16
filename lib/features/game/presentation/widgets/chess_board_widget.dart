import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess/app/theme.dart';
import 'package:chess/core/enums.dart';
import '../../domain/entities/board_position.dart';
import '../../domain/entities/chess_piece.dart';
import '../providers/game_provider.dart';
import 'chess_square.dart';

class ChessBoardWidget extends ConsumerWidget {
  const ChessBoardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth;
        final squareSize = boardSize / 8;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.surfaceLight, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(8, (displayRow) {
                final row = state.boardFlipped ? 7 - displayRow : displayRow;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(8, (displayCol) {
                    final col =
                        state.boardFlipped ? 7 - displayCol : displayCol;
                    final pos = BoardPosition(row, col);
                    final piece = state.board[row][col];

                    final isSelected = state.selectedSquare == pos;
                    final isValidMove = state.validMoves.contains(pos);
                    final isLastMoveFrom = state.lastMove?.from == pos;
                    final isLastMoveTo = state.lastMove?.to == pos;
                    final isCheckSquare = _isCheckSquare(state.status,
                        state.currentTurn, piece, state.board);

                    return ChessSquare(
                      row: row,
                      col: col,
                      piece: piece,
                      isSelected: isSelected,
                      isValidMove: isValidMove,
                      isLastMoveFrom: isLastMoveFrom,
                      isLastMoveTo: isLastMoveTo,
                      isCheckSquare: isCheckSquare,
                      size: squareSize,
                      onTap: () => notifier.selectSquare(pos),
                    );
                  }),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  bool _isCheckSquare(
    GameStatus status,
    PlayerSide currentTurn,
    ChessPiece? piece,
    List<List<ChessPiece?>> board,
  ) {
    if (status != GameStatus.check && status != GameStatus.checkmate) {
      return false;
    }
    if (piece == null) return false;
    return piece.type == PieceType.king && piece.side == currentTurn;
  }
}
