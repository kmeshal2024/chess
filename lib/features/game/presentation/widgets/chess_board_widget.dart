import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess/app/theme.dart';
import 'package:chess/core/enums.dart';
import '../../domain/entities/board_position.dart';
import '../../domain/entities/chess_piece.dart';
import '../providers/game_provider.dart';
import '../providers/game_state.dart';
import 'chess_square.dart';

class ChessBoardWidget extends ConsumerWidget {
  const ChessBoardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState state;
    try {
      state = ref.watch(gameProvider);
    } catch (e) {
      return const Center(
        child: Text('Error loading board',
            style: TextStyle(color: AppColors.textPrimary)),
      );
    }

    final notifier = ref.read(gameProvider.notifier);

    // Safety check: board must be 8x8
    if (state.board.length != 8 ||
        state.board.any((row) => row.length != 8)) {
      return const Center(
        child: Text('Initializing...',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final coordSize = 18.0;
        final boardSize = totalSize - coordSize;
        final squareSize = boardSize / 8;

        if (squareSize <= 0) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          width: totalSize,
          height: totalSize,
          child: Stack(
            children: [
              // Board with wood border
              Positioned(
                left: coordSize,
                top: 0,
                child: Container(
                  width: boardSize,
                  height: boardSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: const Color(0xFF8B6914),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        blurRadius: 2,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(1),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(8, (displayRow) {
                        final row =
                            state.boardFlipped ? 7 - displayRow : displayRow;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(8, (displayCol) {
                            final col = state.boardFlipped
                                ? 7 - displayCol
                                : displayCol;
                            final pos = BoardPosition(row, col);
                            final piece = state.board[row][col];

                            final isSelected = state.selectedSquare == pos;
                            final isValidMove =
                                state.validMoves.contains(pos);
                            final isLastMoveFrom =
                                state.lastMove?.from == pos;
                            final isLastMoveTo = state.lastMove?.to == pos;
                            final isCheckSquare = _isCheckSquare(
                                state.status,
                                state.currentTurn,
                                piece);

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
                ),
              ),
              // Rank labels (left side)
              Positioned(
                left: 0,
                top: 0,
                child: SizedBox(
                  width: coordSize,
                  height: boardSize,
                  child: Column(
                    children: List.generate(8, (i) {
                      final rank =
                          state.boardFlipped ? '${i + 1}' : '${8 - i}';
                      return SizedBox(
                        height: squareSize,
                        child: Center(
                          child: Text(
                            rank,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.goldDark.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              // File labels (bottom)
              Positioned(
                left: coordSize,
                bottom: 0,
                child: SizedBox(
                  width: boardSize,
                  height: coordSize,
                  child: Row(
                    children: List.generate(8, (i) {
                      const files = [
                        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'
                      ];
                      final file =
                          state.boardFlipped ? files[7 - i] : files[i];
                      return SizedBox(
                        width: squareSize,
                        child: Center(
                          child: Text(
                            file,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.goldDark.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isCheckSquare(
    GameStatus status,
    PlayerSide currentTurn,
    ChessPiece? piece,
  ) {
    if (status != GameStatus.check && status != GameStatus.checkmate) {
      return false;
    }
    if (piece == null) return false;
    return piece.type == PieceType.king && piece.side == currentTurn;
  }
}
