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

    return GestureDetector(
      // Swipe left for the next clue, right for the previous one.
      onHorizontalDragEnd: (DragEndDetails details) {
        final double speed = details.primaryVelocity ?? 0;
        if (speed < -200) {
          engine.nextWord();
        } else if (speed > 200) {
          engine.previousWord();
        }
      },
      child: Material(
      color: AppColors.brand,
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
            style: TextStyle(
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


/// Across / Down clue tabs, shown under the grid on tall screens
/// (tablets held upright). Follows the active clue automatically.
class ClueTabs extends StatefulWidget {
  final CrosswordEngine engine;

  const ClueTabs({super.key, required this.engine});

  @override
  State<ClueTabs> createState() => _ClueTabsState();
}

class _ClueTabsState extends State<ClueTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  final GlobalKey _activeKey = GlobalKey();
  CrosswordWord? _shown;

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  /// Switches to the right tab and scrolls the active clue into view.
  void _follow(CrosswordWord? active) {
    if (active == null || identical(active, _shown)) {
      return;
    }
    _shown = active;
    final int tab = active.direction == ClueDirection.across ? 0 : 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (_tabs.index != tab) {
        _tabs.animateTo(tab);
      }
      final BuildContext? target = _activeKey.currentContext;
      if (target != null && target.mounted) {
        Scrollable.ensureVisible(
          target,
          alignment: 0.3,
          duration: const Duration(milliseconds: 250),
        );
      }
    });
  }

  Widget _list(List<CrosswordWord> words, CrosswordWord? active) {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (final CrosswordWord word in words)
            ListTile(
              key: identical(word, active) ? _activeKey : null,
              dense: true,
              selected: identical(word, active),
              selectedColor: AppColors.forestGreen,
              selectedTileColor: AppColors.gold.withValues(alpha: 0.2),
              leading: Text(
                '${widget.engine.numberOf(word)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              title: Text(word.clue),
              subtitle: Text('${word.length} letters'),
              trailing: widget.engine.isWordSolved(word)
                  ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                  : null,
              onTap: () => widget.engine.selectWord(word),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CrosswordWord? active = widget.engine.activeWord;
    _follow(active);

    return Material(
      color: AppColors.surface,
      child: Column(
        children: [
          TabBar(
            controller: _tabs,
            labelColor: AppColors.forestGreen,
            indicatorColor: AppColors.gold,
            tabs: [
              Tab(text: 'Across (${widget.engine.acrossWords.length})'),
              Tab(text: 'Down (${widget.engine.downWords.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _list(widget.engine.acrossWords, active),
                _list(widget.engine.downWords, active),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
