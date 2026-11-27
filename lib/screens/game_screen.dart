import 'package:material_ui/material_ui.dart';

import '../data/sample_puzzles.dart';
import '../game/crossword_engine.dart';
import '../game/puzzle_validator.dart';
import '../models/crossword.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/app_routes.dart';
import '../widgets/clue_panel.dart';
import '../widgets/crossword_grid.dart';
import '../widgets/game_keyboard.dart';

enum _Tool {
  checkWord,
  checkPuzzle,
  revealLetter,
  revealWord,
  clearWord,
  restart,
  changeTopic,
  changeDifficulty,
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final CrosswordPuzzle _puzzle;
  late final ValidationResult _validation;
  late final CrosswordEngine _engine;
  bool _celebrated = false;

  @override
  void initState() {
    super.initState();
    // Phase 8 will choose a real puzzle for the selected topic/difficulty.
    _puzzle = SamplePuzzles.assamStarter;
    _validation = PuzzleValidator.validate(_puzzle);
    _engine = CrosswordEngine(_puzzle);
    _engine.addListener(_onEngineChanged);
  }

  @override
  void dispose() {
    _engine.removeListener(_onEngineChanged);
    _engine.dispose();
    super.dispose();
  }

  void _onEngineChanged() {
    if (!_engine.isComplete) {
      _celebrated = false;
      return;
    }
    if (!_celebrated) {
      _celebrated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showComplete();
        }
      });
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _showComplete() async {
    final bool? playAgain = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.emoji_events_rounded,
          color: AppColors.gold,
          size: 48,
        ),
        title: const Text('Puzzle complete!'),
        content: Text(
          'Well done! You solved "${_puzzle.title}".\n\n'
          'Mistakes found by checks: ${_engine.incorrectAttempts}\n'
          'Letters revealed: ${_engine.lettersRevealed}\n'
          'Words revealed: ${_engine.wordsRevealed}\n\n'
          'Timer, points and achievements are added in the next phases.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Back to Dashboard'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
    if (!mounted) {
      return;
    }
    if (playAgain == true) {
      _engine.restart();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _confirmRestart() async {
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restart puzzle?'),
        content: const Text('All letters you have entered will be cleared.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Restart'),
          ),
        ],
      ),
    );
    if (yes == true) {
      _engine.restart();
    }
  }

  void _onTool(_Tool tool) {
    switch (tool) {
      case _Tool.checkWord:
        final int wrong = _engine.checkWord();
        _toast(wrong == 0
            ? 'No mistakes in this word so far.'
            : '$wrong wrong letter(s) marked in red.');
      case _Tool.checkPuzzle:
        final int wrong = _engine.checkPuzzle();
        _toast(wrong == 0
            ? 'No mistakes in the puzzle so far.'
            : '$wrong wrong letter(s) marked in red.');
      case _Tool.revealLetter:
        _engine.revealLetter();
      case _Tool.revealWord:
        _engine.revealWord();
      case _Tool.clearWord:
        _engine.clearWord();
      case _Tool.restart:
        _confirmRestart();
      case _Tool.changeTopic:
        Navigator.of(context).pushNamed(AppRoutes.category);
      case _Tool.changeDifficulty:
        Navigator.of(context).pushNamed(AppRoutes.difficulty);
    }
  }

  void _showClueSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => ListenableBuilder(
        listenable: _engine,
        builder: (context, _) => SizedBox(
          height: 420,
          child: ClueList(
            engine: _engine,
            onClueTap: () => Navigator.of(sheetContext).pop(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppState.instance;
    final String topicName = state.topic?.name ?? 'Any topic';
    final String subtitle =
        'Practice puzzle · $topicName · ${state.difficulty.label}';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_puzzle.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Reveal a letter',
            icon: const Icon(Icons.lightbulb_outline_rounded),
            onPressed: () => _onTool(_Tool.revealLetter),
          ),
          PopupMenuButton<_Tool>(
            tooltip: 'More options',
            onSelected: _onTool,
            itemBuilder: (_) => const [
              PopupMenuItem(value: _Tool.checkWord, child: Text('Check word')),
              PopupMenuItem(
                value: _Tool.checkPuzzle,
                child: Text('Check puzzle'),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: _Tool.revealLetter,
                child: Text('Reveal letter'),
              ),
              PopupMenuItem(
                value: _Tool.revealWord,
                child: Text('Reveal word'),
              ),
              PopupMenuDivider(),
              PopupMenuItem(value: _Tool.clearWord, child: Text('Clear word')),
              PopupMenuItem(
                value: _Tool.restart,
                child: Text('Restart puzzle'),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: _Tool.changeTopic,
                child: Text('Change topic'),
              ),
              PopupMenuItem(
                value: _Tool.changeDifficulty,
                child: Text('Change difficulty'),
              ),
            ],
          ),
        ],
      ),
      body: !_validation.isValid
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'This puzzle has a problem and cannot be played:\n\n'
                  '${_validation.errors.join('\n')}',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListenableBuilder(
              listenable: _engine,
              builder: (context, _) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final bool wide = constraints.maxWidth >= 900;
                    final Widget board = Column(
                      children: [
                        ActiveClueBar(engine: _engine),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: CrosswordGrid(engine: _engine),
                          ),
                        ),
                        _ProgressRow(
                          engine: _engine,
                          onShowClues: wide ? null : _showClueSheet,
                        ),
                        GameKeyboard(
                          onLetter: _engine.enterLetter,
                          onBackspace: _engine.backspace,
                        ),
                      ],
                    );
                    if (!wide) {
                      return SafeArea(top: false, child: board);
                    }
                    return SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(child: board),
                          const VerticalDivider(width: 1),
                          SizedBox(
                            width: 340,
                            child: ClueList(engine: _engine),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final CrosswordEngine engine;
  final VoidCallback? onShowClues;

  const _ProgressRow({required this.engine, this.onShowClues});

  @override
  Widget build(BuildContext context) {
    final VoidCallback? showClues = onShowClues;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: engine.completion,
                minHeight: 8,
                backgroundColor: Colors.black12,
                color: AppColors.gold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${(engine.completion * 100).round()}%',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (showClues != null)
            TextButton.icon(
              onPressed: showClues,
              icon: const Icon(Icons.list_alt_rounded),
              label: const Text('All clues'),
            ),
        ],
      ),
    );
  }
}
