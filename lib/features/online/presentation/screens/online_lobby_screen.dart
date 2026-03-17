import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chess/app/theme.dart';
import 'package:chess/app/router.dart';
import 'package:chess/shared/widgets/gold_button.dart';
import 'package:chess/shared/widgets/wood_panel.dart';
import 'package:chess/main.dart';
import '../../data/services/online_game_service.dart';

class OnlineLobbyScreen extends StatefulWidget {
  const OnlineLobbyScreen({super.key});

  @override
  State<OnlineLobbyScreen> createState() => _OnlineLobbyScreenState();
}

class _OnlineLobbyScreenState extends State<OnlineLobbyScreen> {
  final _codeController = TextEditingController();
  final _service = OnlineGameService();
  late final String _playerId;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _playerId = _service.generatePlayerId();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final roomCode = await _service.createRoom(_playerId);
      if (mounted) {
        Navigator.pushNamed(
          context,
          AppRouter.onlineGame,
          arguments: {
            'roomCode': roomCode,
            'playerId': _playerId,
            'isHost': true,
          },
        );
      }
    } catch (e) {
      setState(() => _error = 'Failed to create room. Check your connection.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _joinRoom() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Enter a 6-digit room code');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final room = await _service.joinRoom(code, _playerId);
      if (room == null) {
        setState(() => _error = 'Room not found or already full');
      } else if (mounted) {
        Navigator.pushNamed(
          context,
          AppRouter.onlineGame,
          arguments: {
            'roomCode': code,
            'playerId': _playerId,
            'isHost': false,
          },
        );
      }
    } catch (e) {
      setState(() => _error = 'Failed to join room. Check your connection.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If Firebase is not available, show setup instructions
    if (!isFirebaseAvailable) {
      return _buildSetupRequiredScreen();
    }

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
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      // Online icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.gold.withValues(alpha: 0.2),
                              AppColors.gold.withValues(alpha: 0.05),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.goldDark.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.language_rounded,
                          color: AppColors.goldLight,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ONLINE PLAY',
                        style: GoogleFonts.cinzel(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.goldLight,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Play with a friend using room codes',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Create Room
                      WoodPanel(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.add_circle_outline_rounded,
                              color: AppColors.goldLight,
                              size: 36,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Create Room',
                              style: GoogleFonts.cinzel(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.goldLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create a room and share the code\nwith your friend',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: GoldButton(
                                label: 'CREATE ROOM',
                                icon: Icons.play_arrow_rounded,
                                onTap: () { if (!_isLoading) _createRoom(); },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Join Room
                      WoodPanel(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.login_rounded,
                              color: AppColors.goldLight,
                              size: 36,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Join Room',
                              style: GoogleFonts.cinzel(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.goldLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter the 6-digit code from your friend',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Code input
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.backgroundDark.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.goldDark.withValues(alpha: 0.3),
                                ),
                              ),
                              child: TextField(
                                controller: _codeController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 6,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: GoogleFonts.cinzel(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.goldLight,
                                  letterSpacing: 8,
                                ),
                                decoration: InputDecoration(
                                  hintText: '000000',
                                  hintStyle: GoogleFonts.cinzel(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textMuted.withValues(alpha: 0.3),
                                    letterSpacing: 8,
                                  ),
                                  counterText: '',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: GoldButton(
                                label: 'JOIN ROOM',
                                icon: Icons.login_rounded,
                                onTap: () { if (!_isLoading) _joinRoom(); },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Error message
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            _error!,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],

                      // Loading
                      if (_isLoading) ...[
                        const SizedBox(height: 20),
                        const CircularProgressIndicator(
                          color: AppColors.goldLight,
                          strokeWidth: 2,
                        ),
                      ],

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
                  width: 1.5,
                ),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.goldLight, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Online Play',
            style: GoogleFonts.cinzel(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.goldLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupRequiredScreen() {
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
              _buildTopBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gold.withValues(alpha: 0.1),
                          border: Border.all(
                            color: AppColors.goldDark.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.cloud_off_rounded,
                          color: AppColors.goldLight,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Firebase Setup Required',
                        style: GoogleFonts.cinzel(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.goldLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'To enable online multiplayer, you need to set up Firebase:\n\n'
                        '1. Go to console.firebase.google.com\n'
                        '2. Create a new project\n'
                        '3. Add Android app (com.chessapp.chess)\n'
                        '4. Download google-services.json\n'
                        '5. Replace the file in android/app/\n'
                        '6. Enable Cloud Firestore in Firebase',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
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
}
