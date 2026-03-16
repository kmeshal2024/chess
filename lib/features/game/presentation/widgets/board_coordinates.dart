import 'package:flutter/material.dart';
import 'package:chess/app/theme.dart';

class BoardCoordinates extends StatelessWidget {
  final double boardSize;
  final bool flipped;

  const BoardCoordinates({
    super.key,
    required this.boardSize,
    this.flipped = false,
  });

  @override
  Widget build(BuildContext context) {
    final squareSize = boardSize / 8;
    const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    const ranks = ['8', '7', '6', '5', '4', '3', '2', '1'];

    final displayFiles = flipped ? files.reversed.toList() : files;
    final displayRanks = flipped ? ranks.reversed.toList() : ranks;

    return SizedBox(
      width: boardSize + 24,
      height: boardSize + 24,
      child: Stack(
        children: [
          // File labels (bottom)
          Positioned(
            left: 20,
            bottom: 0,
            child: Row(
              children: displayFiles.map((f) {
                return SizedBox(
                  width: squareSize,
                  height: 18,
                  child: Center(
                    child: Text(
                      f,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Rank labels (left)
          Positioned(
            left: 0,
            top: 4,
            child: Column(
              children: displayRanks.map((r) {
                return SizedBox(
                  width: 16,
                  height: squareSize,
                  child: Center(
                    child: Text(
                      r,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Board area
          Positioned(
            left: 20,
            top: 4,
            child: SizedBox(
              width: boardSize,
              height: boardSize,
            ),
          ),
        ],
      ),
    );
  }
}
