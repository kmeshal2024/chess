import 'package:flutter/material.dart';
import 'package:chess/app/theme.dart';
import 'package:chess/core/enums.dart';

class GameStatusBar extends StatelessWidget {
  final PlayerSide currentTurn;
  final GameStatus status;

  const GameStatusBar({
    super.key,
    required this.currentTurn,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTurnIndicator(),
          const SizedBox(width: 10),
          Text(
            _getStatusText(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnIndicator() {
    if (status == GameStatus.checkmate ||
        status == GameStatus.stalemate ||
        status == GameStatus.draw) {
      return Icon(
        status == GameStatus.checkmate
            ? Icons.emoji_events_rounded
            : Icons.handshake_rounded,
        color: _getStatusColor(),
        size: 18,
      );
    }

    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: currentTurn == PlayerSide.white
            ? const Color(0xFFF0F0E8)
            : const Color(0xFF2A2A2A),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.textMuted,
          width: 1.5,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case GameStatus.check:
        return AppColors.error;
      case GameStatus.checkmate:
        return AppColors.accent;
      case GameStatus.stalemate:
      case GameStatus.draw:
        return AppColors.textSecondary;
      default:
        return AppColors.textPrimary;
    }
  }

  String _getStatusText() {
    switch (status) {
      case GameStatus.playing:
        return "${currentTurn.label}'s turn";
      case GameStatus.check:
        return "${currentTurn.label} is in check!";
      case GameStatus.checkmate:
        return "${currentTurn.opposite.label} wins by checkmate!";
      case GameStatus.stalemate:
        return 'Stalemate — Draw';
      case GameStatus.draw:
        return 'Game drawn';
      case GameStatus.resigned:
        return '${currentTurn.opposite.label} wins by resignation';
      case GameStatus.idle:
        return 'Ready to play';
    }
  }
}
