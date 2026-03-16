import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chess/app/theme.dart';

class OnlinePlaceholderScreen extends StatelessWidget {
  const OnlinePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [
              Color(0xFF143D2B),
              Color(0xFF0A2E1F),
              Color(0xFF071F15),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface.withOpacity(0.5),
                          border: Border.all(
                              color: AppColors.goldDark.withOpacity(0.3),
                              width: 1.5),
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: AppColors.goldLight, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Online Play',
                      style: GoogleFonts.cinzel(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.goldLight,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Spacer(),
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.gold.withOpacity(0.2),
                              AppColors.gold.withOpacity(0.05),
                            ],
                          ),
                          border: Border.all(
                              color: AppColors.goldDark.withOpacity(0.3),
                              width: 2),
                        ),
                        child: const Icon(
                          Icons.language_rounded,
                          color: AppColors.goldLight,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Online Play',
                        style: GoogleFonts.cinzel(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.goldLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Challenge players worldwide with real-time\nmatchmaking, private rooms, and ranked play.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.goldDark.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.construction_rounded,
                              color: AppColors.goldLight,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Coming in the next update',
                              style: GoogleFonts.cinzel(
                                color: AppColors.goldLight,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
