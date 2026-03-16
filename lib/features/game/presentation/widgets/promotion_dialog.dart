import 'package:flutter/material.dart';
import 'package:chess/app/theme.dart';
import 'package:chess/core/enums.dart';

class PromotionDialog extends StatelessWidget {
  final PlayerSide side;
  final void Function(PieceType) onSelect;
  final VoidCallback onCancel;

  const PromotionDialog({
    super.key,
    required this.side,
    required this.onSelect,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 24,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Promote Pawn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose a piece',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PromotionOption(
                  type: PieceType.queen,
                  side: side,
                  onTap: () => onSelect(PieceType.queen),
                ),
                _PromotionOption(
                  type: PieceType.rook,
                  side: side,
                  onTap: () => onSelect(PieceType.rook),
                ),
                _PromotionOption(
                  type: PieceType.bishop,
                  side: side,
                  onTap: () => onSelect(PieceType.bishop),
                ),
                _PromotionOption(
                  type: PieceType.knight,
                  side: side,
                  onTap: () => onSelect(PieceType.knight),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: onCancel,
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromotionOption extends StatelessWidget {
  final PieceType type;
  final PlayerSide side;
  final VoidCallback onTap;

  const _PromotionOption({
    required this.type,
    required this.side,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          child: Text(
            _getSymbol(),
            style: TextStyle(
              fontSize: 36,
              color: side == PlayerSide.white
                  ? const Color(0xFFF0F0E8)
                  : const Color(0xFF2A2A2A),
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 2,
                  offset: const Offset(0.5, 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getSymbol() {
    switch (type) {
      case PieceType.queen:
        return '♛';
      case PieceType.rook:
        return '♜';
      case PieceType.bishop:
        return '♝';
      case PieceType.knight:
        return '♞';
      default:
        return '';
    }
  }
}
