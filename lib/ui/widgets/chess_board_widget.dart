import 'package:flutter/material.dart';
import '../../engine/chess_engine.dart';
import '../../models/game_options.dart';
import '../../models/piece.dart';
import '../../models/position.dart';
import 'piece_widget.dart';

class ChessBoardWidget extends StatelessWidget {
  final ChessEngine engine;
  final GameOptions options;
  final Position? selectedPosition;
  final List<Position> legalMoves;
  final bool isFlipped;
  final double size;
  final Function(Position pos) onSquareTapped;
  final Function(Position from, Position to) onPieceDropped;

  const ChessBoardWidget({
    super.key,
    required this.engine,
    required this.options,
    required this.selectedPosition,
    required this.legalMoves,
    required this.isFlipped,
    required this.size,
    required this.onSquareTapped,
    required this.onPieceDropped,
  });

  @override
  Widget build(BuildContext context) {
    final squareSize = size / 8;

    final kingInCheckPos = engine.isInCheck(engine.turn)
        ? engine.findKing(engine.turn)
        : null;

    final List<Widget> pieceWidgets = [];

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = engine.board[r][c];
        if (piece != null) {
          final displayRow = isFlipped ? 7 - r : r;
          final displayCol = isFlipped ? 7 - c : c;
          final pos = Position(r, c);

          pieceWidgets.add(
            AnimatedPositioned(
              key: ValueKey(piece.id), // Stable Key based on piece unique ID for smooth glide animation
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              left: displayCol * squareSize,
              top: displayRow * squareSize,
              width: squareSize,
              height: squareSize,
              child: AnimatedRotation(
                turns: isFlipped ? -0.5 : 0.0, // Keeps piece graphic right-side up during board flip
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                child: GestureDetector(
                  onTap: () => onSquareTapped(pos),
                  child: Draggable<Position>(
                    data: pos,
                    feedback: Material(
                      color: Colors.transparent,
                      child: PieceWidget(piece: piece, size: squareSize * 1.15),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: PieceWidget(piece: piece, size: squareSize),
                    ),
                    child: PieceWidget(piece: piece, size: squareSize),
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return AnimatedRotation(
      turns: isFlipped ? 0.5 : 0.0, // Smooth 180° board rotation animation
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              // 1. Squares Background Grid
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 64,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                ),
                itemBuilder: (context, index) {
                  final gridRow = index ~/ 8;
                  final gridCol = index % 8;

                  final row = isFlipped ? 7 - gridRow : gridRow;
                  final col = isFlipped ? 7 - gridCol : gridCol;

                  final pos = Position(row, col);
                  final isLight = (row + col) % 2 == 0;
                  final isSelected = selectedPosition == pos;
                  final isPossibleMove = options.showLegalMoves && legalMoves.contains(pos);
                  final isLastMove = engine.lastMove != null &&
                      (engine.lastMove!.from == pos || engine.lastMove!.to == pos);
                  final isInCheck = kingInCheckPos == pos;

                  Color squareColor = isLight
                      ? Color(options.boardTheme.lightSquareColor)
                      : Color(options.boardTheme.darkSquareColor);

                  if (isLastMove) {
                    squareColor = Color.alphaBlend(
                      Color(options.boardTheme.accentColor).withOpacity(0.35),
                      squareColor,
                    );
                  }

                  if (isSelected) {
                    squareColor = Color.alphaBlend(
                      Color(options.boardTheme.accentColor).withOpacity(0.65),
                      squareColor,
                    );
                  }

                  if (isInCheck) {
                    squareColor = Color.alphaBlend(
                      Colors.red.withOpacity(0.7),
                      squareColor,
                    );
                  }

                  final textColor = isLight
                      ? Color(options.boardTheme.darkSquareColor)
                      : Color(options.boardTheme.lightSquareColor);

                  final showRank = gridCol == 0;
                  final showFile = gridRow == 7;
                  final rankLabel = (8 - row).toString();
                  final fileLabel = String.fromCharCode('a'.codeUnitAt(0) + col);

                  return DragTarget<Position>(
                    onWillAcceptWithDetails: (details) => details.data != pos,
                    onAcceptWithDetails: (details) {
                      onPieceDropped(details.data, pos);
                    },
                    builder: (context, candidateData, rejectedData) {
                      return GestureDetector(
                        onTap: () => onSquareTapped(pos),
                        child: Container(
                          decoration: BoxDecoration(
                            color: squareColor,
                            border: isSelected
                                ? Border.all(color: Color(options.boardTheme.accentColor), width: 2.5)
                                : null,
                          ),
                          child: Stack(
                            children: [
                              if (isPossibleMove)
                                Center(
                                  child: engine.pieceAt(pos) == null
                                      ? Container(
                                          width: squareSize * 0.28,
                                          height: squareSize * 0.28,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(options.boardTheme.accentColor).withOpacity(0.7),
                                          ),
                                        )
                                      : Container(
                                          width: squareSize * 0.88,
                                          height: squareSize * 0.88,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.redAccent.withOpacity(0.85),
                                              width: 3.5,
                                            ),
                                          ),
                                        ),
                                ),

                              if (showRank)
                                Positioned(
                                  top: 2,
                                  left: 3,
                                  child: Text(
                                    rankLabel,
                                    style: TextStyle(
                                      fontSize: squareSize * 0.18,
                                      fontWeight: FontWeight.bold,
                                      color: textColor.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                              if (showFile)
                                Positioned(
                                  bottom: 2,
                                  right: 3,
                                  child: Text(
                                    fileLabel,
                                    style: TextStyle(
                                      fontSize: squareSize * 0.18,
                                      fontWeight: FontWeight.bold,
                                      color: textColor.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              // 2. Animated Pieces Overlay
              ...pieceWidgets,
            ],
          ),
        ),
      ),
    );
  }
}
