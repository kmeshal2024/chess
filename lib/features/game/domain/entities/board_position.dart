import 'package:equatable/equatable.dart';

class BoardPosition extends Equatable {
  final int row;
  final int col;

  const BoardPosition(this.row, this.col);

  bool get isValid => row >= 0 && row < 8 && col >= 0 && col < 8;

  String get algebraic {
    final file = String.fromCharCode('a'.codeUnitAt(0) + col);
    final rank = (8 - row).toString();
    return '$file$rank';
  }

  factory BoardPosition.fromAlgebraic(String notation) {
    final col = notation.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final row = 8 - int.parse(notation[1]);
    return BoardPosition(row, col);
  }

  @override
  List<Object?> get props => [row, col];
}
