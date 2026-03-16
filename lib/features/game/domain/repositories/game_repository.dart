import '../entities/game_session.dart';
import '../entities/match_settings.dart';

/// Abstract repository for game sessions.
/// Local mode uses [LocalGameRepository].
/// Future online mode will implement [RemoteGameRepository].
abstract class GameRepository {
  Future<GameSession> createGame(MatchSettings settings);
  Future<GameSession?> getGame(String id);
  Future<void> saveGame(GameSession session);
  Future<List<GameSession>> getRecentGames();
  Future<void> deleteGame(String id);

  /// For online mode: stream game state changes from remote source.
  Stream<GameSession> watchGame(String id);
}
