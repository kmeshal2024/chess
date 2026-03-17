import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chess/app/theme.dart';
import 'package:chess/app/router.dart';
import 'package:chess/core/enums.dart';
import 'package:chess/shared/widgets/gold_button.dart';
import 'package:chess/shared/widgets/player_avatar.dart';
import '../providers/game_provider.dart';
import '../providers/game_state.dart';
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
    final GameState state;
    try {
      state = ref.watch(gameProvider);
    } catch (e) {
      return _buildErrorScreen('Failed to load game: $e');
    }

    final notifier = ref.read(gameProvider.notifier);

    // Show promotion dialog
    if (state.awaitingPromotion) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showPromotionDialog(context, state.currentTurn, notifier);
        }
      });
    }

    // Show game over dialog
    final isGameOver = state.status == GameStatus.checkmate ||
        state.status == GameStatus.stalemate ||
        state.status == GameStatus.draw;

    if (isGameOver && !_gameOverDialogShown) {
      _gameOverDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showGameOverDialog(
              context, state.status, state.currentTurn, notifier);
        }
      });
    } else if (!isGameOver) {
      _gameOverDialogShown = false;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final maxBoardSize = screenWidth - 32;

              return Column(
                children: [
                  // Top bar
                  _buildTopBar(context, state),

                  // Turn indicator dots
                  _buildTurnIndicator(state),
                  const SizedBox(height: 4),

                  // Status text
                  _buildStatusText(state),
                  const SizedBox(height: 8),

                  // Chess board - adaptive size
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: maxBoardSize,
                              maxHeight: maxBoardSize,
                            ),
                            child: const ChessBoardWidget(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Bottom controls
                  _buildGameControls(context, notifier, state, isGameOver),
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(color: AppColors.textPrimary),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, GameState state) {
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
                color: AppColors.surface.withValues(alpha: 0.5),
                border: Border.all(
                    color: AppColors.goldDark.withValues(alpha: 0.3),
                    width: 1.5),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.goldLight, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          const PlayerAvatar(size: 44, icon: Icons.person),
          const Spacer(),
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
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRouter.settings),
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
              child: const Icon(Icons.settings_rounded,
                  color: AppColors.goldLight, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnIndicator(GameState state) {
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
                ? AppColors.error.withValues(alpha: 0.8)
                : AppColors.goldLight.withValues(alpha: 0.5),
            boxShadow: isCheck
                ? [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.4),
                      blurRadius: 4,
                    ),
                  ]
                : [],
          ),
        );
      }),
    );
  }

  Widget _buildStatusText(GameState state) {
    String text = "White's Turn";
    Color color = AppColors.textPrimary;

    if (state.status == GameStatus.playing) {
      text = "${state.currentTurn.label}'s Turn";
      color = AppColors.textPrimary;
    } else if (state.status == GameStatus.check) {
      text = "${state.currentTurn.label} is in Check!";
      color = AppColors.error;
    } else if (state.status == GameStatus.checkmate) {
      text = "${state.currentTurn.opposite.label} Wins!";
      color = AppColors.goldLight;
    } else if (state.status == GameStatus.stalemate) {
      text = 'Stalemate';
      color = AppColors.textSecondary;
    } else if (state.status == GameStatus.draw) {
      text = 'Draw';
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
      BuildContext context, dynamic notifier, GameState state, bool isGameOver) {
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
            icon: state.isLoadingHint
                ? Icons.hourglass_top_rounded
                : Icons.lightbulb_rounded,
            label: 'Hint',
            badgeText: '${state.hintsRemaining}',
            onTap: state.hintsRemaining > 0 && !isGameOver && !state.isLoadingHint
                ? () => notifier.requestHint()
                : null,
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
