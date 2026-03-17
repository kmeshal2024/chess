import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/models/app_settings.dart';

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(const AppSettings()) {
    _load();
  }

  void _load() {
    state = _repository.load();
  }

  void setBoardTheme(BoardTheme theme) {
    state = state.copyWith(boardTheme: theme);
    _repository.save(state);
  }

  void toggleSound() {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
    _repository.save(state);
  }

  void toggleHaptic() {
    state = state.copyWith(hapticEnabled: !state.hapticEnabled);
    _repository.save(state);
  }

  void setPieceStyle(PieceStyle style) {
    state = state.copyWith(pieceStyle: style);
    _repository.save(state);
  }

  void toggleCoordinates() {
    state = state.copyWith(showCoordinates: !state.showCoordinates);
    _repository.save(state);
  }
}
