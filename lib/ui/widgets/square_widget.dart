import 'package:flutter/material.dart';
import '../../models/game_options.dart';
import '../../models/piece.dart';
import '../../models/position.dart';
import 'piece_widget.dart';

class SquareWidget extends StatelessWidget {
  final Position position;
  final ChessPiece? piece;
  final bool isLightSquare;
  final bool isSelected;
  final bool isPossibleMove;
  final bool isLastMove;
  final bool isInCheck;
  final BoardThemeOption theme;
  final bool showRank;
  final bool showFile;
  final String rankLabel;
  final String fileLabel;
  final double size;
  final VoidCallback onTap;
  final Function(Position from, Position to) onPieceDropped;

  const SquareWidget({
    super.key,
    required this.position,
    required this.piece,
    required this.isLightSquare,
    required this.isSelected,
    required this.isPossibleMove,
    required this.isLastMove,
    required this.isInCheck,
    required this.theme,
    required this.showRank,
    required this.showFile,
    required this.rankLabel,
    required this.fileLabel,
    required this.size,
    required this.onTap,
    required this.onPieceDropped,
  });

  @override
  Widget build(BuildContext context) {
    Color squareColor = isLightSquare
        ? Color(theme.lightSquareColor)
        : Color(theme.darkSquareColor);

    if (isLastMove) {
      squareColor = Color.alphaBlend(
        Color(theme.accentColor).withOpacity(0.35),
        squareColor,
      );
    }

    if (isSelected) {
      squareColor = Color.alphaBlend(
        Color(theme.accentColor).withOpacity(0.65),
        squareColor,
      );
    }

    if (isInCheck) {
      squareColor = Color.alphaBlend(
        Colors.red.withOpacity(0.7),
        squareColor,
      );
    }

    final textColor = isLightSquare
        ? Color(theme.darkSquareColor)
        : Color(theme.lightSquareColor);

    return DragTarget<Position>(
      onWillAcceptWithDetails: (details) => details.data != position,
      onAcceptWithDetails: (details) {
        onPieceDropped(details.data, position);
      },
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: squareColor,
              border: isSelected
                  ? Border.all(color: Color(theme.accentColor), width: 2.5)
                  : null,
            ),
            child: Stack(
              children: [
                // Piece or Draggable Piece
                if (piece != null)
                  Center(
                    child: Draggable<Position>(
                      data: position,
                      feedback: Material(
                        color: Colors.transparent,
                        child: PieceWidget(
                          piece: piece!,
                          size: size * 1.15,
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: PieceWidget(
                          piece: piece!,
                          size: size,
                        ),
                      ),
                      child: PieceWidget(
                        piece: piece!,
                        size: size,
                      ),
                    ),
                  ),

                // Move Target Indicator (Dot for empty, Ring for capture)
                if (isPossibleMove)
                  Center(
                    child: piece == null
                        ? Container(
                            width: size * 0.28,
                            height: size * 0.28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(theme.accentColor).withOpacity(0.7),
                            ),
                          )
                        : Container(
                            width: size * 0.88,
                            height: size * 0.88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.redAccent.withOpacity(0.85),
                                width: 3.5,
                              ),
                            ),
                          ),
                  ),

                // Rank coordinate notation (1-8)
                if (showRank)
                  Positioned(
                    top: 2,
                    left: 3,
                    child: Text(
                      rankLabel,
                      style: TextStyle(
                        fontSize: size * 0.2,
                        fontWeight: FontWeight.bold,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                  ),

                // File coordinate notation (a-h)
                if (showFile)
                  Positioned(
                    bottom: 2,
                    right: 3,
                    child: Text(
                      fileLabel,
                      style: TextStyle(
                        fontSize: size * 0.2,
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
  }
}
