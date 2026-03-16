import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chess/app/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                      'Settings',
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
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSection('Game', [
                      _SettingsTile(
                        icon: Icons.palette_outlined,
                        title: 'Board Theme',
                        subtitle: 'Marble',
                        onTap: () {},
                      ),
                      _SettingsTile(
                        icon: Icons.volume_up_outlined,
                        title: 'Sound Effects',
                        subtitle: 'On',
                        onTap: () {},
                      ),
                      _SettingsTile(
                        icon: Icons.vibration_rounded,
                        title: 'Haptic Feedback',
                        subtitle: 'On',
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSection('Display', [
                      _SettingsTile(
                        icon: Icons.format_size_rounded,
                        title: 'Piece Style',
                        subtitle: 'Classic',
                        onTap: () {},
                      ),
                      _SettingsTile(
                        icon: Icons.grid_on_rounded,
                        title: 'Show Coordinates',
                        subtitle: 'On',
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSection('About', [
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        title: 'Version',
                        subtitle: '1.0.0',
                        onTap: () {},
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.cinzel(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.goldDark,
              letterSpacing: 2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.goldDark.withOpacity(0.2), width: 1),
          ),
          child: Column(
            children: tiles
                .expand((tile) => [
                      tile,
                      if (tile != tiles.last)
                        Divider(
                          height: 1,
                          indent: 56,
                          color: AppColors.divider.withOpacity(0.5),
                        ),
                    ])
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.goldDark, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.goldDark.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
