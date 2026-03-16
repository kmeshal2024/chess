import 'package:flutter/material.dart';
import 'package:chess/app/theme.dart';

class GameControls extends StatelessWidget {
  final VoidCallback onUndo;
  final VoidCallback onRestart;
  final VoidCallback onFlipBoard;
  final bool canUndo;
  final bool gameOver;

  const GameControls({
    super.key,
    required this.onUndo,
    required this.onRestart,
    required this.onFlipBoard,
    required this.canUndo,
    required this.gameOver,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ControlButton(
          icon: Icons.undo_rounded,
          label: 'Undo',
          onTap: canUndo ? onUndo : null,
        ),
        const SizedBox(width: 12),
        _ControlButton(
          icon: Icons.swap_vert_rounded,
          label: 'Flip',
          onTap: onFlipBoard,
        ),
        const SizedBox(width: 12),
        _ControlButton(
          icon: Icons.refresh_rounded,
          label: 'New Game',
          onTap: () => _confirmRestart(context),
          highlighted: gameOver,
        ),
      ],
    );
  }

  void _confirmRestart(BuildContext context) {
    if (gameOver) {
      onRestart();
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'New Game?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Current progress will be lost.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onRestart();
            },
            child: const Text('New Game'),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool highlighted;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Opacity(
      opacity: enabled ? 1.0 : 0.35,
      child: Material(
        color: highlighted
            ? AppColors.gold.withValues(alpha: 0.15)
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: highlighted
                      ? AppColors.gold
                      : AppColors.textSecondary,
                  size: 22,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: highlighted
                        ? AppColors.gold
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
