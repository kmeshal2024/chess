import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();

  SoundService() {
    _player.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> playMove() async {
    await _play('sounds/move.mp3');
  }

  Future<void> playCapture() async {
    await _play('sounds/capture.mp3');
  }

  Future<void> playCheck() async {
    await _play('sounds/check.mp3');
  }

  Future<void> playGameOver() async {
    await _play('sounds/game_over.mp3');
  }

  Future<void> _play(String asset) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(asset));
    } catch (e) {
      debugPrint('Sound play error: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
