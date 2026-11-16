import 'package:flutter/material.dart';
import '../../models/move.dart';

class MoveLogWidget extends StatelessWidget {
  final List<ChessMove> moveHistory;

  const MoveLogWidget({
    super.key,
    required this.moveHistory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Pair moves by turn number
    final List<Map<String, String>> movePairs = [];
    for (int i = 0; i < moveHistory.length; i += 2) {
      final whiteMove = moveHistory[i].san;
      final blackMove = (i + 1 < moveHistory.length) ? moveHistory[i + 1].san : '';
      movePairs.add({'white': whiteMove, 'black': blackMove});
    }

    final ScrollController scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });

    return Container(
      height: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: movePairs.isEmpty
          ? Center(
              child: Text(
                'Moves will appear here',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.hintColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          : ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: movePairs.length,
              itemBuilder: (context, index) {
                final moveNumber = index + 1;
                final pair = movePairs[index];
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: index == movePairs.length - 1
                        ? theme.colorScheme.primaryContainer.withOpacity(0.5)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$moveNumber.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        pair['white']!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (pair['black']!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          pair['black']!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
