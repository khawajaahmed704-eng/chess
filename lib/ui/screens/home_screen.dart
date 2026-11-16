import 'package:flutter/material.dart';
import '../../models/game_options.dart';
import '../../models/time_control.dart';
import 'game_screen.dart';
import 'mode_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _startQuickPlay(BuildContext context) {
    // Quick Play defaults to 10 min Rapid vs Adaptive AI
    const options = GameOptions(
      mode: GameMode.vsAI,
      category: GameCategory.rapid,
      timeControl: TimeControl.rapid10,
      aiDifficulty: ExtendedAIDifficulty.adaptive,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const GameScreen(options: options),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Brand Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.sports_esports, color: Color(0xFFD4E157), size: 28),
                      SizedBox(width: 10),
                      Text(
                        'NOCTURNE CHESS',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune, color: Colors.white70),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ModeSelectionScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Hero Banner - Primary Action: Quick Play
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFD4E157).withOpacity(0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4E157).withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4E157).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'RECOMMENDED',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4E157),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Quick Play',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Rapid 10 min vs Adaptive Nox AI',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _startQuickPlay(context),
                        icon: const Icon(Icons.play_arrow_rounded, size: 28, color: Colors.black),
                        label: const Text(
                          'Play Now',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4E157),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              const Text(
                'GAME MODES',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 14),

              // Game Mode Quick Cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.35,
                children: [
                  _buildQuickCard(
                    context,
                    title: 'Choose Mode',
                    subtitle: 'Rapid, Blitz, Bullet, Classical',
                    icon: Icons.dashboard_outlined,
                    accentColor: const Color(0xFFD4E157),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ModeSelectionScreen()),
                      );
                    },
                  ),
                  _buildQuickCard(
                    context,
                    title: 'Play Offline',
                    subtitle: '2 Players on this device',
                    icon: Icons.people_outline,
                    accentColor: const Color(0xFF4CAF50),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const GameScreen(
                            options: GameOptions(
                              mode: GameMode.pvp,
                              category: GameCategory.offline,
                              timeControl: TimeControl.casual,
                              autoFlipBoard: true,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildQuickCard(
                    context,
                    title: 'Practice Nox AI',
                    subtitle: '6 difficulty levels',
                    icon: Icons.smart_toy_outlined,
                    accentColor: const Color(0xFF81B64C),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ModeSelectionScreen()),
                      );
                    },
                  ),
                  _buildQuickCard(
                    context,
                    title: 'Custom Match',
                    subtitle: 'FEN setup & Custom timers',
                    icon: Icons.tune,
                    accentColor: const Color(0xFF38BDF8),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ModeSelectionScreen()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: accentColor.withOpacity(0.18),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
