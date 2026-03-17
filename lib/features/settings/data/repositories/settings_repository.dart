import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/app_settings.dart';

class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  static const _keyBoardTheme = 'board_theme';
  static const _keySoundEnabled = 'sound_enabled';
  static const _keyHapticEnabled = 'haptic_enabled';
  static const _keyPieceStyle = 'piece_style';
  static const _keyShowCoordinates = 'show_coordinates';

  AppSettings load() {
    return AppSettings(
      boardTheme: BoardTheme.values[_prefs.getInt(_keyBoardTheme) ?? 0],
      soundEnabled: _prefs.getBool(_keySoundEnabled) ?? true,
      hapticEnabled: _prefs.getBool(_keyHapticEnabled) ?? true,
      pieceStyle: PieceStyle.values[_prefs.getInt(_keyPieceStyle) ?? 0],
      showCoordinates: _prefs.getBool(_keyShowCoordinates) ?? true,
    );
  }

  Future<void> save(AppSettings settings) async {
    await _prefs.setInt(_keyBoardTheme, settings.boardTheme.index);
    await _prefs.setBool(_keySoundEnabled, settings.soundEnabled);
    await _prefs.setBool(_keyHapticEnabled, settings.hapticEnabled);
    await _prefs.setInt(_keyPieceStyle, settings.pieceStyle.index);
    await _prefs.setBool(_keyShowCoordinates, settings.showCoordinates);
  }
}
