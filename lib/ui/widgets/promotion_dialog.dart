import 'package:flutter/material.dart';
import '../../models/piece.dart';
import 'piece_widget.dart';

class PromotionDialog extends StatelessWidget {
  final PieceColor color;

  const PromotionDialog({
    super.key,
    required this.color,
  });

  static Future<PieceType?> show(BuildContext context, PieceColor color) {
    return showDialog<PieceType>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PromotionDialog(color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = [
      {'type': PieceType.queen, 'label': 'Queen'},
      {'type': PieceType.rook, 'label': 'Rook'},
      {'type': PieceType.bishop, 'label': 'Bishop'},
      {'type': PieceType.knight, 'label': 'Knight'},
    ];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Center(
        child: Text(
          'Pawn Promotion',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Choose a piece to promote your pawn to:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: options.map((opt) {
              final type = opt['type'] as PieceType;
              final label = opt['label'] as String;
              final dummyPiece = ChessPiece(type: type, color: color);

              return InkWell(
                onTap: () => Navigator.of(context).pop(type),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.4),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PieceWidget(piece: dummyPiece, size: 42),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
