import 'package:flutter/material.dart';
import '../../models/piece.dart';
import 'piece_widget.dart';

class CapturedPiecesWidget extends StatelessWidget {
  final List<ChessPiece> capturedPieces;
  final int materialAdvantage;
  final PieceColor color;

  const CapturedPiecesWidget({
    super.key,
    required this.capturedPieces,
    required this.materialAdvantage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Sort captured pieces by value
    final sortedPieces = List<ChessPiece>.from(capturedPieces)
      ..sort((a, b) => b.value.compareTo(a.value));

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: sortedPieces
                  .map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(right: 2.0),
                      child: PieceWidget(piece: p, size: 24),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        if (materialAdvantage > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.amber, width: 0.8),
            ),
            child: Text(
              '+$materialAdvantage',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ),
      ],
    );
  }
}
