import 'package:flutter/material.dart';
import 'package:chess/app/theme.dart';
import '../../domain/entities/chess_move.dart';

class MoveListWidget extends StatelessWidget {
  final List<ChessMove> moves;
  final ScrollController? scrollController;

  const MoveListWidget({
    super.key,
    required this.moves,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (moves.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text(
            'No moves yet',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    // Group moves into pairs (white, black)
    final movePairs = <_MovePair>[];
    for (int i = 0; i < moves.length; i += 2) {
      movePairs.add(_MovePair(
        number: (i ~/ 2) + 1,
        whiteMove: moves[i],
        blackMove: i + 1 < moves.length ? moves[i + 1] : null,
      ));
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 120),
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: movePairs.length,
        itemBuilder: (context, index) {
          final pair = movePairs[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    '${pair.number}.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    pair.whiteMove.san,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    pair.blackMove?.san ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MovePair {
  final int number;
  final ChessMove whiteMove;
  final ChessMove? blackMove;

  const _MovePair({
    required this.number,
    required this.whiteMove,
    this.blackMove,
  });
}
