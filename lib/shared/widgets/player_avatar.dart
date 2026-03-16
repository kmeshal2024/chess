import 'package:flutter/material.dart';
import 'package:chess/app/theme.dart';

class PlayerAvatar extends StatelessWidget {
  final double size;
  final IconData icon;

  const PlayerAvatar({
    super.key,
    this.size = 48,
    this.icon = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6B4C12),
            Color(0xFF4A3208),
          ],
        ),
        border: Border.all(
          color: AppColors.goldDark,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: AppColors.gold.withOpacity(0.2),
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: AppColors.goldLight,
        size: size * 0.55,
      ),
    );
  }
}
