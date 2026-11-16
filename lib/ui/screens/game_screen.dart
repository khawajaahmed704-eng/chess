import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../engine/chess_ai.dart';
import '../../engine/chess_engine.dart';
import '../../models/game_options.dart';
import '../../models/game_session.dart';
import '../../models/piece.dart';
import '../../models/position.dart';
import '../../models/time_control.dart';
import '../widgets/chess_board_widget.dart';
import '../widgets/chess_com_move_badge.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/move_log_widget.dart';
import '../widgets/pass_device_widget.dart';
import '../widgets/player_header_widget.dart';
import '../widgets/promotion_dialog.dart';
import 'settings_dialog.dart';

class GameScreen extends StatefulWidget {
  final GameOptions options;

  const GameScreen({
    super.key,
    this.options = const GameOptions(),
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late ChessEngine _engine;
  late GameOptions _options;
  SessionState _sessionState = SessionState.waitingToStart;

  Position? _selectedPosition;
  List<Position> _legalMoves = [];
  bool _isBoardFlipped = false;
  bool _isThinkingAI = false;
  bool _showingPassDeviceScreen = false;

  Timer? _timer;
  int _whiteTimeRemaining = 600;
  int _blackTimeRemaining = 600;
  int _lastTickTimestamp = 0;

  @override
  void initState() {
    super.initState();
    _options = widget.options;
    _engine = ChessEngine();

    if (_options.initialFen != null) {
      _engine.loadFen(_options.initialFen!);
    }

    _resetGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetGame() {
    _timer?.cancel();
    setState(() {
      _engine.resetBoard();
      if (_options.initialFen != null) {
        _engine.loadFen(_options.initialFen!);
      }
      _selectedPosition = null;
      _legalMoves = [];
      _isThinkingAI = false;
      _showingPassDeviceScreen = false;
      _sessionState = SessionState.playerTurn;

      _whiteTimeRemaining = _options.timeControl.baseSeconds;
      _blackTimeRemaining = _options.timeControl.baseSeconds;
      _isBoardFlipped = _options.mode == GameMode.vsAI && _options.aiColor == PieceColor.white;
    });

    if (!_options.timeControl.isCasual) {
      _startMonotonicTimer();
    }

    _checkAITurn();
  }

  void _startMonotonicTimer() {
    _timer?.cancel();
    _lastTickTimestamp = DateTime.now().millisecondsSinceEpoch;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_engine.isGameOver || _showingPassDeviceScreen) return;

      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsedSecs = ((now - _lastTickTimestamp) / 1000).round();
      if (elapsedSecs < 1) return;
      _lastTickTimestamp = now;

      setState(() {
        if (_engine.turn == PieceColor.white) {
          if (_whiteTimeRemaining > 0) {
            _whiteTimeRemaining = (_whiteTimeRemaining - elapsedSecs).clamp(0, 99999);
          } else {
            timer.cancel();
            _showTimeOutDialog(PieceColor.black);
          }
        } else {
          if (_blackTimeRemaining > 0) {
            _blackTimeRemaining = (_blackTimeRemaining - elapsedSecs).clamp(0, 99999);
          } else {
            timer.cancel();
            _showTimeOutDialog(PieceColor.white);
          }
        }
      });
    });
  }

  void _showTimeOutDialog(PieceColor winner) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Time Expired!'),
        content: Text('${winner == PieceColor.white ? "White" : "Black"} wins on time!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text('New Game'),
          ),
        ],
      ),
    );
  }

  void _onSquareTapped(Position pos) {
    if (_engine.isGameOver || _isThinkingAI || _showingPassDeviceScreen) return;

    final tappedPiece = _engine.pieceAt(pos);

    if (tappedPiece != null && tappedPiece.color == _engine.turn) {
      setState(() {
        _selectedPosition = pos;
        _legalMoves = _engine.getLegalMoves(pos);
        _sessionState = SessionState.pieceSelected;
      });
      return;
    }

    if (_selectedPosition != null && _legalMoves.contains(pos)) {
      _executeMove(_selectedPosition!, pos);
      return;
    }

    setState(() {
      _selectedPosition = null;
      _legalMoves = [];
      _sessionState = SessionState.playerTurn;
    });
  }

  Future<void> _executeMove(Position from, Position to) async {
    final piece = _engine.pieceAt(from);
    if (piece == null) return;

    PieceType? promoPiece;

    if (piece.type == PieceType.pawn && (to.row == 0 || to.row == 7)) {
      _sessionState = SessionState.awaitingPromotion;
      if (_options.mode == GameMode.vsAI && _engine.turn == _options.aiColor) {
        promoPiece = PieceType.queen;
      } else {
        promoPiece = await PromotionDialog.show(context, piece.color);
        if (promoPiece == null) return;
      }
    }

    _sessionState = SessionState.animatingMove;
    final movingColor = _engine.turn;

    final success = _engine.makeMove(from, to, promotionPiece: promoPiece);
    if (!success) return;

    if (!_options.timeControl.isCasual && _options.timeControl.incrementSeconds > 0) {
      if (movingColor == PieceColor.white) {
        _whiteTimeRemaining += _options.timeControl.incrementSeconds;
      } else {
        _blackTimeRemaining += _options.timeControl.incrementSeconds;
      }
    }

    setState(() {
      _selectedPosition = null;
      _legalMoves = [];

      if (_options.mode == GameMode.pvp && _options.passDevicePrivacyScreen && !_engine.isGameOver) {
        _showingPassDeviceScreen = true;
        _sessionState = SessionState.passDeviceScreen;
      } else {
        _sessionState = _engine.turn == PieceColor.white ? SessionState.playerTurn : SessionState.opponentTurn;
      }

      if (_options.autoFlipBoard && _options.mode == GameMode.pvp && !_showingPassDeviceScreen) {
        _isBoardFlipped = _engine.turn == PieceColor.black;
      }
    });

    if (_engine.isGameOver) {
      _timer?.cancel();
      _sessionState = SessionState.gameFinished;
      _showGameOverDialog();
    } else if (!_showingPassDeviceScreen) {
      _checkAITurn();
    }
  }

  Future<void> _checkAITurn() async {
    if (_engine.isGameOver) return;
    if (_options.mode != GameMode.vsAI) return;
    if (_engine.turn != _options.aiColor) return;

    setState(() {
      _isThinkingAI = true;
      _sessionState = SessionState.opponentTurn;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    final aiMove = await ChessAI.getBestMove(_engine, _options.aiDifficulty);

    if (mounted && aiMove != null) {
      setState(() {
        _isThinkingAI = false;
      });
      await _executeMove(aiMove.from, aiMove.to);
    } else if (mounted) {
      setState(() {
        _isThinkingAI = false;
      });
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(
        status: _engine.status,
        winner: _engine.winner,
        onNewGame: _resetGame,
        onReviewBoard: () {},
      ),
    );
  }

  void _undoMove() {
    if (_isThinkingAI) return;
    setState(() {
      _engine.undoMove();
      if (_options.mode == GameMode.vsAI && _engine.turn == _options.aiColor) {
        _engine.undoMove();
      }
      _selectedPosition = null;
      _legalMoves = [];
    });
  }

  Future<void> _showHint() async {
    if (_engine.isGameOver || _isThinkingAI) return;
    final hintMove = await ChessAI.getBestMove(_engine, ExtendedAIDifficulty.expert);
    if (hintMove != null && mounted) {
      setState(() {
        _selectedPosition = hintMove.from;
        _legalMoves = [hintMove.to];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nox Hint: Move ${hintMove.pieceMoved.type.name.toUpperCase()} to ${hintMove.to.algebraic}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topColor = _isBoardFlipped ? PieceColor.white : PieceColor.black;
    final bottomColor = _isBoardFlipped ? PieceColor.black : PieceColor.white;

    final topName = topColor == PieceColor.white ? _options.player1Name : _options.player2Name;
    final bottomName = bottomColor == PieceColor.white ? _options.player1Name : _options.player2Name;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              _options.category.name.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFD4E157)),
            ),
            const SizedBox(width: 8),
            Text(
              '(${_options.timeControl.displayLabel})',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline, color: Colors.amber),
            tooltip: 'Nox AI Hint',
            onPressed: _showHint,
          ),
          IconButton(
            icon: const Icon(Icons.screen_rotation),
            tooltip: 'Flip Board',
            onPressed: () => setState(() => _isBoardFlipped = !_isBoardFlipped),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              SettingsDialog.show(context, _options, (newOptions) {
                setState(() => _options = newOptions);
                _resetGame();
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;

                if (isWide) {
                  // Wide Screen Layout (Desktop, Browser, Tablet)
                  final sidebarWidth = min(320.0, constraints.maxWidth * 0.35);
                  final availableWidthForBoard = constraints.maxWidth - sidebarWidth - 40;
                  final availableHeightForBoard = constraints.maxHeight - 140;
                  final boardSize = min(availableWidthForBoard, availableHeightForBoard);

                  return Row(
                    children: [
                      // Left Area: Player HUDs & Centered Chess Board
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: boardSize,
                                child: Transform.rotate(
                                  angle: _options.faceToFaceTabletMode ? 3.14159 : 0.0,
                                  child: PlayerHeaderWidget(
                                    name: topName,
                                    color: topColor,
                                    isTurn: _engine.turn == topColor,
                                    capturedPieces: topColor == PieceColor.white ? _engine.capturedWhite : _engine.capturedBlack,
                                    materialAdvantage: topColor == PieceColor.white ? _engine.whiteAdvantage : _engine.blackAdvantage,
                                    secondsRemaining: !_options.timeControl.isCasual
                                        ? (topColor == PieceColor.white ? _whiteTimeRemaining : _blackTimeRemaining)
                                        : null,
                                    isThinkingAI: _isThinkingAI && _options.aiColor == topColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ChessBoardWidget(
                                engine: _engine,
                                options: _options,
                                selectedPosition: _selectedPosition,
                                legalMoves: _legalMoves,
                                isFlipped: _isBoardFlipped,
                                size: boardSize,
                                onSquareTapped: _onSquareTapped,
                                onPieceDropped: _executeMove,
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: boardSize,
                                child: PlayerHeaderWidget(
                                  name: bottomName,
                                  color: bottomColor,
                                  isTurn: _engine.turn == bottomColor,
                                  capturedPieces: bottomColor == PieceColor.white ? _engine.capturedWhite : _engine.capturedBlack,
                                  materialAdvantage: bottomColor == PieceColor.white ? _engine.whiteAdvantage : _engine.blackAdvantage,
                                  secondsRemaining: !_options.timeControl.isCasual
                                      ? (bottomColor == PieceColor.white ? _whiteTimeRemaining : _blackTimeRemaining)
                                      : null,
                                  isThinkingAI: _isThinkingAI && _options.aiColor == bottomColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Right Sidebar Container for Moves & Controls
                      Container(
                        width: sidebarWidth,
                        margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'MOVE HISTORY',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: Color(0xFFD4E157),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Latest Move Animated Toast Badge Box
                            if (_engine.lastMove != null) ...[
                              ChessComMoveBadge(
                                move: _engine.lastMove,
                                moveNumber: _engine.moveHistory.length,
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Move History Table List
                            Expanded(
                              child: MoveLogWidget(moveHistory: _engine.moveHistory),
                            ),
                            const SizedBox(height: 16),

                            // Game Action Toolbar
                            _buildControlToolbar(),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                // Narrow Screen Layout (Mobile Portrait)
                final maxBoardHeight = constraints.maxHeight - 240;
                final maxBoardWidth = constraints.maxWidth - 24;
                final boardSize = min(maxBoardWidth, maxBoardHeight);

                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      // Top Player HUD
                      Transform.rotate(
                        angle: _options.faceToFaceTabletMode ? 3.14159 : 0.0,
                        child: PlayerHeaderWidget(
                          name: topName,
                          color: topColor,
                          isTurn: _engine.turn == topColor,
                          capturedPieces: topColor == PieceColor.white ? _engine.capturedWhite : _engine.capturedBlack,
                          materialAdvantage: topColor == PieceColor.white ? _engine.whiteAdvantage : _engine.blackAdvantage,
                          secondsRemaining: !_options.timeControl.isCasual
                              ? (topColor == PieceColor.white ? _whiteTimeRemaining : _blackTimeRemaining)
                              : null,
                          isThinkingAI: _isThinkingAI && _options.aiColor == topColor,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Large Perfectly Scaled Chess Board
                      Center(
                        child: ChessBoardWidget(
                          engine: _engine,
                          options: _options,
                          selectedPosition: _selectedPosition,
                          legalMoves: _legalMoves,
                          isFlipped: _isBoardFlipped,
                          size: boardSize,
                          onSquareTapped: _onSquareTapped,
                          onPieceDropped: _executeMove,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Bottom Player HUD
                      PlayerHeaderWidget(
                        name: bottomName,
                        color: bottomColor,
                        isTurn: _engine.turn == bottomColor,
                        capturedPieces: bottomColor == PieceColor.white ? _engine.capturedWhite : _engine.capturedBlack,
                        materialAdvantage: bottomColor == PieceColor.white ? _engine.whiteAdvantage : _engine.blackAdvantage,
                        secondsRemaining: !_options.timeControl.isCasual
                            ? (bottomColor == PieceColor.white ? _whiteTimeRemaining : _blackTimeRemaining)
                            : null,
                        isThinkingAI: _isThinkingAI && _options.aiColor == bottomColor,
                      ),
                      const SizedBox(height: 8),

                      // Right-Side Style Moves Sidebar Container below board
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: MoveLogWidget(moveHistory: _engine.moveHistory),
                              ),
                              if (_engine.lastMove != null) ...[
                                const SizedBox(width: 8),
                                ChessComMoveBadge(
                                  move: _engine.lastMove,
                                  moveNumber: _engine.moveHistory.length,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Action Toolbar
                      _buildControlToolbar(),
                    ],
                  ),
                );
              },
            ),
          ),

          // Pass the Device Privacy Screen Overlay
          if (_showingPassDeviceScreen)
            PassDeviceWidget(
              nextPlayerColor: _engine.turn,
              nextPlayerName: _engine.turn == PieceColor.white ? _options.player1Name : _options.player2Name,
              onReadyPressed: () {
                setState(() {
                  _showingPassDeviceScreen = false;
                  if (_options.autoFlipBoard) {
                    _isBoardFlipped = _engine.turn == PieceColor.black;
                  }
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildControlToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.replay, color: Colors.white70),
            tooltip: 'Restart Game',
            onPressed: _resetGame,
          ),
          IconButton(
            icon: const Icon(Icons.undo, color: Colors.white70),
            tooltip: 'Undo Move',
            onPressed: _engine.moveHistory.isNotEmpty ? _undoMove : null,
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb_outline, color: Colors.amber),
            tooltip: 'Nox Hint',
            onPressed: _showHint,
          ),
          IconButton(
            icon: const Icon(Icons.flag_outlined, color: Colors.redAccent),
            tooltip: 'Resign',
            onPressed: _engine.moveHistory.isNotEmpty && !_engine.isGameOver
                ? () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Resign Game?'),
                        content: Text('${_engine.turn == PieceColor.white ? "White" : "Black"} resigns.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showGameOverDialog();
                            },
                            child: const Text('Resign'),
                          ),
                        ],
                      ),
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
