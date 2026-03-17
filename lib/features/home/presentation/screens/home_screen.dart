import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chess/app/router.dart';
import 'package:chess/app/theme.dart';
import 'package:chess/core/enums.dart';
import 'package:chess/shared/widgets/wood_panel.dart';
import 'package:chess/shared/widgets/gold_button.dart';
import 'package:chess/shared/widgets/difficulty_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedSide = 0; // 0=white, 1=random, 2=black
  int _difficulty = 3;
  int _gamesWon = 0;
  int _gamesDraw = 0;
  int _gamesLost = 0;

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
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildTitle(),
                      const SizedBox(height: 20),
                      _buildMainPanel(),
                      const SizedBox(height: 24),
                      _buildPlayButton(),
                      const SizedBox(height: 16),
                      _buildOnlineButton(),
                      const SizedBox(height: 24),
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

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF6B4C12), Color(0xFF4A3208)],
              ),
              border: Border.all(color: AppColors.goldDark, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const Center(
              child: Text('\u2654',
                  style: TextStyle(fontSize: 22, color: AppColors.goldLight)),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'ChessMate',
            style: GoogleFonts.cinzel(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.goldLight,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRouter.settings),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface.withValues(alpha: 0.5),
                border: Border.all(
                    color: AppColors.goldDark.withValues(alpha: 0.3), width: 1.5),
              ),
              child: const Icon(Icons.settings_rounded,
                  color: AppColors.goldLight, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.goldDark.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'PLAY VS COMPUTER',
            style: GoogleFonts.cinzel(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.goldLight,
              letterSpacing: 2,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.goldDark.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainPanel() {
    return WoodPanel(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          Text(
            'Play as',
            style: GoogleFonts.cinzel(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildPieceSelector(),
          const SizedBox(height: 28),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.goldDark.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          DifficultySlider(
            level: _difficulty,
            onChanged: (val) => setState(() => _difficulty = val),
          ),
          const SizedBox(height: 24),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.goldDark.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildPieceSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPieceOption(0, '\u2654', 'White', const Color(0xFFF0ECE0)),
        _buildPieceOption(1, '\u265A', 'Random', AppColors.textSecondary),
        _buildPieceOption(2, '\u265A', 'Black', const Color(0xFF2A2A2A)),
      ],
    );
  }

  Widget _buildPieceOption(
      int index, String piece, String label, Color pieceColor) {
    final isSelected = _selectedSide == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedSide = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? AppColors.goldDark.withValues(alpha: 0.25)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AppColors.goldDark.withValues(alpha: 0.7)
                : AppColors.textMuted.withValues(alpha: 0.15),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == 1
                    ? AppColors.surface.withValues(alpha: 0.5)
                    : (index == 0
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.3)),
                border: Border.all(
                  color: isSelected
                      ? AppColors.goldDark
                      : AppColors.textMuted.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  index == 1 ? '?' : piece,
                  style: TextStyle(
                    fontSize: index == 1 ? 28 : 34,
                    color: index == 1 ? AppColors.goldLight : pieceColor,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 4,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.cinzel(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color:
                    isSelected ? AppColors.goldLight : AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final totalGames = _gamesWon + _gamesDraw + _gamesLost;
    final winRate = totalGames > 0
        ? ((_gamesWon / totalGames) * 100).toStringAsFixed(0)
        : '0';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('Games Won', '$_gamesWon', AppColors.success),
        _buildStatItem('Games Draw', '$_gamesDraw', AppColors.textSecondary),
        _buildStatItem('Games Lost', '$_gamesLost', AppColors.error),
        _buildStatItem('Win Rate', '$winRate%', AppColors.goldLight),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.cinzel(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    return SizedBox(
      width: double.infinity,
      child: GoldButton(
        label: 'PLAY NOW',
        icon: Icons.play_arrow_rounded,
        isLarge: true,
        backgroundColor: const Color(0xFF4CAF50),
        onTap: () {
          PlayerSide playerSide;
          if (_selectedSide == 0) {
            playerSide = PlayerSide.white;
          } else if (_selectedSide == 2) {
            playerSide = PlayerSide.black;
          } else {
            playerSide =
                Random().nextBool() ? PlayerSide.white : PlayerSide.black;
          }
          Navigator.pushNamed(
            context,
            AppRouter.game,
            arguments: {
              'mode': GameMode.ai,
              'side': playerSide,
              'difficulty': _difficulty,
            },
          );
        },
      ),
    );
  }

  Widget _buildOnlineButton() {
    return SizedBox(
      width: double.infinity,
      child: GoldButton(
        label: 'PLAY ONLINE',
        icon: Icons.language_rounded,
        isLarge: true,
        backgroundColor: const Color(0xFF2196F3),
        onTap: () => Navigator.pushNamed(context, AppRouter.online),
      ),
    );
  }
}
