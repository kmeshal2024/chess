import 'package:equatable/equatable.dart';
import 'package:chess/core/enums.dart';

class MatchSettings extends Equatable {
  final GameMode mode;
  final Duration? timeControl;
  final String? roomId;
  final PlayerSide playerSide;

  const MatchSettings({
    this.mode = GameMode.offline,
    this.timeControl,
    this.roomId,
    this.playerSide = PlayerSide.white,
  });

  @override
  List<Object?> get props => [mode, timeControl, roomId, playerSide];
}
