import 'package:flutter/material.dart';
import '../../models/game_options.dart';
import '../../models/piece.dart';
import '../../models/time_control.dart';
import 'game_screen.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  GameCategory _selectedCategory = GameCategory.rapid;
  TimeControl _selectedTimeControl = TimeControl.rapid10;
  GameMode _selectedMode = GameMode.vsAI;
  ExtendedAIDifficulty _aiDifficulty = ExtendedAIDifficulty.intermediate;
  PieceColor _playerColor = PieceColor.white;
  String _player1Name = 'Player 1';
  String _player2Name = 'Player 2';
  bool _autoRotateBoard = true;
  bool _faceToFaceMode = false;
  bool _passDeviceScreen = false;
  String? _customFen;

  List<TimeControl> get _currentPresets {
    switch (_selectedCategory) {
      case GameCategory.rapid:
        return [TimeControl.rapid10, TimeControl.rapid10_5, TimeControl.rapid15_10];
      case GameCategory.blitz:
        return [TimeControl.blitz3, TimeControl.blitz3_2, TimeControl.blitz5, TimeControl.blitz5_3];
      case GameCategory.bullet:
        return [TimeControl.bullet1, TimeControl.bullet1_1, TimeControl.bullet2_1];
      case GameCategory.classical:
        return [TimeControl.classical30, TimeControl.classical30_20, TimeControl.classical60];
      case GameCategory.offline:
        return [TimeControl.casual, TimeControl.rapid10, TimeControl.blitz5, TimeControl.bullet1];
      case GameCategory.aiPractice:
        return [TimeControl.rapid10, TimeControl.blitz5, TimeControl.casual];
      case GameCategory.custom:
        return [TimeControl.rapid10, TimeControl.blitz3, TimeControl.casual];
    }
  }

  void _startGame() {
    final options = GameOptions(
      mode: (_selectedCategory == GameCategory.offline) ? GameMode.pvp : _selectedMode,
      category: _selectedCategory,
      timeControl: _selectedTimeControl,
      aiDifficulty: _aiDifficulty,
      aiColor: _playerColor.opposite,
      player1Name: _player1Name,
      player2Name: _player2Name,
      autoFlipBoard: _autoRotateBoard,
      faceToFaceTabletMode: _faceToFaceMode,
      passDevicePrivacyScreen: _passDeviceScreen,
      initialFen: _customFen,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(options: options),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Game Modes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Block - Nocturne Visual System
              const Text(
                'CHOOSE YOUR RHYTHM',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Color(0xFFD4E157), // Acid-lime
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'How do you want to think?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Every clock changes the character of the game.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 24),

              // Step 1: Mode Cards Selection
              _buildSectionTitle('1. Select Mode'),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildModeCard(
                      category: GameCategory.rapid,
                      name: 'Rapid',
                      duration: '10 - 15 min',
                      explanation: 'Thoughtful tactical play with enough time to calculate deep combinations.',
                      accentColor: const Color(0xFFD4E157), // Acid Lime
                      icon: Icons.timer,
                    ),
                    _buildModeCard(
                      category: GameCategory.blitz,
                      name: 'Blitz',
                      duration: '3 - 5 min',
                      explanation: 'Fast-paced intuition and sharp reflexes under time pressure.',
                      accentColor: const Color(0xFFFF6F61), // Coral Accent
                      icon: Icons.flash_on,
                    ),
                    _buildModeCard(
                      category: GameCategory.bullet,
                      name: 'Bullet',
                      duration: '1 - 2 min',
                      explanation: 'Hyper-fast speed chess. Instant calculations and premoves.',
                      accentColor: const Color(0xFFE53935), // Warm Red Accent
                      icon: Icons.electric_bolt,
                    ),
                    _buildModeCard(
                      category: GameCategory.classical,
                      name: 'Classical',
                      duration: '30 - 60 min',
                      explanation: 'Deep strategic mastery with analysis and move notes.',
                      accentColor: const Color(0xFFF5F5F0), // Muted Ivory Accent
                      icon: Icons.hourglass_full,
                    ),
                    _buildModeCard(
                      category: GameCategory.offline,
                      name: 'Play on this Device',
                      duration: 'Flexible',
                      explanation: 'Offline 2-player pass-and-play with auto-board rotation.',
                      accentColor: const Color(0xFF4CAF50), // Forest Green Accent
                      icon: Icons.people_alt,
                    ),
                    _buildModeCard(
                      category: GameCategory.aiPractice,
                      name: 'Practice with Nox',
                      duration: 'Self-paced',
                      explanation: 'Adaptive AI engine with mistakes, explanations & hints.',
                      accentColor: const Color(0xFF81B64C), // Nox Acid Lime
                      icon: Icons.smart_toy_sharp,
                    ),
                    _buildModeCard(
                      category: GameCategory.custom,
                      name: 'Custom Game',
                      duration: 'Custom',
                      explanation: 'Set up custom time controls, initial FEN, colors, and options.',
                      accentColor: const Color(0xFF38BDF8),
                      icon: Icons.tune,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Step 2: Time Control Preset
              _buildSectionTitle('2. Time Control Preset'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _currentPresets.map((tc) {
                  final isSelected = _selectedTimeControl.name == tc.name;
                  return ChoiceChip(
                    label: Text(tc.name),
                    selected: isSelected,
                    selectedColor: const Color(0xFFD4E157),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                    backgroundColor: const Color(0xFF1E293B),
                    onSelected: (sel) {
                      if (sel) {
                        setState(() {
                          _selectedTimeControl = tc;
                        });
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // Step 3: Match Configurations
              _buildSectionTitle('3. Configure Options'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    if (_selectedCategory == GameCategory.aiPractice || _selectedMode == GameMode.vsAI) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('AI Level:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          DropdownButton<ExtendedAIDifficulty>(
                            dropdownColor: const Color(0xFF1E293B),
                            value: _aiDifficulty,
                            items: ExtendedAIDifficulty.values.map((d) {
                              return DropdownMenuItem(
                                value: d,
                                child: Text(d.label, style: const TextStyle(color: Colors.white)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _aiDifficulty = val);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Play Color:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          SegmentedButton<PieceColor>(
                            segments: const [
                              ButtonSegment(value: PieceColor.white, label: Text('White')),
                              ButtonSegment(value: PieceColor.black, label: Text('Black')),
                            ],
                            selected: {_playerColor},
                            onSelectionChanged: (set) {
                              setState(() => _playerColor = set.first);
                            },
                          ),
                        ],
                      ),
                    ],

                    if (_selectedCategory == GameCategory.offline) ...[
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Player 1 (White) Name',
                          labelStyle: TextStyle(color: Colors.grey),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (val) => _player1Name = val.isEmpty ? 'White Player' : val,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Player 2 (Black) Name',
                          labelStyle: TextStyle(color: Colors.grey),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (val) => _player2Name = val.isEmpty ? 'Black Player' : val,
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Auto-Rotate Board per Move', style: TextStyle(color: Colors.white)),
                        subtitle: const Text('Smoothly rotates board 180° after each turn', style: TextStyle(color: Colors.grey)),
                        value: _autoRotateBoard,
                        onChanged: (val) => setState(() => _autoRotateBoard = val),
                      ),
                      SwitchListTile(
                        title: const Text('Face-to-Face Tablet HUD', style: TextStyle(color: Colors.white)),
                        subtitle: const Text('Rotates top player HUD 180° for tablet sitting opposite', style: TextStyle(color: Colors.grey)),
                        value: _faceToFaceMode,
                        onChanged: (val) => setState(() => _faceToFaceMode = val),
                      ),
                      SwitchListTile(
                        title: const Text('Pass-Device Privacy Overlay', style: TextStyle(color: Colors.white)),
                        subtitle: const Text('Show "Pass phone to opponent" barrier between turns', style: TextStyle(color: Colors.grey)),
                        value: _passDeviceScreen,
                        onChanged: (val) => setState(() => _passDeviceScreen = val),
                      ),
                    ],

                    if (_selectedCategory == GameCategory.custom) ...[
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Initial FEN (Optional)',
                          hintText: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
                          hintStyle: TextStyle(color: Colors.grey),
                          labelStyle: TextStyle(color: Colors.grey),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (val) => _customFen = val.trim().isEmpty ? null : val.trim(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Start Game Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _startGame,
                  icon: const Icon(Icons.play_arrow, size: 28, color: Colors.black),
                  label: Text(
                    'Start ${_selectedCategory.name.toUpperCase()} Match',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4E157),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildModeCard({
    required GameCategory category,
    required String name,
    required String duration,
    required String explanation,
    required Color accentColor,
    required IconData icon,
  }) {
    final isSelected = _selectedCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
          _selectedTimeControl = _currentPresets.first;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 220,
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.18) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentColor : Colors.white12,
            width: isSelected ? 2.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: accentColor.withOpacity(0.2),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: accentColor, size: 22),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? accentColor : Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              duration,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              explanation,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
