import 'piece.dart';
import 'time_control.dart';

enum GameMode { pvp, vsAI }

enum ExtendedAIDifficulty {
  beginner('Beginner', 0),
  casual('Casual', 1),
  intermediate('Intermediate', 2),
  advanced('Advanced', 3),
  expert('Expert', 4),
  adaptive('Adaptive', 2);

  final String label;
  final int levelDepth;
  const ExtendedAIDifficulty(this.label, this.levelDepth);
}

enum BoardThemeOption {
  wood('Classic Wood', 0xFFE0C097, 0xFF8B5A2B, 0xFFD4AC0D),
  slate('Slate Modern', 0xFFE2E8F0, 0xFF475569, 0xFF38BDF8),
  emerald('Forest Emerald', 0xFFEAE6DF, 0xFF466D5B, 0xFF81C784),
  ocean('Deep Ocean', 0xFFD0E1F9, 0xFF4D648D, 0xFF28965A),
  cyberpunk('Neon Cyber', 0xFF2A2D3E, 0xFF181A24, 0xFF00E5FF);

  final String label;
  final int lightSquareColor;
  final int darkSquareColor;
  final int accentColor;

  const BoardThemeOption(this.label, this.lightSquareColor, this.darkSquareColor, this.accentColor);
}

class GameOptions {
  final GameMode mode;
  final GameCategory category;
  final TimeControl timeControl;
  final ExtendedAIDifficulty aiDifficulty;
  final PieceColor aiColor;
  final BoardThemeOption boardTheme;
  final String player1Name;
  final String player2Name;
  final bool autoFlipBoard;
  final bool faceToFaceTabletMode;
  final bool passDevicePrivacyScreen;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool showLegalMoves;
  final bool moveConfirmation;
  final bool premoveEnabled;
  final String? initialFen;

  const GameOptions({
    this.mode = GameMode.vsAI,
    this.category = GameCategory.rapid,
    this.timeControl = TimeControl.rapid10,
    this.aiDifficulty = ExtendedAIDifficulty.intermediate,
    this.aiColor = PieceColor.black,
    this.boardTheme = BoardThemeOption.wood,
    this.player1Name = 'White Player',
    this.player2Name = 'Black Player',
    this.autoFlipBoard = false,
    this.faceToFaceTabletMode = false,
    this.passDevicePrivacyScreen = false,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.showLegalMoves = true,
    this.moveConfirmation = false,
    this.premoveEnabled = true,
    this.initialFen,
  });

  GameOptions copyWith({
    GameMode? mode,
    GameCategory? category,
    TimeControl? timeControl,
    ExtendedAIDifficulty? aiDifficulty,
    PieceColor? aiColor,
    BoardThemeOption? boardTheme,
    String? player1Name,
    String? player2Name,
    bool? autoFlipBoard,
    bool? faceToFaceTabletMode,
    bool? passDevicePrivacyScreen,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? showLegalMoves,
    bool? moveConfirmation,
    bool? premoveEnabled,
    String? initialFen,
  }) {
    return GameOptions(
      mode: mode ?? this.mode,
      category: category ?? this.category,
      timeControl: timeControl ?? this.timeControl,
      aiDifficulty: aiDifficulty ?? this.aiDifficulty,
      aiColor: aiColor ?? this.aiColor,
      boardTheme: boardTheme ?? this.boardTheme,
      player1Name: player1Name ?? this.player1Name,
      player2Name: player2Name ?? this.player2Name,
      autoFlipBoard: autoFlipBoard ?? this.autoFlipBoard,
      faceToFaceTabletMode: faceToFaceTabletMode ?? this.faceToFaceTabletMode,
      passDevicePrivacyScreen: passDevicePrivacyScreen ?? this.passDevicePrivacyScreen,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      showLegalMoves: showLegalMoves ?? this.showLegalMoves,
      moveConfirmation: moveConfirmation ?? this.moveConfirmation,
      premoveEnabled: premoveEnabled ?? this.premoveEnabled,
      initialFen: initialFen ?? this.initialFen,
    );
  }
}
