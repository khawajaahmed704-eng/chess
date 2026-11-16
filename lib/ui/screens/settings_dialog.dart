import 'package:flutter/material.dart';
import '../../models/game_options.dart';
import '../../models/piece.dart';
import '../../models/time_control.dart';

class SettingsDialog extends StatefulWidget {
  final GameOptions currentOptions;
  final ValueChanged<GameOptions> onOptionsChanged;

  const SettingsDialog({
    super.key,
    required this.currentOptions,
    required this.onOptionsChanged,
  });

  static Future<void> show(
    BuildContext context,
    GameOptions options,
    ValueChanged<GameOptions> onChanged,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SettingsDialog(
        currentOptions: options,
        onOptionsChanged: onChanged,
      ),
    );
  }

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late GameOptions _options;

  @override
  void initState() {
    super.initState();
    _options = widget.currentOptions;
  }

  void _updateOptions(GameOptions newOptions) {
    setState(() {
      _options = newOptions;
    });
    widget.onOptionsChanged(_options);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Game Settings',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildSectionHeader('Game Mode'),
                    SegmentedButton<GameMode>(
                      segments: const [
                        ButtonSegment(
                          value: GameMode.vsAI,
                          label: Text('vs Computer'),
                          icon: Icon(Icons.computer),
                        ),
                        ButtonSegment(
                          value: GameMode.pvp,
                          label: Text('Pass & Play'),
                          icon: Icon(Icons.people),
                        ),
                      ],
                      selected: {_options.mode},
                      onSelectionChanged: (set) {
                        _updateOptions(_options.copyWith(mode: set.first));
                      },
                    ),

                    if (_options.mode == GameMode.vsAI) ...[
                      const SizedBox(height: 16),
                      _buildSectionHeader('AI Difficulty'),
                      DropdownButtonFormField<ExtendedAIDifficulty>(
                        value: _options.aiDifficulty,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        items: ExtendedAIDifficulty.values.map((d) {
                          return DropdownMenuItem(
                            value: d,
                            child: Text(d.label),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            _updateOptions(_options.copyWith(aiDifficulty: val));
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Play As:'),
                          SegmentedButton<PieceColor>(
                            segments: const [
                              ButtonSegment(value: PieceColor.white, label: Text('White')),
                              ButtonSegment(value: PieceColor.black, label: Text('Black')),
                            ],
                            selected: {_options.aiColor == PieceColor.white ? PieceColor.black : PieceColor.white},
                            onSelectionChanged: (set) {
                              final playerColor = set.first;
                              _updateOptions(_options.copyWith(aiColor: playerColor.opposite));
                            },
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 20),
                    _buildSectionHeader('Clock Timer'),
                    DropdownButtonFormField<TimeControl>(
                      value: _options.timeControl,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      items: [
                        TimeControl.rapid10,
                        TimeControl.rapid10_5,
                        TimeControl.rapid15_10,
                        TimeControl.blitz3,
                        TimeControl.blitz5,
                        TimeControl.bullet1,
                        TimeControl.classical30,
                        TimeControl.casual,
                      ].map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(t.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          _updateOptions(_options.copyWith(timeControl: val));
                        }
                      },
                    ),

                    const SizedBox(height: 20),
                    _buildSectionHeader('Board Theme'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: BoardThemeOption.values.map((t) {
                        final isSelected = _options.boardTheme == t;
                        return ChoiceChip(
                          label: Text(t.label),
                          selected: isSelected,
                          avatar: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Color(t.darkSquareColor),
                              shape: BoxShape.circle,
                              border: Border.all(color: Color(t.lightSquareColor), width: 2),
                            ),
                          ),
                          onSelected: (sel) {
                            if (sel) {
                              _updateOptions(_options.copyWith(boardTheme: t));
                            }
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),
                    _buildSectionHeader('Preferences'),
                    SwitchListTile(
                      title: const Text('Show Legal Moves'),
                      subtitle: const Text('Highlight valid destination dots on board'),
                      value: _options.showLegalMoves,
                      onChanged: (val) => _updateOptions(_options.copyWith(showLegalMoves: val)),
                    ),
                    SwitchListTile(
                      title: const Text('Auto-Flip Board'),
                      subtitle: const Text('Automatically rotate board on turn switch'),
                      value: _options.autoFlipBoard,
                      onChanged: (val) => _updateOptions(_options.copyWith(autoFlipBoard: val)),
                    ),
                    SwitchListTile(
                      title: const Text('Face-to-Face Tablet HUD'),
                      subtitle: const Text('Rotate top HUD 180° for two players sitting opposite'),
                      value: _options.faceToFaceTabletMode,
                      onChanged: (val) => _updateOptions(_options.copyWith(faceToFaceTabletMode: val)),
                    ),
                    SwitchListTile(
                      title: const Text('Pass-Device Privacy Screen'),
                      subtitle: const Text('Show privacy overlay between turns in offline mode'),
                      value: _options.passDevicePrivacyScreen,
                      onChanged: (val) => _updateOptions(_options.copyWith(passDevicePrivacyScreen: val)),
                    ),
                    SwitchListTile(
                      title: const Text('Sound Effects'),
                      subtitle: const Text('Play sound on moves and captures'),
                      value: _options.soundEnabled,
                      onChanged: (val) => _updateOptions(_options.copyWith(soundEnabled: val)),
                    ),
                    SwitchListTile(
                      title: const Text('Haptic Feedback'),
                      subtitle: const Text('Vibrate subtly on piece drops and captures'),
                      value: _options.hapticsEnabled,
                      onChanged: (val) => _updateOptions(_options.copyWith(hapticsEnabled: val)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}
