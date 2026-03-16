enum PieceType { pawn, knight, bishop, rook, queen, king }

enum PlayerSide { white, black }

enum GameMode { offline, online, ai }

enum GameStatus {
  idle,
  playing,
  check,
  checkmate,
  stalemate,
  draw,
  resigned,
}

extension PlayerSideX on PlayerSide {
  PlayerSide get opposite =>
      this == PlayerSide.white ? PlayerSide.black : PlayerSide.white;

  String get label => this == PlayerSide.white ? 'White' : 'Black';
}

extension PieceTypeX on PieceType {
  String get symbol {
    switch (this) {
      case PieceType.pawn:
        return '';
      case PieceType.knight:
        return 'N';
      case PieceType.bishop:
        return 'B';
      case PieceType.rook:
        return 'R';
      case PieceType.queen:
        return 'Q';
      case PieceType.king:
        return 'K';
    }
  }

  int get materialValue {
    switch (this) {
      case PieceType.pawn:
        return 1;
      case PieceType.knight:
        return 3;
      case PieceType.bishop:
        return 3;
      case PieceType.rook:
        return 5;
      case PieceType.queen:
        return 9;
      case PieceType.king:
        return 0;
    }
  }
}
