import 'package:flutter/material.dart';
import 'package:chess/app/router.dart';
import 'package:chess/app/theme.dart';
import 'package:chess/core/constants.dart';
import '../widgets/menu_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildHeader(),
              const SizedBox(height: 48),
              _buildMenuSection(context),
              const Spacer(),
              _buildFooter(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.accentLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  '♔',
                  style: TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Play. Learn. Compete.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'PLAY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 1.5,
            ),
          ),
        ),
        MenuCard(
          title: 'Local Game',
          subtitle: 'Play on the same device against a friend',
          icon: Icons.people_outline_rounded,
          accentColor: AppColors.primary,
          onTap: () => Navigator.pushNamed(context, AppRouter.game),
        ),
        const SizedBox(height: 12),
        MenuCard(
          title: 'Online Match',
          subtitle: 'Challenge players around the world',
          icon: Icons.language_rounded,
          accentColor: AppColors.accent,
          badge: 'SOON',
          enabled: true,
          onTap: () => Navigator.pushNamed(context, AppRouter.online),
        ),
        const SizedBox(height: 12),
        MenuCard(
          title: 'vs Computer',
          subtitle: 'Test your skills against the AI',
          icon: Icons.smart_toy_outlined,
          accentColor: AppColors.success,
          badge: 'SOON',
          enabled: false,
          onTap: () {},
        ),
        const SizedBox(height: 32),
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'MORE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 1.5,
            ),
          ),
        ),
        MenuCard(
          title: 'Settings',
          subtitle: 'App preferences and customization',
          icon: Icons.tune_rounded,
          accentColor: AppColors.textSecondary,
          onTap: () => Navigator.pushNamed(context, AppRouter.settings),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return const Center(
      child: Text(
        'v1.0.0',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
