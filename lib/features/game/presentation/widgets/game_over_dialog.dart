import 'package:flutter/material.dart';
import 'package:chess/app/theme.dart';
import 'package:chess/core/enums.dart';

class GameOverDialog extends StatelessWidget {
  final GameStatus status;
  final PlayerSide currentTurn;
  final VoidCallback onNewGame;
  final VoidCallback onDismiss;

  const GameOverDialog({
    super.key,
    required this.status,
    required this.currentTurn,
    required this.onNewGame,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _getAccentColor().withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 32,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _getAccentColor().withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(),
                color: _getAccentColor(),
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _getTitle(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getSubtitle(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNewGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getAccentColor(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'New Game',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onDismiss,
              child: const Text(
                'Review Board',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAccentColor() {
    switch (status) {
      case GameStatus.checkmate:
        return AppColors.accent;
      case GameStatus.stalemate:
      case GameStatus.draw:
        return AppColors.textSecondary;
      default:
        return AppColors.primary;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case GameStatus.checkmate:
        return Icons.emoji_events_rounded;
      case GameStatus.stalemate:
      case GameStatus.draw:
        return Icons.handshake_rounded;
      default:
        return Icons.sports_esports_rounded;
    }
  }

  String _getTitle() {
    switch (status) {
      case GameStatus.checkmate:
        return 'Checkmate!';
      case GameStatus.stalemate:
        return 'Stalemate';
      case GameStatus.draw:
        return 'Draw';
      default:
        return 'Game Over';
    }
  }

  String _getSubtitle() {
    switch (status) {
      case GameStatus.checkmate:
        return '${currentTurn.opposite.label} wins the game!';
      case GameStatus.stalemate:
        return 'No legal moves available.\nThe game is a draw.';
      case GameStatus.draw:
        return 'The game has ended in a draw.';
      default:
        return '';
    }
  }
}
