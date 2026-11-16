import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final int secondsRemaining;
  final bool isActive;
  final bool isLowTime;

  const TimerWidget({
    super.key,
    required this.secondsRemaining,
    required this.isActive,
    required this.isLowTime,
  });

  String _formatTime(int totalSecs) {
    final minutes = totalSecs ~/ 60;
    final seconds = totalSecs % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color bgColor;
    Color textColor;

    if (isActive) {
      if (isLowTime) {
        bgColor = Colors.red.shade700;
        textColor = Colors.white;
      } else {
        bgColor = theme.colorScheme.primaryContainer;
        textColor = theme.colorScheme.onPrimaryContainer;
      }
    } else {
      bgColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
      textColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: (isLowTime ? Colors.red : theme.colorScheme.primary)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            _formatTime(secondsRemaining),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
