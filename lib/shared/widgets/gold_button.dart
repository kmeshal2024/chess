import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chess/app/theme.dart';

class GoldButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isLarge;
  final Color? backgroundColor;
  final Color? textColor;

  const GoldButton({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    this.isLarge = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<GoldButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? const Color(0xFF4CAF50);
    final fgColor = widget.textColor ?? Colors.white;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(_pressed ? 0.96 : 1.0),
        padding: EdgeInsets.symmetric(
          horizontal: widget.isLarge ? 48 : 24,
          vertical: widget.isLarge ? 18 : 14,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              bgColor,
              Color.lerp(bgColor, Colors.black, 0.25)!,
            ],
          ),
          borderRadius: BorderRadius.circular(widget.isLarge ? 14 : 10),
          border: Border.all(
            color: AppColors.goldDark.withOpacity(0.7),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.4),
              blurRadius: _pressed ? 4 : 8,
              offset: Offset(0, _pressed ? 1 : 3),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: fgColor, size: widget.isLarge ? 24 : 20),
              const SizedBox(width: 10),
            ],
            Text(
              widget.label,
              style: GoogleFonts.cinzel(
                fontSize: widget.isLarge ? 20 : 15,
                fontWeight: FontWeight.w800,
                color: fgColor,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularGameButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final String? badgeText;
  final double size;

  const CircularGameButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.badgeText,
    this.size = 64,
  });

  @override
  State<CircularGameButton> createState() => _CircularGameButtonState();
}

class _CircularGameButtonState extends State<CircularGameButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap!();
            }
          : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: widget.size,
                  height: widget.size,
                  transform: Matrix4.identity()
                    ..scale(_pressed ? 0.92 : 1.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF7A5A1A),
                        Color(0xFF4A3208),
                        Color(0xFF3D2A06),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.goldDark.withOpacity(0.8),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: _pressed ? 2 : 6,
                        offset: Offset(0, _pressed ? 1 : 3),
                      ),
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.15),
                        blurRadius: 1,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    color: AppColors.goldLight,
                    size: widget.size * 0.42,
                  ),
                ),
                // Badge
                if (widget.badgeText != null)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.backgroundDark,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        widget.badgeText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.label.toUpperCase(),
              style: GoogleFonts.cinzel(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
