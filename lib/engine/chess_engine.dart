import '../models/move.dart';
import '../models/piece.dart';
import '../models/position.dart';

class GameStateSnapshot {
  final List<List<ChessPiece?>> board;
  final PieceColor turn;
  final Position? enPassantTarget;
  final int halfMoveClock;
  final int fullMoveNumber;
  final List<ChessPiece> capturedWhite;
  final List<ChessPiece> capturedBlack;
  final ChessMove? lastMove;

  GameStateSnapshot({
    required List<List<ChessPiece?>> board,
    required this.turn,
    required this.enPassantTarget,
    required this.halfMoveClock,
    required this.fullMoveNumber,
    required List<ChessPiece> capturedWhite,
    required List<ChessPiece> capturedBlack,
    required this.lastMove,
  })  : board = List.generate(8, (r) => List.from(board[r])),
        capturedWhite = List.from(capturedWhite),
        capturedBlack = List.from(capturedBlack);
}

enum GameStatus {
  inProgress,
  checkmate,
  stalemate,
  draw50MoveRule,
  drawThreefoldRepetition,
  drawInsufficientMaterial,
}

class ChessEngine {
  late List<List<ChessPiece?>> _board;
  PieceColor _turn = PieceColor.white;
  Position? _enPassantTarget; // Square behind the pawn that just moved 2 ranks
  int _halfMoveClock = 0; // For 50-move rule
  int _fullMoveNumber = 1;

  final List<ChessPiece> _capturedWhite = [];
  final List<ChessPiece> _capturedBlack = [];
  final List<ChessMove> _moveHistory = [];
  final List<GameStateSnapshot> _historySnapshots = [];
  final List<String> _fenHistory = [];

  ChessMove? _lastMove;
  GameStatus _status = GameStatus.inProgress;
  PieceColor? _winner;

  ChessEngine() {
    resetBoard();
  }

  // Getters
  List<List<ChessPiece?>> get board => _board;
  PieceColor get turn => _turn;
  Position? get enPassantTarget => _enPassantTarget;
  int get halfMoveClock => _halfMoveClock;
  int get fullMoveNumber => _fullMoveNumber;
  List<ChessPiece> get capturedWhite => List.unmodifiable(_capturedWhite);
  List<ChessPiece> get capturedBlack => List.unmodifiable(_capturedBlack);
  List<ChessMove> get moveHistory => List.unmodifiable(_moveHistory);
  ChessMove? get lastMove => _lastMove;
  GameStatus get status => _status;
  PieceColor? get winner => _winner;

  bool get isGameOver => _status != GameStatus.inProgress;

  int get whiteMaterial => _capturedBlack.fold(0, (sum, p) => sum + p.value);
  int get blackMaterial => _capturedWhite.fold(0, (sum, p) => sum + p.value);
  int get whiteAdvantage => whiteMaterial - blackMaterial;
  int get blackAdvantage => blackMaterial - whiteMaterial;

  void resetBoard() {
    _board = List.generate(8, (_) => List.filled(8, null));
    _turn = PieceColor.white;
    _enPassantTarget = null;
    _halfMoveClock = 0;
    _fullMoveNumber = 1;
    _capturedWhite.clear();
    _capturedBlack.clear();
    _moveHistory.clear();
    _historySnapshots.clear();
    _fenHistory.clear();
    _lastMove = null;
    _status = GameStatus.inProgress;
    _winner = null;

    // Set up Black pieces
    _board[0][0] = const ChessPiece(id: 'b_rook_0', type: PieceType.rook, color: PieceColor.black);
    _board[0][1] = const ChessPiece(id: 'b_knight_1', type: PieceType.knight, color: PieceColor.black);
    _board[0][2] = const ChessPiece(id: 'b_bishop_2', type: PieceType.bishop, color: PieceColor.black);
    _board[0][3] = const ChessPiece(id: 'b_queen_3', type: PieceType.queen, color: PieceColor.black);
    _board[0][4] = const ChessPiece(id: 'b_king_4', type: PieceType.king, color: PieceColor.black);
    _board[0][5] = const ChessPiece(id: 'b_bishop_5', type: PieceType.bishop, color: PieceColor.black);
    _board[0][6] = const ChessPiece(id: 'b_knight_6', type: PieceType.knight, color: PieceColor.black);
    _board[0][7] = const ChessPiece(id: 'b_rook_7', type: PieceType.rook, color: PieceColor.black);
    for (int col = 0; col < 8; col++) {
      _board[1][col] = ChessPiece(id: 'b_pawn_$col', type: PieceType.pawn, color: PieceColor.black);
    }

    // Set up White pieces
    for (int col = 0; col < 8; col++) {
      _board[6][col] = ChessPiece(id: 'w_pawn_$col', type: PieceType.pawn, color: PieceColor.white);
    }
    _board[7][0] = const ChessPiece(id: 'w_rook_0', type: PieceType.rook, color: PieceColor.white);
    _board[7][1] = const ChessPiece(id: 'w_knight_1', type: PieceType.knight, color: PieceColor.white);
    _board[7][2] = const ChessPiece(id: 'w_bishop_2', type: PieceType.bishop, color: PieceColor.white);
    _board[7][3] = const ChessPiece(id: 'w_queen_3', type: PieceType.queen, color: PieceColor.white);
    _board[7][4] = const ChessPiece(id: 'w_king_4', type: PieceType.king, color: PieceColor.white);
    _board[7][5] = const ChessPiece(id: 'w_bishop_5', type: PieceType.bishop, color: PieceColor.white);
    _board[7][6] = const ChessPiece(id: 'w_knight_6', type: PieceType.knight, color: PieceColor.white);
    _board[7][7] = const ChessPiece(id: 'w_rook_7', type: PieceType.rook, color: PieceColor.white);

    _recordFEN();
  }

  bool loadFen(String fen) {
    try {
      final parts = fen.trim().split(' ');
      if (parts.isEmpty) return false;

      final rows = parts[0].split('/');
      if (rows.length != 8) return false;

      final newBoard = List.generate(8, (_) => List<ChessPiece?>.filled(8, null));

      for (int r = 0; r < 8; r++) {
        int c = 0;
        for (int i = 0; i < rows[r].length; i++) {
          final char = rows[r][i];
          final digit = int.tryParse(char);
          if (digit != null) {
            c += digit;
          } else {
            PieceColor color = char == char.toUpperCase() ? PieceColor.white : PieceColor.black;
            PieceType type;
            switch (char.toLowerCase()) {
              case 'p': type = PieceType.pawn; break;
              case 'n': type = PieceType.knight; break;
              case 'b': type = PieceType.bishop; break;
              case 'r': type = PieceType.rook; break;
              case 'q': type = PieceType.queen; break;
              case 'k': type = PieceType.king; break;
              default: return false;
            }
            if (c < 8) {
              newBoard[r][c] = ChessPiece(id: 'fen_${r}_$c', type: type, color: color);
              c++;
            }
          }
        }
      }

      _board = newBoard;
      _turn = (parts.length > 1 && parts[1] == 'b') ? PieceColor.black : PieceColor.white;
      _status = GameStatus.inProgress;
      _winner = null;
      _moveHistory.clear();
      _historySnapshots.clear();
      _recordFEN();
      return true;
    } catch (_) {
      return false;
    }
  }

  ChessPiece? pieceAt(Position pos) {
    if (!pos.isValid) return null;
    return _board[pos.row][pos.col];
  }

  Position? findKing(PieceColor color) {
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = _board[r][c];
        if (p != null && p.type == PieceType.king && p.color == color) {
          return Position(r, c);
        }
      }
    }
    return null;
  }

  bool isSquareAttacked(Position pos, PieceColor attackingColor) {
    // 1. Pawn attacks
    final pawnDir = attackingColor == PieceColor.white ? -1 : 1;
    final pawnRow = pos.row - pawnDir;
    for (final dc in [-1, 1]) {
      final pCol = pos.col + dc;
      if (pawnRow >= 0 && pawnRow < 8 && pCol >= 0 && pCol < 8) {
        final p = _board[pawnRow][pCol];
        if (p != null && p.color == attackingColor && p.type == PieceType.pawn) {
          return true;
        }
      }
    }

    // 2. Knight attacks
    final knightMoves = [
      [-2, -1], [-2, 1], [-1, -2], [-1, 2],
      [1, -2], [1, 2], [2, -1], [2, 1]
    ];
    for (final m in knightMoves) {
      final r = pos.row + m[0];
      final c = pos.col + m[1];
      if (r >= 0 && r < 8 && c >= 0 && c < 8) {
        final p = _board[r][c];
        if (p != null && p.color == attackingColor && p.type == PieceType.knight) {
          return true;
        }
      }
    }

    // 3. King attacks
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final r = pos.row + dr;
        final c = pos.col + dc;
        if (r >= 0 && r < 8 && c >= 0 && c < 8) {
          final p = _board[r][c];
          if (p != null && p.color == attackingColor && p.type == PieceType.king) {
            return true;
          }
        }
      }
    }

    // 4. Straight lines (Rook / Queen)
    final straightDirs = [[-1, 0], [1, 0], [0, -1], [0, 1]];
    for (final dir in straightDirs) {
      int r = pos.row + dir[0];
      int c = pos.col + dir[1];
      while (r >= 0 && r < 8 && c >= 0 && c < 8) {
        final p = _board[r][c];
        if (p != null) {
          if (p.color == attackingColor && (p.type == PieceType.rook || p.type == PieceType.queen)) {
            return true;
          }
          break; // Line blocked
        }
        r += dir[0];
        c += dir[1];
      }
    }

    // 5. Diagonal lines (Bishop / Queen)
    final diagDirs = [[-1, -1], [-1, 1], [1, -1], [1, 1]];
    for (final dir in diagDirs) {
      int r = pos.row + dir[0];
      int c = pos.col + dir[1];
      while (r >= 0 && r < 8 && c >= 0 && c < 8) {
        final p = _board[r][c];
        if (p != null) {
          if (p.color == attackingColor && (p.type == PieceType.bishop || p.type == PieceType.queen)) {
            return true;
          }
          break; // Line blocked
        }
        r += dir[0];
        c += dir[1];
      }
    }

    return false;
  }

  bool isInCheck(PieceColor color) {
    final kingPos = findKing(color);
    if (kingPos == null) return false;
    return isSquareAttacked(kingPos, color.opposite);
  }

  List<Position> getLegalMoves(Position from) {
    if (isGameOver) return [];
    final piece = pieceAt(from);
    if (piece == null || piece.color != _turn) return [];

    final pseudoMoves = _getPseudoLegalMoves(from, piece);
    final legalMoves = <Position>[];

    for (final to in pseudoMoves) {
      if (!_wouldBeInCheck(from, to, piece)) {
        legalMoves.add(to);
      }
    }

    return legalMoves;
  }

  List<Position> _getPseudoLegalMoves(Position from, ChessPiece piece) {
    final moves = <Position>[];
    final row = from.row;
    final col = from.col;
    final color = piece.color;

    switch (piece.type) {
      case PieceType.pawn:
        final dir = color == PieceColor.white ? -1 : 1;
        final startRow = color == PieceColor.white ? 6 : 1;

        // One step forward
        final forwardRow = row + dir;
        if (forwardRow >= 0 && forwardRow < 8 && _board[forwardRow][col] == null) {
          moves.add(Position(forwardRow, col));

          // Two steps forward from start rank
          final doubleRow = row + (2 * dir);
          if (row == startRow && _board[doubleRow][col] == null) {
            moves.add(Position(doubleRow, col));
          }
        }

        // Standard captures
        for (final dc in [-1, 1]) {
          final cCol = col + dc;
          if (cCol >= 0 && cCol < 8 && forwardRow >= 0 && forwardRow < 8) {
            final target = _board[forwardRow][cCol];
            if (target != null && target.color != color) {
              moves.add(Position(forwardRow, cCol));
            }
            // En Passant capture
            if (_enPassantTarget != null &&
                _enPassantTarget!.row == forwardRow &&
                _enPassantTarget!.col == cCol) {
              moves.add(Position(forwardRow, cCol));
            }
          }
        }
        break;

      case PieceType.knight:
        final offsets = [
          [-2, -1], [-2, 1], [-1, -2], [-1, 2],
          [1, -2], [1, 2], [2, -1], [2, 1]
        ];
        for (final off in offsets) {
          final r = row + off[0];
          final c = col + off[1];
          if (r >= 0 && r < 8 && c >= 0 && c < 8) {
            final target = _board[r][c];
            if (target == null || target.color != color) {
              moves.add(Position(r, c));
            }
          }
        }
        break;

      case PieceType.bishop:
        _addSlidingMoves(from, piece, [[-1, -1], [-1, 1], [1, -1], [1, 1]], moves);
        break;

      case PieceType.rook:
        _addSlidingMoves(from, piece, [[-1, 0], [1, 0], [0, -1], [0, 1]], moves);
        break;

      case PieceType.queen:
        _addSlidingMoves(from, piece, [
          [-1, -1], [-1, 1], [1, -1], [1, 1],
          [-1, 0], [1, 0], [0, -1], [0, 1]
        ], moves);
        break;

      case PieceType.king:
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            final r = row + dr;
            final c = col + dc;
            if (r >= 0 && r < 8 && c >= 0 && c < 8) {
              final target = _board[r][c];
              if (target == null || target.color != color) {
                moves.add(Position(r, c));
              }
            }
          }
        }

        // Castling moves
        if (!piece.hasMoved && !isInCheck(color)) {
          // Kingside Castling
          final rookKingside = _board[row][7];
          if (rookKingside != null &&
              rookKingside.type == PieceType.rook &&
              rookKingside.color == color &&
              !rookKingside.hasMoved) {
            if (_board[row][5] == null && _board[row][6] == null) {
              if (!isSquareAttacked(Position(row, 5), color.opposite) &&
                  !isSquareAttacked(Position(row, 6), color.opposite)) {
                moves.add(Position(row, 6));
              }
            }
          }

          // Queenside Castling
          final rookQueenside = _board[row][0];
          if (rookQueenside != null &&
              rookQueenside.type == PieceType.rook &&
              rookQueenside.color == color &&
              !rookQueenside.hasMoved) {
            if (_board[row][1] == null &&
                _board[row][2] == null &&
                _board[row][3] == null) {
              if (!isSquareAttacked(Position(row, 2), color.opposite) &&
                  !isSquareAttacked(Position(row, 3), color.opposite)) {
                moves.add(Position(row, 2));
              }
            }
          }
        }
        break;
    }

    return moves;
  }

  void _addSlidingMoves(Position from, ChessPiece piece, List<List<int>> dirs, List<Position> moves) {
    for (final dir in dirs) {
      int r = from.row + dir[0];
      int c = from.col + dir[1];
      while (r >= 0 && r < 8 && c >= 0 && c < 8) {
        final target = _board[r][c];
        if (target == null) {
          moves.add(Position(r, c));
        } else {
          if (target.color != piece.color) {
            moves.add(Position(r, c));
          }
          break; // Stop at first obstruction
        }
        r += dir[0];
        c += dir[1];
      }
    }
  }

  bool _wouldBeInCheck(Position from, Position to, ChessPiece piece) {
    final originalToPiece = _board[to.row][to.col];
    Position? enPassantCapturedPos;
    ChessPiece? enPassantCapturedPiece;

    // Handle En Passant simulation
    if (piece.type == PieceType.pawn &&
        _enPassantTarget != null &&
        to == _enPassantTarget) {
      final epRow = piece.color == PieceColor.white ? to.row + 1 : to.row - 1;
      enPassantCapturedPos = Position(epRow, to.col);
      enPassantCapturedPiece = _board[epRow][to.col];
      _board[epRow][to.col] = null;
    }

    // Execute move on board temporarily
    _board[from.row][from.col] = null;
    _board[to.row][to.col] = piece;

    final inCheck = isInCheck(piece.color);

    // Revert move
    _board[from.row][from.col] = piece;
    _board[to.row][to.col] = originalToPiece;
    if (enPassantCapturedPos != null) {
      _board[enPassantCapturedPos.row][enPassantCapturedPos.col] = enPassantCapturedPiece;
    }

    return inCheck;
  }

  bool makeMove(Position from, Position to, {PieceType? promotionPiece}) {
    if (isGameOver) return false;
    final piece = pieceAt(from);
    if (piece == null || piece.color != _turn) return false;

    final legalMoves = getLegalMoves(from);
    if (!legalMoves.contains(to)) return false;

    // Save snapshot for Undo
    _historySnapshots.add(GameStateSnapshot(
      board: _board,
      turn: _turn,
      enPassantTarget: _enPassantTarget,
      halfMoveClock: _halfMoveClock,
      fullMoveNumber: _fullMoveNumber,
      capturedWhite: _capturedWhite,
      capturedBlack: _capturedBlack,
      lastMove: _lastMove,
    ));

    ChessPiece targetPiece = pieceAt(to) ?? piece;
    ChessPiece? captured = _board[to.row][to.col];
    bool isKingsideCastling = false;
    bool isQueensideCastling = false;
    bool isEnPassant = false;

    // 1. Pawn En Passant Execution
    if (piece.type == PieceType.pawn &&
        _enPassantTarget != null &&
        to == _enPassantTarget) {
      isEnPassant = true;
      final epRow = piece.color == PieceColor.white ? to.row + 1 : to.row - 1;
      captured = _board[epRow][to.col];
      _board[epRow][to.col] = null;
    }

    // 2. King Castling Execution
    if (piece.type == PieceType.king && (from.col - to.col).abs() == 2) {
      if (to.col == 6) {
        // Kingside
        isKingsideCastling = true;
        final rook = _board[from.row][7];
        _board[from.row][7] = null;
        _board[from.row][5] = rook?.copyWith(hasMoved: true);
      } else if (to.col == 2) {
        // Queenside
        isQueensideCastling = true;
        final rook = _board[from.row][0];
        _board[from.row][0] = null;
        _board[from.row][3] = rook?.copyWith(hasMoved: true);
      }
    }

    // Record Captured Piece
    if (captured != null) {
      if (captured.color == PieceColor.white) {
        _capturedWhite.add(captured);
      } else {
        _capturedBlack.add(captured);
      }
      _halfMoveClock = 0; // Reset 50-move clock on capture
    } else if (piece.type == PieceType.pawn) {
      _halfMoveClock = 0; // Reset 50-move clock on pawn move
    } else {
      _halfMoveClock++;
    }

    // 3. Update En Passant Target for next turn
    if (piece.type == PieceType.pawn && (from.row - to.row).abs() == 2) {
      final epRow = (from.row + to.row) ~/ 2;
      _enPassantTarget = Position(epRow, from.col);
    } else {
      _enPassantTarget = null;
    }

    // 4. Pawn Promotion
    PieceType? promotedTo;
    if (piece.type == PieceType.pawn && (to.row == 0 || to.row == 7)) {
      promotedTo = promotionPiece ?? PieceType.queen;
      targetPiece = piece.copyWith(type: promotedTo, hasMoved: true);
    } else {
      targetPiece = piece.copyWith(hasMoved: true);
    }

    // Move piece on board
    _board[from.row][from.col] = null;
    _board[to.row][to.col] = targetPiece;

    // Turn transition
    _turn = _turn.opposite;
    if (_turn == PieceColor.white) {
      _fullMoveNumber++;
    }

    // Check & Checkmate evaluation for opponent
    final opponentInCheck = isInCheck(_turn);
    final opponentHasMoves = _hasAnyLegalMoves(_turn);
    final opponentCheckmate = opponentInCheck && !opponentHasMoves;

    // Generate SAN notation string
    final san = _generateSAN(
      from: from,
      to: to,
      piece: piece,
      captured: captured,
      promotion: promotedTo,
      isKingsideCastling: isKingsideCastling,
      isQueensideCastling: isQueensideCastling,
      isCheck: opponentInCheck,
      isCheckmate: opponentCheckmate,
    );

    _lastMove = ChessMove(
      from: from,
      to: to,
      pieceMoved: piece,
      pieceCaptured: captured,
      promotionPiece: promotedTo,
      isKingsideCastling: isKingsideCastling,
      isQueensideCastling: isQueensideCastling,
      isEnPassant: isEnPassant,
      isCheck: opponentInCheck,
      isCheckmate: opponentCheckmate,
      san: san,
    );
    _moveHistory.add(_lastMove!);

    // Game Status Evaluation
    if (opponentCheckmate) {
      _status = GameStatus.checkmate;
      _winner = _turn.opposite;
    } else if (!opponentInCheck && !opponentHasMoves) {
      _status = GameStatus.stalemate;
    } else if (_halfMoveClock >= 100) {
      _status = GameStatus.draw50MoveRule;
    } else if (isInsufficientMaterial()) {
      _status = GameStatus.drawInsufficientMaterial;
    } else if (_checkThreefoldRepetition()) {
      _status = GameStatus.drawThreefoldRepetition;
    }

    _recordFEN();
    return true;
  }

  bool undoMove() {
    if (_historySnapshots.isEmpty) return false;

    final snapshot = _historySnapshots.removeLast();
    _board = snapshot.board;
    _turn = snapshot.turn;
    _enPassantTarget = snapshot.enPassantTarget;
    _halfMoveClock = snapshot.halfMoveClock;
    _fullMoveNumber = snapshot.fullMoveNumber;

    _capturedWhite.clear();
    _capturedWhite.addAll(snapshot.capturedWhite);
    _capturedBlack.clear();
    _capturedBlack.addAll(snapshot.capturedBlack);

    if (_moveHistory.isNotEmpty) {
      _moveHistory.removeLast();
    }
    _lastMove = snapshot.lastMove;
    if (_fenHistory.isNotEmpty) {
      _fenHistory.removeLast();
    }

    _status = GameStatus.inProgress;
    _winner = null;
    return true;
  }

  bool _hasAnyLegalMoves(PieceColor color) {
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = _board[r][c];
        if (p != null && p.color == color) {
          final legal = getLegalMoves(Position(r, c));
          if (legal.isNotEmpty) return true;
        }
      }
    }
    return false;
  }

  List<ChessMove> getAllLegalMoves(PieceColor color) {
    final allMoves = <ChessMove>[];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = _board[r][c];
        if (p != null && p.color == color) {
          final from = Position(r, c);
          final destinations = getLegalMoves(from);
          for (final to in destinations) {
            // Check for promotion possibilities
            if (p.type == PieceType.pawn && (to.row == 0 || to.row == 7)) {
              for (final promo in [PieceType.queen, PieceType.rook, PieceType.bishop, PieceType.knight]) {
                allMoves.add(ChessMove(
                  from: from,
                  to: to,
                  pieceMoved: p,
                  pieceCaptured: pieceAt(to),
                  promotionPiece: promo,
                  san: '${to.algebraic}=${_pieceSymbol(promo)}',
                ));
              }
            } else {
              allMoves.add(ChessMove(
                from: from,
                to: to,
                pieceMoved: p,
                pieceCaptured: pieceAt(to),
                san: '${p.pgnSymbol}${to.algebraic}',
              ));
            }
          }
        }
      }
    }
    return allMoves;
  }

  bool isInsufficientMaterial() {
    final pieces = <ChessPiece>[];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = _board[r][c];
        if (p != null) pieces.add(p);
      }
    }

    // King vs King
    if (pieces.length == 2) return true;

    // King & Bishop vs King OR King & Knight vs King
    if (pieces.length == 3) {
      final nonKings = pieces.where((p) => p.type != PieceType.king);
      if (nonKings.isNotEmpty) {
        final type = nonKings.first.type;
        if (type == PieceType.bishop || type == PieceType.knight) return true;
      }
    }

    // King & Bishop vs King & Bishop with same color square bishops
    if (pieces.length == 4) {
      final whiteBishops = pieces.where((p) => p.color == PieceColor.white && p.type == PieceType.bishop);
      final blackBishops = pieces.where((p) => p.color == PieceColor.black && p.type == PieceType.bishop);

      if (whiteBishops.length == 1 && blackBishops.length == 1) {
        // Find square colors for both bishops
        int? wBishopSquareColor;
        int? bBishopSquareColor;
        for (int r = 0; r < 8; r++) {
          for (int c = 0; c < 8; c++) {
            final p = _board[r][c];
            if (p != null && p.type == PieceType.bishop) {
              final squareColor = (r + c) % 2;
              if (p.color == PieceColor.white) wBishopSquareColor = squareColor;
              if (p.color == PieceColor.black) bBishopSquareColor = squareColor;
            }
          }
        }
        if (wBishopSquareColor == bBishopSquareColor) return true;
      }
    }

    return false;
  }

  bool _checkThreefoldRepetition() {
    if (_fenHistory.length < 3) return false;
    final currentFen = _fenHistory.last;
    final count = _fenHistory.where((fen) => fen == currentFen).length;
    return count >= 3;
  }

  void _recordFEN() {
    final buffer = StringBuffer();
    for (int r = 0; r < 8; r++) {
      int empty = 0;
      for (int c = 0; c < 8; c++) {
        final p = _board[r][c];
        if (p == null) {
          empty++;
        } else {
          if (empty > 0) {
            buffer.write(empty);
            empty = 0;
          }
          buffer.write(p.fenChar);
        }
      }
      if (empty > 0) buffer.write(empty);
      if (r < 7) buffer.write('/');
    }
    buffer.write(' ${_turn == PieceColor.white ? 'w' : 'b'}');
    _fenHistory.add(buffer.toString());
  }

  String _generateSAN({
    required Position from,
    required Position to,
    required ChessPiece piece,
    required ChessPiece? captured,
    required PieceType? promotion,
    required bool isKingsideCastling,
    required bool isQueensideCastling,
    required bool isCheck,
    required bool isCheckmate,
  }) {
    if (isKingsideCastling) return 'O-O${isCheckmate ? '#' : (isCheck ? '+' : '')}';
    if (isQueensideCastling) return 'O-O-O${isCheckmate ? '#' : (isCheck ? '+' : '')}';

    final sb = StringBuffer();
    if (piece.type != PieceType.pawn) {
      sb.write(piece.pgnSymbol);
      // Disambiguation if multiple pieces of same type can move to 'to' square
      final disambig = _getDisambiguation(from, to, piece);
      sb.write(disambig);
    }

    if (captured != null) {
      if (piece.type == PieceType.pawn) {
        sb.write(String.fromCharCode('a'.codeUnitAt(0) + from.col));
      }
      sb.write('x');
    }

    sb.write(to.algebraic);

    if (promotion != null) {
      sb.write('=${_pieceSymbol(promotion)}');
    }

    if (isCheckmate) {
      sb.write('#');
    } else if (isCheck) {
      sb.write('+');
    }

    return sb.toString();
  }

  String _getDisambiguation(Position from, Position to, ChessPiece piece) {
    final samePieceSources = <Position>[];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (r == from.row && c == from.col) continue;
        final p = _board[r][c];
        if (p != null && p.type == piece.type && p.color == piece.color) {
          final pseudo = _getPseudoLegalMoves(Position(r, c), p);
          if (pseudo.contains(to) && !_wouldBeInCheck(Position(r, c), to, p)) {
            samePieceSources.add(Position(r, c));
          }
        }
      }
    }

    if (samePieceSources.isEmpty) return '';

    final sameCol = samePieceSources.any((pos) => pos.col == from.col);
    final sameRow = samePieceSources.any((pos) => pos.row == from.row);

    if (!sameCol) {
      return String.fromCharCode('a'.codeUnitAt(0) + from.col);
    } else if (!sameRow) {
      return (8 - from.row).toString();
    } else {
      return from.algebraic;
    }
  }

  String _pieceSymbol(PieceType type) {
    switch (type) {
      case PieceType.queen: return 'Q';
      case PieceType.rook: return 'R';
      case PieceType.bishop: return 'B';
      case PieceType.knight: return 'N';
      default: return '';
    }
  }
}
