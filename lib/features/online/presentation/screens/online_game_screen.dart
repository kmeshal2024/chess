import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chess/app/theme.dart';
import 'package:chess/core/enums.dart';
import 'package:chess/shared/widgets/player_avatar.dart';
import 'package:chess/features/game/domain/entities/board_position.dart';
import 'package:chess/features/game/domain/entities/chess_piece.dart';
import 'package:chess/features/game/data/services/bishop_chess_engine.dart';
import 'package:chess/features/game/presentation/widgets/chess_piece_widget.dart';
import '../../data/services/online_game_service.dart';

class OnlineGameScreen extends StatefulWidget {
  final String roomCode;
  final String playerId;
  final bool isHost;

  const OnlineGameScreen({
    super.key,
    required this.roomCode,
    required this.playerId,
    required this.isHost,
  });

  @override
  State<OnlineGameScreen> createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends State<OnlineGameScreen> {
  final OnlineGameService _service = OnlineGameService();
  final BishopChessEngine _engine = BishopChessEngine();

  StreamSubscription? _roomSub;
  OnlineRoom? _room;
  bool _waitingForOpponent = false;
  bool _gameOver = false;

  // Local board state
  List<List<ChessPiece?>> _board = [];
  BoardPosition? _selectedSquare;
  Set<BoardPosition> _validMoves = {};
  BoardPosition? _lastMoveFrom;
  BoardPosition? _lastMoveTo;

  // The host plays White, the guest plays Black
  PlayerSide get _mySide => widget.isHost ? PlayerSide.white : PlayerSide.black;
  bool get _isMyTurn {
    if (_room == null) return false;
    final turnSide = _room!.currentTurn == 'white' ? PlayerSide.white : PlayerSide.black;
    return turnSide == _mySide;
  }

  @override
  void initState() {
    super.initState();
    _waitingForOpponent = widget.isHost;
    _engine.newGame();
    _board = _engine.getBoard();
    _startListening();
  }

  void _startListening() {
    _roomSub = _service.watchRoom(widget.roomCode).listen((room) {
      if (room == null) {
        // Room deleted
        if (mounted) {
          _showMessage('Room was closed');
          Navigator.pop(context);
        }
        return;
      }

      setState(() {
        _room = room;
        _waitingForOpponent = room.guestId == null;

        // Sync board from FEN
        try {
          _engine.loadFen(room.currentFen);
          _board = _engine.getBoard();
        } catch (e) {
          debugPrint('Failed to load FEN: $e');
        }

        // Track last move
        if (room.lastMoveFrom != null && room.lastMoveTo != null) {
          try {
            _lastMoveFrom = BoardPosition.fromAlgebraic(room.lastMoveFrom!);
            _lastMoveTo = BoardPosition.fromAlgebraic(room.lastMoveTo!);
          } catch (e) {
            // Ignore parse errors
          }
        }

        // Check game over
        if (room.status == 'finished') {
          _gameOver = true;
        }
      });
    });
  }

  void _onSquareTap(int row, int col) {
    if (!_isMyTurn || _gameOver || _waitingForOpponent) return;

    final position = BoardPosition(row, col);
    final piece = _board[row][col];

    // If a square is selected and tapping a valid move
    if (_selectedSquare != null && _validMoves.contains(position)) {
      _makeMove(_selectedSquare!, position);
      return;
    }

    // If tapping own piece, select it
    if (piece != null && piece.side == _mySide) {
      try {
        final moves = _engine.getLegalMoves(position);
        setState(() {
          _selectedSquare = position;
          _validMoves = moves.toSet();
        });
      } catch (e) {
        setState(() {
          _selectedSquare = null;
          _validMoves = {};
        });
      }
      return;
    }

    // Deselect
    setState(() {
      _selectedSquare = null;
      _validMoves = {};
    });
  }

  Future<void> _makeMove(BoardPosition from, BoardPosition to) async {
    try {
      // Check for promotion
      PieceType? promotion;
      if (_engine.isPromotionMove(from, to)) {
        promotion = await _showPromotionPicker();
        if (promotion == null) {
          setState(() {
            _selectedSquare = null;
            _validMoves = {};
          });
          return;
        }
      }

      final move = _engine.makeMove(from, to, promotion: promotion);
      if (move == null) {
        setState(() {
          _selectedSquare = null;
          _validMoves = {};
        });
        return;
      }

      // Update local state
      setState(() {
        _board = _engine.getBoard();
        _selectedSquare = null;
        _validMoves = {};
        _lastMoveFrom = from;
        _lastMoveTo = to;
      });

      // Determine game status
      String? gameStatus;
      String? winner;
      if (_engine.isCheckmate()) {
        gameStatus = 'finished';
        winner = _mySide == PlayerSide.white ? 'white' : 'black';
      } else if (_engine.isStalemate() || _engine.isDraw()) {
        gameStatus = 'finished';
        winner = 'draw';
      }

      // Send move to Firestore
      final nextTurn = _mySide == PlayerSide.white ? 'black' : 'white';
      await _service.sendMove(
        roomCode: widget.roomCode,
        newFen: _engine.getFen(),
        fromSquare: from.algebraic,
        toSquare: to.algebraic,
        nextTurn: nextTurn,
        promotion: promotion?.symbol,
        gameStatus: gameStatus,
        winner: winner,
      );
    } catch (e) {
      _showMessage('Move failed: $e');
      setState(() {
        _selectedSquare = null;
        _validMoves = {};
      });
    }
  }

  Future<PieceType?> _showPromotionPicker() async {
    return showDialog<PieceType>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Promote Pawn',
          style: GoogleFonts.cinzel(color: AppColors.goldLight),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _promotionOption(ctx, PieceType.queen, '\u2655'),
            _promotionOption(ctx, PieceType.rook, '\u2656'),
            _promotionOption(ctx, PieceType.bishop, '\u2657'),
            _promotionOption(ctx, PieceType.knight, '\u2658'),
          ],
        ),
      ),
    );
  }

  Widget _promotionOption(BuildContext ctx, PieceType type, String char) {
    return GestureDetector(
      onTap: () => Navigator.pop(ctx, type),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.woodDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.goldDark),
        ),
        child: Center(
          child: Text(char, style: const TextStyle(fontSize: 30)),
        ),
      ),
    );
  }

  void _showMessage(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.surface,
        ),
      );
    }
  }

  @override
  void dispose() {
    _roomSub?.cancel();
    // If host leaves while waiting, delete the room
    if (widget.isHost && _waitingForOpponent) {
      _service.deleteRoom(widget.roomCode);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          ),
        ),
        child: SafeArea(
          child: _waitingForOpponent ? _buildWaitingScreen() : _buildGameScreen(),
        ),
      ),
    );
  }

  Widget _buildWaitingScreen() {
    return Column(
      children: [
        _buildTopBar(),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: AppColors.goldLight,
                    strokeWidth: 2,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Waiting for opponent...',
                    style: GoogleFonts.cinzel(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.goldLight,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Share this room code:',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: widget.roomCode));
                      _showMessage('Code copied!');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.woodDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.goldDark,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.roomCode,
                            style: GoogleFonts.cinzel(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppColors.goldLight,
                              letterSpacing: 8,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.copy_rounded,
                            color: AppColors.goldLight,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tap to copy',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameScreen() {
    // Determine if board should be flipped (guest sees from black perspective)
    final boardFlipped = !widget.isHost;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final maxBoardSize = screenWidth - 32;

        return Column(
          children: [
            _buildTopBar(),

            // Opponent info
            _buildPlayerBar(
              isOpponent: true,
              side: _mySide == PlayerSide.white ? PlayerSide.black : PlayerSide.white,
            ),
            const SizedBox(height: 4),

            // Status
            _buildStatus(),
            const SizedBox(height: 4),

            // Board
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
                      child: _buildBoard(boardFlipped, maxBoardSize),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),

            // My info
            _buildPlayerBar(isOpponent: false, side: _mySide),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _confirmExit(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface.withValues(alpha: 0.5),
                border: Border.all(
                  color: AppColors.goldDark.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.goldLight, size: 20),
            ),
          ),
          const Spacer(),
          Text(
            'ONLINE',
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.goldLight,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          // Room code badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.woodDark.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.goldDark.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              '#${widget.roomCode}',
              style: GoogleFonts.cinzel(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.goldLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerBar({required bool isOpponent, required PlayerSide side}) {
    final isActive = _room != null &&
        ((_room!.currentTurn == 'white' && side == PlayerSide.white) ||
         (_room!.currentTurn == 'black' && side == PlayerSide.black));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          PlayerAvatar(
            size: 36,
            icon: isOpponent ? Icons.person_outline : Icons.person,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isOpponent ? 'Opponent' : 'You',
                style: GoogleFonts.cinzel(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isActive ? AppColors.goldLight : AppColors.textSecondary,
                ),
              ),
              Text(
                side == PlayerSide.white ? 'White' : 'Black',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (isActive)
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatus() {
    String text = _isMyTurn ? 'Your Turn' : "Opponent's Turn";
    Color color = AppColors.textPrimary;

    if (_gameOver && _room != null) {
      if (_room!.winner == 'draw') {
        text = 'Draw!';
        color = AppColors.textSecondary;
      } else if (_room!.winner == (_mySide == PlayerSide.white ? 'white' : 'black')) {
        text = 'You Win!';
        color = AppColors.goldLight;
      } else {
        text = 'You Lose';
        color = AppColors.error;
      }
    } else if (_engine.isCheck()) {
      text = _isMyTurn ? 'You are in Check!' : 'Opponent in Check!';
      color = AppColors.error;
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

  Widget _buildBoard(bool flipped, double maxSize) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.goldDark, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalSize = constraints.maxWidth < constraints.maxHeight
                ? constraints.maxWidth
                : constraints.maxHeight;
            final squareSize = totalSize / 8;
            if (squareSize <= 0) return const SizedBox();

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(8, (displayRow) {
                final row = flipped ? (7 - displayRow) : displayRow;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(8, (displayCol) {
                    final col = flipped ? (7 - displayCol) : displayCol;
                    final piece = (row < _board.length && col < _board[row].length)
                        ? _board[row][col]
                        : null;
                    final pos = BoardPosition(row, col);
                    final isSelected = _selectedSquare == pos;
                    final isValidMove = _validMoves.contains(pos);
                    final isFrom = _lastMoveFrom == pos;
                    final isTo = _lastMoveTo == pos;
                    final isLight = (row + col) % 2 == 0;
                    final isCheck = piece != null &&
                        piece.type == PieceType.king &&
                        _engine.isCheck() &&
                        piece.side == _engine.getCurrentTurn();

                    Color bgColor = isLight
                        ? const Color(0xFFEDD6B0)
                        : const Color(0xFF2C2C2C);

                    if (isSelected) {
                      bgColor = AppColors.selectedSquare;
                    } else if (isCheck) {
                      bgColor = AppColors.checkSquare;
                    } else if (isTo) {
                      bgColor = isLight
                          ? const Color(0xFFC8C878)
                          : const Color(0xFF6B8F47);
                    } else if (isFrom) {
                      bgColor = isLight
                          ? const Color(0xFFDADA9A)
                          : const Color(0xFF5A7A3D);
                    }

                    return GestureDetector(
                      onTap: () => _onSquareTap(row, col),
                      child: Container(
                        width: squareSize,
                        height: squareSize,
                        color: bgColor,
                        child: Stack(
                          children: [
                            if (isValidMove && piece == null)
                              Center(
                                child: Container(
                                  width: squareSize * 0.3,
                                  height: squareSize * 0.3,
                                  decoration: const BoxDecoration(
                                    color: AppColors.validMoveDot,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            if (isValidMove && piece != null)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.validMoveCapture,
                                      width: squareSize * 0.08,
                                    ),
                                  ),
                                ),
                              ),
                            if (piece != null)
                              Center(
                                child: ChessPieceWidget(
                                  piece: piece,
                                  size: squareSize,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  void _confirmExit() {
    if (_gameOver || _waitingForOpponent) {
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
          'Leaving will forfeit the game.',
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
              _service.sendMove(
                roomCode: widget.roomCode,
                newFen: _engine.getFen(),
                fromSquare: '',
                toSquare: '',
                nextTurn: _room?.currentTurn ?? 'white',
                gameStatus: 'finished',
                winner: _mySide == PlayerSide.white ? 'black' : 'white',
              );
              Navigator.pop(context);
            },
            child: const Text('Leave',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
