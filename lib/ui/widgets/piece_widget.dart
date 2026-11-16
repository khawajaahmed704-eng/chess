import 'package:flutter/material.dart';
import '../../models/piece.dart';

class PieceWidget extends StatelessWidget {
  final ChessPiece piece;
  final double size;

  const PieceWidget({
    super.key,
    required this.piece,
    required this.size,
  });

  String _getSymbol() {
    switch (piece.type) {
      case PieceType.king:
        return '♚';
      case PieceType.queen:
        return '♛';
      case PieceType.rook:
        return '♜';
      case PieceType.bishop:
        return '♝';
      case PieceType.knight:
        return '♞';
      case PieceType.pawn:
        return '♟';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWhite = piece.color == PieceColor.white;

    // Elegant styling with outer shadow and crisp interior contrast
    final textColor = isWhite ? const Color(0xFFFAFAFA) : const Color(0xFF1E293B);
    final shadowColor = isWhite ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final borderColor = isWhite ? const Color(0xFF475569) : const Color(0xFF000000);

    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer stroke for accessibility & high contrast
            Text(
              _getSymbol(),
              style: TextStyle(
                fontSize: size * 0.78,
                height: 1.0,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = size * 0.04
                  ..color = borderColor,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: size * 0.08,
                    offset: Offset(0, size * 0.04),
                  ),
                ],
              ),
            ),
            // Primary piece fill
            Text(
              _getSymbol(),
              style: TextStyle(
                fontSize: size * 0.78,
                height: 1.0,
                color: textColor,
                shadows: [
                  Shadow(
                    color: shadowColor.withOpacity(0.4),
                    blurRadius: 1,
                    offset: const Offset(0.5, 0.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
