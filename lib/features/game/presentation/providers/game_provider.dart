import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/bishop_chess_engine.dart';
import '../../domain/services/chess_engine_service.dart';
import 'game_notifier.dart';
import 'game_state.dart';

final chessEngineProvider = Provider<ChessEngineService>((ref) {
  return BishopChessEngine();
});

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  final engine = ref.watch(chessEngineProvider);
  return GameNotifier(engine);
});
