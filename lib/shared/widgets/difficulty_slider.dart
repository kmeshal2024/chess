import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chess/app/theme.dart';

class DifficultySlider extends StatelessWidget {
  final int level;
  final int maxLevel;
  final ValueChanged<int> onChanged;

  const DifficultySlider({
    super.key,
    required this.level,
    this.maxLevel = 5,
    required this.onChanged,
  });

  String get _levelName {
    switch (level) {
      case 1:
        return 'BEGINNER';
      case 2:
        return 'EASY';
      case 3:
        return 'MIDDLE';
      case 4:
        return 'HARD';
      case 5:
        return 'EXPERT';
      default:
        return 'MIDDLE';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up_rounded,
                color: AppColors.goldLight.withOpacity(0.7), size: 18),
            const SizedBox(width: 8),
            Text(
              'Difficulty level',
              style: GoogleFonts.cinzel(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Level number and name
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left arrow
            GestureDetector(
              onTap: level > 1 ? () => onChanged(level - 1) : null,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: level > 1
                      ? AppColors.goldDark.withOpacity(0.3)
                      : Colors.transparent,
                ),
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: level > 1
                      ? AppColors.goldLight
                      : AppColors.textMuted.withOpacity(0.3),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Level display
            Column(
              children: [
                Text(
                  '$level',
                  style: GoogleFonts.cinzel(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.goldLight,
                    shadows: [
                      Shadow(
                        color: AppColors.gold.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                Text(
                  '- $_levelName -',
                  style: GoogleFonts.cinzel(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Right arrow
            GestureDetector(
              onTap: level < maxLevel ? () => onChanged(level + 1) : null,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: level < maxLevel
                      ? AppColors.goldDark.withOpacity(0.3)
                      : Colors.transparent,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: level < maxLevel
                      ? AppColors.goldLight
                      : AppColors.textMuted.withOpacity(0.3),
                  size: 24,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Difficulty dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(maxLevel, (i) {
            final isActive = i < level;
            return Container(
              width: 32,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: isActive
                    ? AppColors.goldDark
                    : AppColors.textMuted.withOpacity(0.2),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.gold.withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }
}
