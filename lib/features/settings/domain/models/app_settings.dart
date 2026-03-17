import 'package:equatable/equatable.dart';

enum BoardTheme { classic, marble, wood, dark }

enum PieceStyle { classic, modern, minimal }

class AppSettings extends Equatable {
  final BoardTheme boardTheme;
  final bool soundEnabled;
  final bool hapticEnabled;
  final PieceStyle pieceStyle;
  final bool showCoordinates;

  const AppSettings({
    this.boardTheme = BoardTheme.classic,
    this.soundEnabled = true,
    this.hapticEnabled = true,
    this.pieceStyle = PieceStyle.classic,
    this.showCoordinates = true,
  });

  AppSettings copyWith({
    BoardTheme? boardTheme,
    bool? soundEnabled,
    bool? hapticEnabled,
    PieceStyle? pieceStyle,
    bool? showCoordinates,
  }) {
    return AppSettings(
      boardTheme: boardTheme ?? this.boardTheme,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      pieceStyle: pieceStyle ?? this.pieceStyle,
      showCoordinates: showCoordinates ?? this.showCoordinates,
    );
  }

  @override
  List<Object?> get props => [
        boardTheme,
        soundEnabled,
        hapticEnabled,
        pieceStyle,
        showCoordinates,
      ];
}
