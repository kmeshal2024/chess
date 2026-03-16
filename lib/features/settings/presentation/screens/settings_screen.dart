import 'package:flutter/material.dart';
import 'package:chess/app/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection('Game', [
              _SettingsTile(
                icon: Icons.palette_outlined,
                title: 'Board Theme',
                subtitle: 'Classic',
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
                subtitle: 'Standard',
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
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: tiles
                .map((tile) => tile)
                .expand((tile) => [
                      tile,
                      if (tile != tiles.last)
                        const Divider(
                          height: 1,
                          indent: 56,
                          color: AppColors.divider,
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
            Icon(icon, color: AppColors.textSecondary, size: 22),
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
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
