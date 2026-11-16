import 'piece.dart';
import 'position.dart';

class ChessMove {
  final Position from;
  final Position to;
  final ChessPiece pieceMoved;
  final ChessPiece? pieceCaptured;
  final PieceType? promotionPiece;
  final bool isKingsideCastling;
  final bool isQueensideCastling;
  final bool isEnPassant;
  final bool isCheck;
  final bool isCheckmate;
  final String san;

  const ChessMove({
    required this.from,
    required this.to,
    required this.pieceMoved,
    this.pieceCaptured,
    this.promotionPiece,
    this.isKingsideCastling = false,
    this.isQueensideCastling = false,
    this.isEnPassant = false,
    this.isCheck = false,
    this.isCheckmate = false,
    required this.san,
  });

  bool get isCastling => isKingsideCastling || isQueensideCastling;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChessMove &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to &&
          promotionPiece == other.promotionPiece;

  @override
  int get hashCode => from.hashCode ^ to.hashCode ^ (promotionPiece?.hashCode ?? 0);

  @override
  String toString() => san;
}
