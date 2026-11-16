import 'package:flutter/material.dart';
import '../../engine/chess_engine.dart';
import '../../models/piece.dart';

class GameOverDialog extends StatelessWidget {
  final GameStatus status;
  final PieceColor? winner;
  final VoidCallback onNewGame;
  final VoidCallback onReviewBoard;

  const GameOverDialog({
    super.key,
    required this.status,
    required this.winner,
    required this.onNewGame,
    required this.onReviewBoard,
  });

  String get _title {
    switch (status) {
      case GameStatus.checkmate:
        return winner == PieceColor.white ? 'White Wins!' : 'Black Wins!';
      case GameStatus.stalemate:
        return 'Draw by Stalemate';
      case GameStatus.draw50MoveRule:
        return 'Draw (50-Move Rule)';
      case GameStatus.drawThreefoldRepetition:
        return 'Draw (Threefold Repetition)';
      case GameStatus.drawInsufficientMaterial:
        return 'Draw (Insufficient Material)';
      default:
        return 'Game Over';
    }
  }

  String get _description {
    switch (status) {
      case GameStatus.checkmate:
        return 'Checkmate! ${winner == PieceColor.white ? "White" : "Black"} trapped the opposing King.';
      case GameStatus.stalemate:
        return 'Stalemate! The active player has no legal moves and is not in check.';
      case GameStatus.draw50MoveRule:
        return 'Fifty consecutive moves played without a pawn move or piece capture.';
      case GameStatus.drawThreefoldRepetition:
        return 'The exact same board position occurred 3 times during the game.';
      case GameStatus.drawInsufficientMaterial:
        return 'Neither player has enough pieces left to deliver checkmate.';
      default:
        return 'The game has ended.';
    }
  }

  IconData get _icon {
    if (status == GameStatus.checkmate) {
      return Icons.emoji_events;
    }
    return Icons.handshake_outlined;
  }

  Color get _iconColor {
    if (status == GameStatus.checkmate) {
      return Colors.amber;
    }
    return Colors.blueAccent;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: _iconColor.withOpacity(0.15),
            child: Icon(_icon, size: 36, color: _iconColor),
          ),
          const SizedBox(height: 16),
          Text(
            _title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _description,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onReviewBoard();
                  },
                  child: const Text('Review Board'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onNewGame();
                  },
                  child: const Text('New Game'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
