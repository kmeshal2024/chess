import 'package:flutter/material.dart';
import 'package:chess/app/theme.dart';

class OnlinePlaceholderScreen extends StatelessWidget {
  const OnlinePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Play'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: AppColors.accent,
                  size: 48,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Online Play',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Challenge players worldwide with real-time\nmatchmaking, private rooms, and ranked play.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              _buildFeatureRow(Icons.bolt_rounded, 'Real-time matchmaking'),
              const SizedBox(height: 16),
              _buildFeatureRow(Icons.lock_outline_rounded, 'Private rooms'),
              const SizedBox(height: 16),
              _buildFeatureRow(Icons.leaderboard_rounded, 'Elo ranking system'),
              const SizedBox(height: 16),
              _buildFeatureRow(Icons.timer_outlined, 'Blitz, Rapid & Classical'),
              const SizedBox(height: 16),
              _buildFeatureRow(Icons.visibility_rounded, 'Spectator mode'),
              const SizedBox(height: 48),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.2),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.construction_rounded,
                      color: AppColors.accent,
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Coming in the next update',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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
    );
  }

  Widget _buildFeatureRow(IconData icon, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.textMuted, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
