import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chess/app/theme.dart';
import 'package:chess/core/enums.dart';
import 'package:chess/shared/widgets/gold_button.dart';
import 'package:chess/shared/widgets/player_avatar.dart';
import '../providers/game_provider.dart';
import '../widgets/chess_board_widget.dart';
import '../widgets/promotion_dialog.dart';
import '../widgets/game_over_dialog.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _gameOverDialogShown = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);

    // Show promotion dialog
    if (state.awaitingPromotion) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPromotionDialog(context, state.currentTurn, notifier);
      });
    }

    // Show game over dialog
    final isGameOver = state.status == GameStatus.checkmate ||
        state.status == GameStatus.stalemate ||
        state.status == GameStatus.draw;

    if (isGameOver && !_gameOverDialogShown) {
      _gameOverDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGameOverDialog(
            context, state.status, state.currentTurn, notifier);
      });
    } else if (!isGameOver) {
      _gameOverDialogShown = false;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = screenWidth - 32;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
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
              // Top bar with avatar and settings
              _buildTopBar(context, state),
              const SizedBox(height: 4),

              // Turn indicator dots
              _buildTurnIndicator(state),
              const SizedBox(height: 8),

              // Status text
              _buildStatusText(state),
              const SizedBox(height: 8),

              // Chess board
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: boardSize,
                  height: boardSize,
                  child: const ChessBoardWidget(),
                ),
              ),

              const Spacer(),

              // Bottom controls
              _buildGameControls(context, notifier, state, isGameOver),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, dynamic state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () =>
                _confirmExit(context, state.moveHistory.isNotEmpty),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface.withOpacity(0.5),
                border: Border.all(
                    color: AppColors.goldDark.withOpacity(0.3), width: 1.5),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.goldLight, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          // Player avatar
          const PlayerAvatar(size: 44, icon: Icons.person),
          const Spacer(),
          // Title
          Text(
            'GAME',
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.goldLight,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          // Settings gear
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface.withOpacity(0.5),
                border: Border.all(
                    color: AppColors.goldDark.withOpacity(0.3), width: 1.5),
              ),
              child: const Icon(Icons.settings_rounded,
                  color: AppColors.goldLight, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnIndicator(dynamic state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final isCheck = state.status == GameStatus.check ||
            state.status == GameStatus.checkmate;
        return Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCheck
                ? AppColors.error.withOpacity(0.8)
                : AppColors.goldLight.withOpacity(0.5),
            boxShadow: [
              if (isCheck)
                BoxShadow(
                  color: AppColors.error.withOpacity(0.4),
                  blurRadius: 4,
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusText(dynamic state) {
    String text;
    Color color;

    switch (state.status) {
      case GameStatus.playing:
        text = "${state.currentTurn.label}'s Turn";
        color = AppColors.textPrimary;
        break;
      case GameStatus.check:
        text = "${state.currentTurn.label} is in Check!";
        color = AppColors.error;
        break;
      case GameStatus.checkmate:
        text = "${state.currentTurn.opposite.label} Wins!";
        color = AppColors.goldLight;
        break;
      case GameStatus.stalemate:
        text = 'Stalemate';
        color = AppColors.textSecondary;
        break;
      case GameStatus.draw:
        text = 'Draw';
        color = AppColors.textSecondary;
        break;
      default:
        text = 'Ready';
        color = AppColors.textSecondary;
    }

    return Text(
      text,
      style: GoogleFonts.cinzel(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildGameControls(
      BuildContext context, dynamic notifier, dynamic state, bool isGameOver) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircularGameButton(
            icon: Icons.refresh_rounded,
            label: 'Restart',
            onTap: () => _confirmRestart(context, notifier, isGameOver),
          ),
          CircularGameButton(
            icon: Icons.castle_rounded,
            label: 'Pieces',
            onTap: () => notifier.flipBoard(),
          ),
          CircularGameButton(
            icon: Icons.undo_rounded,
            label: 'Undo',
            onTap: state.moveHistory.isNotEmpty && !isGameOver
                ? () => notifier.undoMove()
                : null,
          ),
          CircularGameButton(
            icon: Icons.lightbulb_rounded,
            label: 'Hint',
            badgeText: '4',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _confirmRestart(
      BuildContext context, dynamic notifier, bool isGameOver) {
    if (isGameOver) {
      notifier.restartGame();
      _gameOverDialogShown = false;
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'New Game?',
          style: GoogleFonts.cinzel(color: AppColors.goldLight),
        ),
        content: const Text(
          'Current progress will be lost.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              notifier.restartGame();
            },
            child: const Text('New Game',
                style: TextStyle(color: AppColors.goldLight)),
          ),
        ],
      ),
    );
  }

  void _showPromotionDialog(
    BuildContext context,
    PlayerSide side,
    dynamic notifier,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PromotionDialog(
        side: side,
        onSelect: (type) {
          Navigator.pop(context);
          notifier.completePromotion(type);
        },
        onCancel: () {
          Navigator.pop(context);
          notifier.cancelPromotion();
        },
      ),
    );
  }

  void _showGameOverDialog(
    BuildContext context,
    GameStatus status,
    PlayerSide currentTurn,
    dynamic notifier,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => GameOverDialog(
        status: status,
        currentTurn: currentTurn,
        onNewGame: () {
          Navigator.pop(context);
          notifier.restartGame();
          _gameOverDialogShown = false;
        },
        onDismiss: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _confirmExit(BuildContext context, bool hasProgress) {
    if (!hasProgress) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Leave Game?',
          style: GoogleFonts.cinzel(color: AppColors.goldLight),
        ),
        content: const Text(
          'Current game progress will be lost.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Stay',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Leave',
                style: TextStyle(color: AppColors.goldLight)),
          ),
        ],
      ),
    );
  }
}
