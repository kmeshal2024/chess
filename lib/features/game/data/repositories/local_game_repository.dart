import 'dart:async';
import 'package:chess/core/constants.dart';
import 'package:chess/core/enums.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/entities/match_settings.dart';
import '../../domain/repositories/game_repository.dart';

class LocalGameRepository implements GameRepository {
  final Map<String, GameSession> _sessions = {};
  final _uuid = const Uuid();

  @override
  Future<GameSession> createGame(MatchSettings settings) async {
    final session = GameSession(
      id: _uuid.v4(),
      settings: settings,
      currentTurn: PlayerSide.white,
      status: GameStatus.playing,
      board: List.generate(8, (_) => List.filled(8, null)),
      fen: initialFen,
      createdAt: DateTime.now(),
    );
    _sessions[session.id] = session;
    return session;
  }

  @override
  Future<GameSession?> getGame(String id) async => _sessions[id];

  @override
  Future<void> saveGame(GameSession session) async {
    _sessions[session.id] = session;
  }

  @override
  Future<List<GameSession>> getRecentGames() async {
    final games = _sessions.values.toList();
    games.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return games.take(10).toList();
  }

  @override
  Future<void> deleteGame(String id) async {
    _sessions.remove(id);
  }

  @override
  Stream<GameSession> watchGame(String id) {
    // Local mode doesn't need real-time streaming
    return Stream.value(_sessions[id]!);
  }
}
