import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess/app/theme.dart';
import 'package:chess/core/enums.dart';
import '../providers/game_provider.dart';
import '../widgets/chess_board_widget.dart';
import '../widgets/captured_pieces_widget.dart';
import '../widgets/move_list_widget.dart';
import '../widgets/game_status_bar.dart';
import '../widgets/game_controls.dart';
import '../widgets/promotion_dialog.dart';
import '../widgets/game_over_dialog.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final _moveListScrollController = ScrollController();
  bool _gameOverDialogShown = false;

  @override
  void dispose() {
    _moveListScrollController.dispose();
    super.dispose();
  }

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
        _showGameOverDialog(context, state.status, state.currentTurn, notifier);
      });
    } else if (!isGameOver) {
      _gameOverDialogShown = false;
    }

    // Auto-scroll move list
    if (state.moveHistory.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_moveListScrollController.hasClients) {
          _moveListScrollController.animateTo(
            _moveListScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = screenWidth - 32;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Game'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => _confirmExit(context, state.moveHistory.isNotEmpty),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Status bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GameStatusBar(
                currentTurn: state.currentTurn,
                status: state.status,
              ),
            ),
            const SizedBox(height: 12),

            // Top captured pieces (black's captures, shown when board not flipped)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CapturedPiecesWidget(
                pieces: state.boardFlipped
                    ? state.capturedByWhite
                    : state.capturedByBlack,
                side: state.boardFlipped ? PlayerSide.white : PlayerSide.black,
                materialAdvantage: state.materialAdvantageWhite,
              ),
            ),
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
            const SizedBox(height: 8),

            // Bottom captured pieces
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CapturedPiecesWidget(
                pieces: state.boardFlipped
                    ? state.capturedByBlack
                    : state.capturedByWhite,
                side: state.boardFlipped ? PlayerSide.black : PlayerSide.white,
                materialAdvantage: state.materialAdvantageWhite,
              ),
            ),
            const SizedBox(height: 8),

            // Move list
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.divider,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(12, 10, 12, 0),
                      child: Text(
                        'MOVES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Expanded(
                      child: MoveListWidget(
                        moves: state.moveHistory,
                        scrollController: _moveListScrollController,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GameControls(
                onUndo: () => notifier.undoMove(),
                onRestart: () => notifier.restartGame(),
                onFlipBoard: () => notifier.flipBoard(),
                canUndo: state.moveHistory.isNotEmpty && !isGameOver,
                gameOver: isGameOver,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
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
        title: const Text(
          'Leave Game?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Current game progress will be lost.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}
