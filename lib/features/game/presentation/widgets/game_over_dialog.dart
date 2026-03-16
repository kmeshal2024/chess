import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B4D37),
              Color(0xFF0A2E1F),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _getAccentColor().withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.7),
              blurRadius: 32,
            ),
            BoxShadow(
              color: _getAccentColor().withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    _getAccentColor().withOpacity(0.3),
                    _getAccentColor().withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: _getAccentColor().withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: Icon(
                _getIcon(),
                color: _getAccentColor(),
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _getTitle(),
              style: GoogleFonts.cinzel(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: _getAccentColor(),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _getSubtitle(),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            // New Game button
            GestureDetector(
              onTap: onNewGame,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getAccentColor(),
                      Color.lerp(_getAccentColor(), Colors.black, 0.3)!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.goldDark.withOpacity(0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getAccentColor().withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'NEW GAME',
                    style: GoogleFonts.cinzel(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: onDismiss,
              child: Text(
                'Review Board',
                style: GoogleFonts.inter(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
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
        return AppColors.gold;
      case GameStatus.stalemate:
      case GameStatus.draw:
        return AppColors.textSecondary;
      default:
        return AppColors.gold;
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
