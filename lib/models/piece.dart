enum PieceType { pawn, knight, bishop, rook, queen, king }

enum PieceColor { white, black }

extension PieceColorExtension on PieceColor {
  PieceColor get opposite => this == PieceColor.white ? PieceColor.black : PieceColor.white;
}

class ChessPiece {
  final String id;
  final PieceType type;
  final PieceColor color;
  final bool hasMoved;

  const ChessPiece({
    this.id = '',
    required this.type,
    required this.color,
    this.hasMoved = false,
  });

  ChessPiece copyWith({
    String? id,
    PieceType? type,
    PieceColor? color,
    bool? hasMoved,
  }) {
    return ChessPiece(
      id: id ?? this.id,
      type: type ?? this.type,
      color: color ?? this.color,
      hasMoved: hasMoved ?? this.hasMoved,
    );
  }

  int get value {
    switch (type) {
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

  String get fenChar {
    switch (type) {
      case PieceType.pawn:
        return color == PieceColor.white ? 'P' : 'p';
      case PieceType.knight:
        return color == PieceColor.white ? 'N' : 'n';
      case PieceType.bishop:
        return color == PieceColor.white ? 'B' : 'b';
      case PieceType.rook:
        return color == PieceColor.white ? 'R' : 'r';
      case PieceType.queen:
        return color == PieceColor.white ? 'Q' : 'q';
      case PieceType.king:
        return color == PieceColor.white ? 'K' : 'k';
    }
  }

  String get pgnSymbol {
    switch (type) {
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChessPiece &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          color == other.color &&
          hasMoved == other.hasMoved;

  @override
  int get hashCode => id.hashCode ^ type.hashCode ^ color.hashCode ^ hasMoved.hashCode;

  @override
  String toString() => '${color.name} ${type.name} ($id)';
}
