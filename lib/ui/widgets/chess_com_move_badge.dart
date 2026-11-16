import 'package:flutter/material.dart';
import '../../models/move.dart';
import '../../models/piece.dart';
import 'piece_widget.dart';

class ChessComMoveBadge extends StatefulWidget {
  final ChessMove? move;
  final int moveNumber;

  const ChessComMoveBadge({
    super.key,
    required this.move,
    required this.moveNumber,
  });

  @override
  State<ChessComMoveBadge> createState() => _ChessComMoveBadgeState();
}

class _ChessComMoveBadgeState extends State<ChessComMoveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    if (widget.move != null) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ChessComMoveBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.move != oldWidget.move && widget.move != null) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.move == null) return const SizedBox.shrink();

    final move = widget.move!;
    final isWhite = move.pieceMoved.color == PieceColor.white;

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF262421), // Chess.com signature dark background
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isWhite ? const Color(0xFF81B64C) : const Color(0xFFFF6F61), // Lime / Coral accent
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Move Number Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${widget.moveNumber}.',
                  style: const TextStyle(
                    color: Color(0xFFBABAB8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Piece Icon
              PieceWidget(piece: move.pieceMoved, size: 22),
              const SizedBox(width: 6),

              // Move SAN String (e.g., Nf3, Qxd5+, O-O)
              Text(
                move.san,
                style: TextStyle(
                  color: isWhite ? Colors.white : const Color(0xFFE2E8F0),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),

              if (move.isCheckmate || move.isCheck) ...[
                const SizedBox(width: 4),
                Icon(
                  move.isCheckmate ? Icons.emoji_events : Icons.warning_amber_rounded,
                  size: 16,
                  color: move.isCheckmate ? Colors.amber : Colors.redAccent,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
