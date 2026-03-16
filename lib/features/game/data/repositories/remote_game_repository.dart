import 'dart:async';
import '../../domain/entities/game_session.dart';
import '../../domain/entities/match_settings.dart';
import '../../domain/repositories/game_repository.dart';

/// Placeholder for future online multiplayer.
///
/// This repository will be implemented to connect to:
///   - Firebase Firestore + Realtime Database, OR
///   - Supabase Realtime, OR
///   - Custom WebSocket backend
///
/// Implementation points:
///   - [createGame] → create room/session on server
///   - [watchGame] → listen to Firestore snapshots / Supabase realtime / WS messages
///   - [saveGame] → push move to server (server validates and broadcasts)
///   - [getGame] → fetch current session state from server
///
/// The server should be authoritative for online mode:
///   - Client sends move intent
///   - Server validates legality
///   - Server broadcasts updated state to both players
///   - Client receives and applies state
///
/// Reconnection:
///   - On reconnect, fetch full game state from server
///   - Replay any missed moves
///   - Resume from current position
class RemoteGameRepository implements GameRepository {
  // Future: inject FirebaseFirestore / SupabaseClient / WebSocketChannel

  @override
  Future<GameSession> createGame(MatchSettings settings) {
    throw UnimplementedError('Online mode not yet implemented');
  }

  @override
  Future<GameSession?> getGame(String id) {
    throw UnimplementedError('Online mode not yet implemented');
  }

  @override
  Future<void> saveGame(GameSession session) {
    throw UnimplementedError('Online mode not yet implemented');
  }

  @override
  Future<List<GameSession>> getRecentGames() {
    throw UnimplementedError('Online mode not yet implemented');
  }

  @override
  Future<void> deleteGame(String id) {
    throw UnimplementedError('Online mode not yet implemented');
  }

  @override
  Stream<GameSession> watchGame(String id) {
    throw UnimplementedError('Online mode not yet implemented');
  }
}
