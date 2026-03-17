import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents an online game room in Firestore
class OnlineRoom {
  final String roomCode;
  final String hostId;
  final String? guestId;
  final String currentFen;
  final String currentTurn; // 'white' or 'black'
  final String status; // 'waiting', 'playing', 'finished'
  final String? lastMoveFrom;
  final String? lastMoveTo;
  final String? lastMovePromotion;
  final String? winner;
  final DateTime createdAt;

  OnlineRoom({
    required this.roomCode,
    required this.hostId,
    this.guestId,
    required this.currentFen,
    required this.currentTurn,
    required this.status,
    this.lastMoveFrom,
    this.lastMoveTo,
    this.lastMovePromotion,
    this.winner,
    required this.createdAt,
  });

  factory OnlineRoom.fromFirestore(Map<String, dynamic> data) {
    return OnlineRoom(
      roomCode: data['roomCode'] ?? '',
      hostId: data['hostId'] ?? '',
      guestId: data['guestId'],
      currentFen: data['currentFen'] ?? 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
      currentTurn: data['currentTurn'] ?? 'white',
      status: data['status'] ?? 'waiting',
      lastMoveFrom: data['lastMoveFrom'],
      lastMoveTo: data['lastMoveTo'],
      lastMovePromotion: data['lastMovePromotion'],
      winner: data['winner'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'roomCode': roomCode,
      'hostId': hostId,
      'guestId': guestId,
      'currentFen': currentFen,
      'currentTurn': currentTurn,
      'status': status,
      'lastMoveFrom': lastMoveFrom,
      'lastMoveTo': lastMoveTo,
      'lastMovePromotion': lastMovePromotion,
      'winner': winner,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class OnlineGameService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'chess_rooms';

  /// Generate a unique player ID
  String generatePlayerId() {
    final random = Random();
    return 'player_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(9999)}';
  }

  /// Generate a 6-digit room code
  String _generateRoomCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Create a new room and return the room code
  Future<String> createRoom(String playerId) async {
    final roomCode = _generateRoomCode();

    const initialFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

    await _db.collection(_collection).doc(roomCode).set({
      'roomCode': roomCode,
      'hostId': playerId,
      'guestId': null,
      'currentFen': initialFen,
      'currentTurn': 'white',
      'status': 'waiting',
      'lastMoveFrom': null,
      'lastMoveTo': null,
      'lastMovePromotion': null,
      'winner': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return roomCode;
  }

  /// Join an existing room
  Future<OnlineRoom?> joinRoom(String roomCode, String playerId) async {
    final doc = await _db.collection(_collection).doc(roomCode).get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    if (data['status'] != 'waiting') return null;
    if (data['guestId'] != null) return null;

    await _db.collection(_collection).doc(roomCode).update({
      'guestId': playerId,
      'status': 'playing',
    });

    final updated = await _db.collection(_collection).doc(roomCode).get();
    return OnlineRoom.fromFirestore(updated.data()!);
  }

  /// Listen to room changes in real-time
  Stream<OnlineRoom?> watchRoom(String roomCode) {
    return _db.collection(_collection).doc(roomCode).snapshots().map((snap) {
      if (!snap.exists) return null;
      return OnlineRoom.fromFirestore(snap.data()!);
    });
  }

  /// Send a move to the room
  Future<void> sendMove({
    required String roomCode,
    required String newFen,
    required String fromSquare,
    required String toSquare,
    required String nextTurn,
    String? promotion,
    String? gameStatus,
    String? winner,
  }) async {
    final updateData = <String, dynamic>{
      'currentFen': newFen,
      'lastMoveFrom': fromSquare,
      'lastMoveTo': toSquare,
      'lastMovePromotion': promotion,
      'currentTurn': nextTurn,
    };

    if (gameStatus != null) {
      updateData['status'] = gameStatus;
    }
    if (winner != null) {
      updateData['winner'] = winner;
    }

    await _db.collection(_collection).doc(roomCode).update(updateData);
  }

  /// Delete a room (cleanup)
  Future<void> deleteRoom(String roomCode) async {
    await _db.collection(_collection).doc(roomCode).delete();
  }

  /// Check if a room exists
  Future<bool> roomExists(String roomCode) async {
    final doc = await _db.collection(_collection).doc(roomCode).get();
    return doc.exists;
  }
}
