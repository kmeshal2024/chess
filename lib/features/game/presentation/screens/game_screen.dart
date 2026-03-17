import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chess/app/theme.dart';
import 'package:chess/app/router.dart';
import 'package:chess/core/enums.dart';
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
  bool _gameConfigured = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_gameConfigured) {
      _gameConfigured = true;
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['mode'] == GameMode.ai) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(gameProvider.notifier).configureAiGame(
                  playerSide: args['side'] as PlayerSide,
                  difficulty: args['difficulty'] as int,
                );
          }
        });
      }
    }
  }

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
        state.status == GameStatus.draw ||
        state.status == GameStatus.resigned;

    if (isGameOver && !_gameOverDialogShown) {
      _gameOverDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showGameOverDialog(context, state, notifier);
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
          child: Column(
            children: [
              _buildTopBar(context, state),
              _buildPlayerBar(state, isOpponent: true),
              const SizedBox(height: 4),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: const ChessBoardWidget(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              _buildPlayerBar(state, isOpponent: false),
              if (state.moveHistory.isNotEmpty) _buildMoveList(state),
              _buildGameControls(context, notifier, state, isGameOver),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // --- Player bar with captured pieces ---
  Widget _buildPlayerBar(GameState state, {required bool isOpponent}) {
    final isAi = state.gameMode == GameMode.ai;
    final bool isWhiteBar;
    if (state.boardFlipped) {
      isWhiteBar = isOpponent ? false : true;
    } else {
      isWhiteBar = isOpponent ? true : false;
    }

    final barSide = isWhiteBar ? PlayerSide.white : PlayerSide.black;
    final captured = isWhiteBar ? state.capturedByBlack : state.capturedByWhite;
    final isActive = state.currentTurn == barSide && !state.isAiThinking;
    final materialAdv = state.materialAdvantageWhite;
    final advantage = isWhiteBar ? materialAdv : -materialAdv;

    String playerName;
    if (isAi) {
      playerName = (barSide != state.playerSide) ? 'AI Engine' : 'You';
    } else {
      playerName = barSide == PlayerSide.white ? 'White' : 'Black';
    }

    final pieceIcon = isWhiteBar ? '\u2654' : '\u265A';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.goldDark.withValues(alpha: 0.15)
            : AppColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: isActive
            ? Border.all(color: AppColors.goldDark.withValues(alpha: 0.4), width: 1)
            : null,
      ),
      child: Row(
        children: [
          Text(pieceIcon,
              style: TextStyle(
                  fontSize: 20,
                  color: isWhiteBar
                      ? const Color(0xFFF0ECE0)
                      : const Color(0xFF2A2A2A))),
          const SizedBox(width: 8),
          Text(playerName,
              style: GoogleFonts.cinzel(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? AppColors.goldLight : AppColors.textSecondary,
              )),
          if (state.isAiThinking && isAi && barSide != state.playerSide)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldLight),
                ),
              ),
            ),
          const Spacer(),
          if (captured.isNotEmpty)
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...captured.take(10).map((p) {
                    final isW = p.side == PlayerSide.white;
                    final symbols = {
                      PieceType.pawn: isW ? '\u2659' : '\u265F',
                      PieceType.knight: isW ? '\u2658' : '\u265E',
                      PieceType.bishop: isW ? '\u2657' : '\u265D',
                      PieceType.rook: isW ? '\u2656' : '\u265C',
                      PieceType.queen: isW ? '\u2655' : '\u265B',
                      PieceType.king: isW ? '\u2654' : '\u265A',
                    };
                    return Text(symbols[p.type] ?? '',
                        style: const TextStyle(fontSize: 13));
                  }),
                  if (advantage > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text('+$advantage',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.goldLight,
                          )),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // --- Move list (scrollable horizontal) ---
  Widget _buildMoveList(GameState state) {
    final moves = state.moveHistory;
    final totalPairs = (moves.length / 2).ceil();
    return Container(
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: totalPairs,
        itemBuilder: (context, index) {
          final moveNum = totalPairs - index;
          final whiteIdx = (moveNum - 1) * 2;
          final blackIdx = whiteIdx + 1;
          final whiteSan = whiteIdx < moves.length ? moves[whiteIdx].san : '';
          final blackSan = blackIdx < moves.length ? moves[blackIdx].san : '';
          return Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$moveNum.',
                    style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                const SizedBox(width: 4),
                Text(whiteSan,
                    style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                if (blackSan.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Text(blackSan,
                      style: GoogleFonts.inter(
                          fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                ],
              ],
            ),
          );
        },
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
    final isAi = state.gameMode == GameMode.ai;
    String statusText;
    Color statusColor = AppColors.textPrimary;

    if (state.isAiThinking) {
      statusText = 'AI thinking...';
      statusColor = AppColors.goldLight;
    } else if (state.status == GameStatus.check) {
      statusText = 'CHECK!';
      statusColor = AppColors.error;
    } else if (state.status == GameStatus.playing) {
      if (isAi) {
        statusText = state.currentTurn == state.playerSide ? 'Your Turn' : "AI's Turn";
      } else {
        statusText = "${state.currentTurn.label}'s Turn";
      }
    } else if (state.status == GameStatus.checkmate) {
      if (isAi) {
        statusText = state.currentTurn == state.playerSide ? 'You Lost!' : 'You Win!';
      } else {
        statusText = "${state.currentTurn.opposite.label} Wins!";
      }
      statusColor = AppColors.goldLight;
    } else if (state.status == GameStatus.resigned) {
      statusText = isAi ? 'You Resigned' : "${state.currentTurn.label} Resigned";
      statusColor = AppColors.error;
    } else if (state.status == GameStatus.stalemate) {
      statusText = 'Stalemate';
    } else if (state.status == GameStatus.draw) {
      statusText = 'Draw';
    } else {
      statusText = 'GAME';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _confirmExit(context, state.moveHistory.isNotEmpty),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface.withValues(alpha: 0.5),
                border: Border.all(color: AppColors.goldDark.withValues(alpha: 0.3), width: 1.5),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: AppColors.goldLight, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          if (state.isAiThinking)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: SizedBox(
                width: 12, height: 12,
                child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldLight)),
              ),
            ),
          Expanded(
            child: Text(statusText,
                style: GoogleFonts.cinzel(
                    fontSize: 15, fontWeight: FontWeight.w800, color: statusColor, letterSpacing: 1)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Move ${(state.moveHistory.length / 2).ceil()}',
                style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRouter.settings),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface.withValues(alpha: 0.5),
                border: Border.all(color: AppColors.goldDark.withValues(alpha: 0.3), width: 1.5),
              ),
              child: const Icon(Icons.settings_rounded, color: AppColors.goldLight, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameControls(
      BuildContext context, dynamic notifier, GameState state, bool isGameOver) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlBtn(Icons.flag_rounded, 'Resign',
              color: AppColors.error,
              onTap: !isGameOver && !state.isAiThinking
                  ? () => _confirmResign(context, notifier) : null),
          _ControlBtn(Icons.handshake_rounded, 'Draw',
              onTap: !isGameOver && !state.isAiThinking && state.moveHistory.length >= 2
                  ? () => _confirmDraw(context, notifier) : null),
          _ControlBtn(Icons.undo_rounded, 'Undo',
              onTap: state.moveHistory.isNotEmpty && !isGameOver && !state.isAiThinking
                  ? () => notifier.undoMove() : null),
          _ControlBtn(
              state.isLoadingHint ? Icons.hourglass_top_rounded : Icons.lightbulb_rounded,
              'Hint ${state.hintsRemaining}',
              color: AppColors.goldLight,
              onTap: state.hintsRemaining > 0 && !isGameOver && !state.isLoadingHint && !state.isAiThinking
                  ? () => notifier.requestHint() : null),
          _ControlBtn(Icons.swap_vert_rounded, 'Flip',
              onTap: () => notifier.flipBoard()),
          _ControlBtn(Icons.refresh_rounded, 'New',
              onTap: () => _confirmRestart(context, notifier, isGameOver)),
        ],
      ),
    );
  }

  // --- Dialogs ---

  void _confirmResign(BuildContext context, dynamic notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Resign?', style: GoogleFonts.cinzel(color: AppColors.error)),
        content: const Text('Are you sure you want to resign?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(onPressed: () { Navigator.pop(ctx); notifier.resignGame(); },
              child: const Text('Resign', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
  }

  void _confirmDraw(BuildContext context, dynamic notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Offer Draw?', style: GoogleFonts.cinzel(color: AppColors.goldLight)),
        content: const Text('Propose a draw to end the game?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(onPressed: () { Navigator.pop(ctx); notifier.offerDraw(); },
              child: const Text('Offer Draw', style: TextStyle(color: AppColors.goldLight))),
        ],
      ),
    );
  }

  void _confirmRestart(BuildContext context, dynamic notifier, bool isGameOver) {
    if (isGameOver) { notifier.restartGame(); _gameOverDialogShown = false; return; }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('New Game?', style: GoogleFonts.cinzel(color: AppColors.goldLight)),
        content: const Text('Current progress will be lost.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(onPressed: () { Navigator.pop(ctx); notifier.restartGame(); },
              child: const Text('New Game', style: TextStyle(color: AppColors.goldLight))),
        ],
      ),
    );
  }

  void _showPromotionDialog(BuildContext context, PlayerSide side, dynamic notifier) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PromotionDialog(
        side: side,
        onSelect: (type) { Navigator.pop(context); notifier.completePromotion(type); },
        onCancel: () { Navigator.pop(context); notifier.cancelPromotion(); },
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, GameState state, dynamic notifier) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => GameOverDialog(
        status: state.status,
        currentTurn: state.currentTurn,
        gameMode: state.gameMode,
        playerSide: state.playerSide,
        onNewGame: () { Navigator.pop(context); notifier.restartGame(); _gameOverDialogShown = false; },
        onDismiss: () { Navigator.pop(context); },
      ),
    );
  }

  void _confirmExit(BuildContext context, bool hasProgress) {
    if (!hasProgress) { Navigator.pop(context); return; }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Leave Game?', style: GoogleFonts.cinzel(color: AppColors.goldLight)),
        content: const Text('Current game progress will be lost.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Stay', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
              child: const Text('Leave', style: TextStyle(color: AppColors.goldLight))),
        ],
      ),
    );
  }
}

// --- Compact control button ---
Widget _ControlBtn(IconData icon, String label,
    {VoidCallback? onTap, Color? color}) {
  final isEnabled = onTap != null;
  final iconColor = isEnabled
      ? (color ?? AppColors.textPrimary)
      : AppColors.textMuted.withValues(alpha: 0.3);
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isEnabled
                ? AppColors.surface.withValues(alpha: 0.5)
                : AppColors.surface.withValues(alpha: 0.15),
            border: Border.all(
                color: isEnabled ? AppColors.goldDark.withValues(alpha: 0.3) : Colors.transparent,
                width: 1),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(height: 3),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 9, fontWeight: FontWeight.w600,
                color: isEnabled ? AppColors.textMuted : AppColors.textMuted.withValues(alpha: 0.3))),
      ],
    ),
  );
}
