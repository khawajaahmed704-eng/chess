import 'dart:math';
import '../models/game_options.dart';
import '../models/move.dart';
import '../models/piece.dart';
import '../models/position.dart';
import 'chess_engine.dart';

class ChessAI {
  static const int infinity = 1000000;

  static final List<List<int>> pawnTable = [
    [0,  0,  0,  0,  0,  0,  0,  0],
    [50, 50, 50, 50, 50, 50, 50, 50],
    [10, 10, 20, 30, 30, 20, 10, 10],
    [ 5,  5, 10, 25, 25, 10,  5,  5],
    [ 0,  0,  0, 20, 20,  0,  0,  0],
    [ 5, -5,-10,  0,  0,-10, -5,  5],
    [ 5, 10, 10,-20,-20, 10, 10,  5],
    [0,  0,  0,  0,  0,  0,  0,  0]
  ];

  static final List<List<int>> knightTable = [
    [-50,-40,-30,-30,-30,-30,-40,-50],
    [-40,-20,  0,  0,  0,  0,-20,-40],
    [-30,  0, 10, 15, 15, 10,  0,-30],
    [-30,  5, 15, 20, 20, 15,  5,-30],
    [-30,  0, 15, 20, 20, 15,  0,-30],
    [-30,  5, 10, 15, 15, 10,  5,-30],
    [-40,-20,  0,  5,  5,  0,-20,-40],
    [-50,-40,-30,-30,-30,-30,-40,-50]
  ];

  static final List<List<int>> bishopTable = [
    [-20,-10,-10,-10,-10,-10,-10,-20],
    [-10,  0,  0,  0,  0,  0,  0,-10],
    [-10,  0,  5, 10, 10,  5,  0,-10],
    [-10,  5,  5, 10, 10,  5,  5,-10],
    [-10,  0, 10, 10, 10, 10,  0,-10],
    [-10, 10, 10, 10, 10, 10, 10,-10],
    [-10,  5,  0,  0,  0,  0,  5,-10],
    [-20,-10,-10,-10,-10,-10,-10,-20]
  ];

  static final List<List<int>> rookTable = [
    [0,  0,  0,  0,  0,  0,  0,  0],
    [5, 10, 10, 10, 10, 10, 10,  5],
    [-5,  0,  0,  0,  0,  0,  0, -5],
    [-5,  0,  0,  0,  0,  0,  0, -5],
    [-5,  0,  0,  0,  0,  0,  0, -5],
    [-5,  0,  0,  0,  0,  0,  0, -5],
    [-5,  0,  0,  0,  0,  0,  0, -5],
    [0,  0,  0,  5,  5,  0,  0,  0]
  ];

  static final List<List<int>> queenTable = [
    [-20,-10,-10, -5, -5,-10,-10,-20],
    [-10,  0,  0,  0,  0,  0,  0,-10],
    [-10,  0,  5,  5,  5,  5,  0,-10],
    [ -5,  0,  5,  5,  5,  5,  0, -5],
    [  0,  0,  5,  5,  5,  5,  0, -5],
    [-10,  5,  5,  5,  5,  5,  0,-10],
    [-10,  0,  5,  0,  0,  0,  0,-10],
    [-20,-10,-10, -5, -5,-10,-10,-20]
  ];

  static final List<List<int>> kingMiddleTable = [
    [-30,-40,-40,-50,-50,-40,-40,-30],
    [-30,-40,-40,-50,-50,-40,-40,-30],
    [-30,-40,-40,-50,-50,-40,-40,-30],
    [-30,-40,-40,-50,-50,-40,-40,-30],
    [-20,-30,-30,-40,-40,-30,-30,-20],
    [-10,-20,-20,-20,-20,-20,-20,-10],
    [ 20, 20,  0,  0,  0,  0, 20, 20],
    [ 20, 30, 10,  0,  0, 10, 30, 20]
  ];

  static Future<ChessMove?> getBestMove(ChessEngine engine, ExtendedAIDifficulty difficulty) async {
    final moves = engine.getAllLegalMoves(engine.turn);
    if (moves.isEmpty) return null;

    final random = Random();

    if (difficulty == ExtendedAIDifficulty.beginner) {
      // 50% blunder / random move, 50% simple move
      if (random.nextDouble() < 0.5) {
        return moves[random.nextInt(moves.length)];
      }
    }

    if (difficulty == ExtendedAIDifficulty.casual) {
      final captureMoves = moves.where((m) => m.pieceCaptured != null).toList();
      if (captureMoves.isNotEmpty && random.nextDouble() < 0.6) {
        return captureMoves[random.nextInt(captureMoves.length)];
      }
      return moves[random.nextInt(moves.length)];
    }

    int depth = 2;
    if (difficulty == ExtendedAIDifficulty.advanced || difficulty == ExtendedAIDifficulty.expert) {
      depth = 3;
    } else if (difficulty == ExtendedAIDifficulty.adaptive) {
      // Adaptive depth based on move count
      depth = engine.moveHistory.length > 20 ? 3 : 2;
    }

    final isMaximizing = engine.turn == PieceColor.white;
    ChessMove? bestMove;
    int bestScore = isMaximizing ? -infinity : infinity;

    for (final move in moves) {
      engine.makeMove(move.from, move.to, promotionPiece: move.promotionPiece);
      final score = _minimax(engine, depth - 1, -infinity, infinity, !isMaximizing);
      engine.undoMove();

      if (isMaximizing) {
        if (score > bestScore) {
          bestScore = score;
          bestMove = move;
        }
      } else {
        if (score < bestScore) {
          bestScore = score;
          bestMove = move;
        }
      }
    }

    return bestMove ?? moves.first;
  }

  static int _minimax(ChessEngine engine, int depth, int alpha, int beta, bool isMaximizing) {
    if (depth == 0 || engine.isGameOver) {
      return _evaluateBoard(engine);
    }

    final moves = engine.getAllLegalMoves(engine.turn);
    if (moves.isEmpty) {
      if (engine.isInCheck(engine.turn)) {
        return isMaximizing ? -infinity + 100 : infinity - 100;
      }
      return 0;
    }

    if (isMaximizing) {
      int maxEval = -infinity;
      for (final move in moves) {
        engine.makeMove(move.from, move.to, promotionPiece: move.promotionPiece);
        final eval = _minimax(engine, depth - 1, alpha, beta, false);
        engine.undoMove();
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      int minEval = infinity;
      for (final move in moves) {
        engine.makeMove(move.from, move.to, promotionPiece: move.promotionPiece);
        final eval = _minimax(engine, depth - 1, alpha, beta, true);
        engine.undoMove();
        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  static int _evaluateBoard(ChessEngine engine) {
    int totalScore = 0;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = engine.board[r][c];
        if (p == null) continue;

        final isWhite = p.color == PieceColor.white;
        int pieceVal = p.value * 100;

        int posScore = 0;
        final row = isWhite ? r : 7 - r;
        final col = c;

        switch (p.type) {
          case PieceType.pawn:
            posScore = pawnTable[row][col];
            break;
          case PieceType.knight:
            posScore = knightTable[row][col];
            break;
          case PieceType.bishop:
            posScore = bishopTable[row][col];
            break;
          case PieceType.rook:
            posScore = rookTable[row][col];
            break;
          case PieceType.queen:
            posScore = queenTable[row][col];
            break;
          case PieceType.king:
            posScore = kingMiddleTable[row][col];
            break;
        }

        final score = pieceVal + posScore;
        totalScore += isWhite ? score : -score;
      }
    }

    return totalScore;
  }
}
