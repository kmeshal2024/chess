import 'package:flutter/material.dart';
import 'package:chess/app/theme.dart';

class WoodPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final double goldBorderWidth;

  const WoodPanel({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.goldBorderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6B4C12),
            Color(0xFF4A3208),
            Color(0xFF5C3D10),
            Color(0xFF3D2A06),
          ],
          stops: [0.0, 0.35, 0.65, 1.0],
        ),
        border: Border.all(
          color: AppColors.goldDark.withOpacity(0.6),
          width: goldBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.goldDark.withOpacity(0.15),
            blurRadius: 1,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - goldBorderWidth),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.transparent,
                Colors.black.withOpacity(0.1),
              ],
              stops: const [0.0, 0.3, 1.0],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
