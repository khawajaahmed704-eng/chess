import 'package:flutter/material.dart';
import '../../models/piece.dart';
import 'captured_pieces_widget.dart';
import 'timer_widget.dart';

class PlayerHeaderWidget extends StatelessWidget {
  final String name;
  final PieceColor color;
  final bool isTurn;
  final List<ChessPiece> capturedPieces;
  final int materialAdvantage;
  final int? secondsRemaining;
  final bool isThinkingAI;

  const PlayerHeaderWidget({
    super.key,
    required this.name,
    required this.color,
    required this.isTurn,
    required this.capturedPieces,
    required this.materialAdvantage,
    this.secondsRemaining,
    this.isThinkingAI = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWhite = color == PieceColor.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isTurn
            ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.9)
            : theme.colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: isTurn
            ? Border.all(
                color: theme.colorScheme.primary.withOpacity(0.6),
                width: 1.5,
              )
            : Border.all(color: Colors.transparent),
      ),
      child: Row(
        children: [
          // Player Avatar & Indicator
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isWhite
                    ? Colors.white
                    : Colors.grey.shade900,
                child: Icon(
                  isWhite ? Icons.person_outline : Icons.computer,
                  color: isWhite ? Colors.grey.shade800 : Colors.white,
                  size: 22,
                ),
              ),
              if (isTurn)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.shade400,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Player Name & Captured Pieces
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isTurn ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                    if (isThinkingAI) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                CapturedPiecesWidget(
                  capturedPieces: capturedPieces,
                  materialAdvantage: materialAdvantage,
                  color: color,
                ),
              ],
            ),
          ),

          // Timer Widget
          if (secondsRemaining != null)
            TimerWidget(
              secondsRemaining: secondsRemaining!,
              isActive: isTurn,
              isLowTime: secondsRemaining! <= 30,
            ),
        ],
      ),
    );
  }
}
