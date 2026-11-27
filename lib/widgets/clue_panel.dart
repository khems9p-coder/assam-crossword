import 'package:material_ui/material_ui.dart';

import '../game/crossword_engine.dart';
import '../models/crossword.dart';
import '../theme/app_theme.dart';

/// The green bar above the grid showing the current clue.
class ActiveClueBar extends StatelessWidget {
  final CrosswordEngine engine;

  const ActiveClueBar({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    final CrosswordWord? word = engine.activeWord;

    return Material(
      color: AppColors.forestGreen,
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous clue',
            color: Colors.white,
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: engine.previousWord,
          ),
          Expanded(
            child: InkWell(
              onTap: engine.toggleDirection,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      word == null
                          ? ''
                          : '${engine.numberOf(word)} ${word.direction.label}'
                              ' · ${word.length} letters',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                    Text(
                      word?.clue ?? 'Tap a square to begin',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Next clue',
            color: Colors.white,
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: engine.nextWord,
          ),
        ],
      ),
    );
  }
}

/// The full list of Across and Down clues.
class ClueList extends StatelessWidget {
  final CrosswordEngine engine;
  final VoidCallback? onClueTap;

  const ClueList({super.key, required this.engine, this.onClueTap});

  @override
  Widget build(BuildContext context) {
    final CrosswordWord? active = engine.activeWord;

    Widget header(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.forestGreen,
            ),
          ),
        );

    Widget tile(CrosswordWord word) => ListTile(
          dense: true,
          selected: identical(word, active),
          selectedColor: AppColors.forestGreen,
          selectedTileColor: AppColors.gold.withValues(alpha: 0.2),
          leading: Text(
            '${engine.numberOf(word)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          title: Text(word.clue),
          subtitle: Text('${word.length} letters'),
          trailing: engine.isWordSolved(word)
              ? const Icon(Icons.check_circle_rounded, color: Colors.green)
              : null,
          onTap: () {
            engine.selectWord(word);
            onClueTap?.call();
          },
        );

    return ListView(
      children: [
        header('Across'),
        for (final CrosswordWord word in engine.acrossWords) tile(word),
        header('Down'),
        for (final CrosswordWord word in engine.downWords) tile(word),
        const SizedBox(height: 16),
      ],
    );
  }
}
