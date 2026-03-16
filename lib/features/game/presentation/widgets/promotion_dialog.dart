import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B4D37),
              Color(0xFF0A2E1F),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.goldDark.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 24,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Promote Pawn',
              style: GoogleFonts.cinzel(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.goldLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a piece',
              style: GoogleFonts.inter(
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
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: AppColors.textMuted),
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
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6B4C12),
                Color(0xFF4A3208),
              ],
            ),
            border: Border.all(
              color: AppColors.goldDark.withOpacity(0.6),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            _getSymbol(),
            style: TextStyle(
              fontSize: 36,
              color: side == PlayerSide.white
                  ? const Color(0xFFF5F0E0)
                  : const Color(0xFF1A1A1A),
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
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
