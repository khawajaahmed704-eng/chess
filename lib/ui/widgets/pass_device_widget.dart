import 'package:flutter/material.dart';
import '../../models/piece.dart';

class PassDeviceWidget extends StatelessWidget {
  final PieceColor nextPlayerColor;
  final String nextPlayerName;
  final VoidCallback onReadyPressed;

  const PassDeviceWidget({
    super.key,
    required this.nextPlayerColor,
    required this.nextPlayerName,
    required this.onReadyPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isWhite = nextPlayerColor == PieceColor.white;

    return Container(
      color: Colors.black.withOpacity(0.92),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: isWhite ? Colors.white : Colors.grey.shade900,
                child: Icon(
                  Icons.phone_android,
                  size: 40,
                  color: isWhite ? Colors.black : Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pass the Device',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hand the device to $nextPlayerName (${isWhite ? "White" : "Black"})',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onReadyPressed,
                icon: const Icon(Icons.play_arrow_rounded, size: 28),
                label: const Text(
                  "I'm Ready to Play",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
