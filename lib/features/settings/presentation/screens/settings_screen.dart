import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chess/app/theme.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/board_theme_data.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

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
                          color: AppColors.surface.withValues(alpha: 0.5),
                          border: Border.all(
                              color: AppColors.goldDark.withValues(alpha: 0.3),
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
                        subtitle:
                            BoardThemeData.fromEnum(settings.boardTheme).label,
                        onTap: () =>
                            _showBoardThemeSheet(context, settings, notifier),
                      ),
                      _SettingsTile(
                        icon: Icons.volume_up_outlined,
                        title: 'Sound Effects',
                        subtitle: settings.soundEnabled ? 'On' : 'Off',
                        onTap: () => notifier.toggleSound(),
                      ),
                      _SettingsTile(
                        icon: Icons.vibration_rounded,
                        title: 'Haptic Feedback',
                        subtitle: settings.hapticEnabled ? 'On' : 'Off',
                        onTap: () => notifier.toggleHaptic(),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSection('Display', [
                      _SettingsTile(
                        icon: Icons.format_size_rounded,
                        title: 'Piece Style',
                        subtitle: settings.pieceStyle.name[0].toUpperCase() +
                            settings.pieceStyle.name.substring(1),
                        onTap: () =>
                            _showPieceStyleSheet(context, settings, notifier),
                      ),
                      _SettingsTile(
                        icon: Icons.grid_on_rounded,
                        title: 'Show Coordinates',
                        subtitle: settings.showCoordinates ? 'On' : 'Off',
                        onTap: () => notifier.toggleCoordinates(),
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

  void _showBoardThemeSheet(
      BuildContext context, AppSettings settings, dynamic notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Board Theme',
              style: GoogleFonts.cinzel(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.goldLight,
              ),
            ),
            const SizedBox(height: 16),
            ...BoardTheme.values.map((theme) {
              final data = BoardThemeData.fromEnum(theme);
              final isSelected = settings.boardTheme == theme;
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: isSelected
                        ? Border.all(color: AppColors.goldLight, width: 2)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: data.lightSquare,
                            borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(5)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: data.darkSquare,
                            borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(5)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                title: Text(
                  data.label,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.goldLight
                        : AppColors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle,
                        color: AppColors.goldLight, size: 22)
                    : null,
                onTap: () {
                  notifier.setBoardTheme(theme);
                  Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showPieceStyleSheet(
      BuildContext context, AppSettings settings, dynamic notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Piece Style',
              style: GoogleFonts.cinzel(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.goldLight,
              ),
            ),
            const SizedBox(height: 16),
            ...PieceStyle.values.map((style) {
              final isSelected = settings.pieceStyle == style;
              final label =
                  style.name[0].toUpperCase() + style.name.substring(1);
              return ListTile(
                leading: Icon(
                  Icons.extension_rounded,
                  color:
                      isSelected ? AppColors.goldLight : AppColors.textMuted,
                ),
                title: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.goldLight
                        : AppColors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle,
                        color: AppColors.goldLight, size: 22)
                    : null,
                onTap: () {
                  notifier.setPieceStyle(style);
                  Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 8),
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
            color: AppColors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.goldDark.withValues(alpha: 0.2), width: 1),
          ),
          child: Column(
            children: tiles
                .expand((tile) => [
                      tile,
                      if (tile != tiles.last)
                        Divider(
                          height: 1,
                          indent: 56,
                          color: AppColors.divider.withValues(alpha: 0.5),
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
              color: AppColors.goldDark.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
