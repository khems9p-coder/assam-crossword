import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../data/question_bank.dart';
import '../game/crossword_engine.dart';
import '../game/puzzle_validator.dart';
import '../models/crossword.dart';
import '../models/difficulty.dart';
import '../services/app_state.dart';
import '../services/daily_service.dart';
import '../services/puzzle_service.dart';
import '../services/score_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_routes.dart';
import '../utils/helpers.dart';
import '../widgets/celebration_dialog.dart';
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
  /// True for the Daily Challenge, false for normal puzzles.
  final bool daily;

  const GameScreen({super.key, this.daily = false});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with WidgetsBindingObserver {
  late final String? _topicId;
  late final Difficulty _difficulty;
  late final DateTime _day;
  int _number = 1;
  bool _loading = true;
  bool _needsTopic = false;
  String? _message;
  CrosswordPuzzle? _puzzle;
  ValidationResult? _validation;
  CrosswordEngine? _engine;
  bool _celebrated = false;

  /// Set once the puzzle is finished, so the results can be shown again.
  GameResult? _result;

  /// True while the player looks over the solved grid after finishing.
  bool _reviewing = false;
  Timer? _clock;
  int _seconds = 0;
  bool _inBackground = false;
  int _lastSolved = 0;
  int _combo = 0;
  DateTime? _lastSolveTime;

  @override
  void initState() {
    super.initState();
    _day = DailyService.today();
    if (widget.daily) {
      _topicId = DailyService.topicFor(_day).id;
      _difficulty = DailyService.difficulty;
    } else {
      _topicId = AppState.instance.topicId;
      _difficulty = AppState.instance.difficulty;
    }
    WidgetsBinding.instance.addObserver(this);
    _prepare();
  }

  Future<void> _prepare() async {
    if (QuestionBank.instance.isLoaded) {
      _setUpPuzzle();
      return;
    }
    await QuestionBank.instance.load();
    if (!mounted) {
      return;
    }
    setState(_setUpPuzzle);
  }

  void _setUpPuzzle() {
    final String? topicId = _topicId;
    _loading = false;
    if (topicId == null) {
      _needsTopic = true;
      _message = 'Choose a topic to start a crossword.';
      return;
    }
    _number =
        widget.daily ? 0 : PuzzleService.currentNumber(topicId, _difficulty);
    final CrosswordPuzzle? puzzle = widget.daily
        ? DailyService.build(_day)
        : PuzzleService.build(topicId, _difficulty, _number);
    if (puzzle == null) {
      _needsTopic = true;
      _message = 'There are not enough questions for this topic yet. '
          'Please choose another topic.';
      return;
    }
    _puzzle = puzzle;
    _validation = PuzzleValidator.validate(puzzle);
    _engine = CrosswordEngine(
      puzzle,
      givenShare: CrosswordEngine.givenShareFor(_difficulty),
    )
      ..onEvent = _onGameEvent
      ..addListener(_onEngineChanged);
    _startClock();
  }

  // ---------- Timer ----------

  /// Counts seconds while the puzzle is being played. It stops when the
  /// puzzle is finished and pauses while the app is in the background.
  void _startClock() {
    _clock?.cancel();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      final CrosswordEngine? engine = _engine;
      if (!mounted || _inBackground || engine == null || engine.isComplete) {
        return;
      }
      setState(() => _seconds++);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _inBackground = state != AppLifecycleState.resumed;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clock?.cancel();
    _engine?.removeListener(_onEngineChanged);
    _engine?.dispose();
    super.dispose();
  }

  void _onEngineChanged() {
    final CrosswordEngine? engine = _engine;
    if (engine == null) {
      return;
    }
    final int solved = engine.solvedWordCount;
    if (solved > _lastSolved && !engine.isComplete) {
      _playSolvedDing();
    }
    _lastSolved = solved;
    if (!engine.isComplete) {
      _celebrated = false;
      return;
    }
    if (!_celebrated) {
      _celebrated = true;
      unawaited(_finish(engine));
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

  /// Saves the result, then shows the celebration.
  Future<void> _finish(CrosswordEngine engine) async {
    final String? topicId = _topicId;
    final CrosswordPuzzle? puzzle = _puzzle;
    if (topicId == null || puzzle == null) {
      return;
    }
    final int seconds = _seconds;
    if (!widget.daily) {
      await PuzzleService.markCompleted(topicId, _difficulty, _number);
    }
    final GameResult result = await ScoreService.record(
      topicId: topicId,
      difficulty: _difficulty,
      engine: engine,
      seconds: seconds,
      isDaily: widget.daily,
    );
    if (!mounted) {
      return;
    }
    _result = result;
    SoundService.instance.play(Sfx.complete);
    SoundService.instance.buzz(Buzz.celebrate);
    // Let the player see the finished grid for a moment first.
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted || !engine.isComplete) {
      return;
    }
    await _showResults(engine);
  }

  /// Shows the celebration and acts on the player's choice.
  Future<void> _showResults(CrosswordEngine engine) async {
    final CrosswordPuzzle? puzzle = _puzzle;
    final GameResult? result = _result;
    if (puzzle == null || result == null) {
      return;
    }
    final FinishChoice? choice = await CelebrationDialog.show(
      context,
      title: puzzle.title,
      result: result,
    );
    if (!mounted) {
      return;
    }
    switch (choice) {
      case FinishChoice.review:
        setState(() => _reviewing = true);
      case FinishChoice.replay:
        _restart(engine);
      case FinishChoice.next:
        Navigator.of(context).pushReplacementNamed(AppRoutes.game);
      case FinishChoice.dashboard:
      case null:
        Navigator.of(context).pop();
    }
  }

  void _restart(CrosswordEngine engine) {
    SoundService.instance.play(Sfx.shuffle);
    _combo = 0;
    _lastSolveTime = null;
    _reviewing = false;
    _result = null;
    engine.restart();
    setState(() => _seconds = 0);
  }

  /// Leaves the solved grid: the next puzzle, or back for the daily one.
  void _leaveReview() {
    if (widget.daily) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.game);
    }
  }

  Future<void> _confirmRestart(CrosswordEngine engine) async {
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
      _restart(engine);
    }
  }

  void _onTool(_Tool tool) {
    final CrosswordEngine? engine = _engine;
    if (engine == null) {
      return;
    }
    switch (tool) {
      case _Tool.checkWord:
        final int wrong = engine.checkWord();
        _checkFeedback(wrong);
        _toast(wrong == 0
            ? 'No mistakes in this word so far.'
            : '$wrong wrong letter(s) marked in red.');
      case _Tool.checkPuzzle:
        final int wrong = engine.checkPuzzle();
        _checkFeedback(wrong);
        _toast(wrong == 0
            ? 'No mistakes in the puzzle so far.'
            : '$wrong wrong letter(s) marked in red.');
      case _Tool.revealLetter:
        SoundService.instance.play(Sfx.sparkle);
        engine.revealLetter();
      case _Tool.revealWord:
        SoundService.instance.play(Sfx.sparkle);
        engine.revealWord();
      case _Tool.clearWord:
        SoundService.instance.play(Sfx.whoosh);
        engine.clearWord();
      case _Tool.restart:
        _confirmRestart(engine);
      case _Tool.changeTopic:
        Navigator.of(context).pushNamed(AppRoutes.category);
      case _Tool.changeDifficulty:
        Navigator.of(context).pushNamed(AppRoutes.difficulty);
    }
  }

  void _checkFeedback(int wrong) {
    if (wrong > 0) {
      SoundService.instance.play(Sfx.buzzer);
      SoundService.instance.buzz(Buzz.strong);
    } else {
      SoundService.instance.play(Sfx.select);
    }
  }

  /// Sounds for taps, typing and moving around the grid.
  void _onGameEvent(GameEvent event) {
    switch (event) {
      case GameEvent.selected:
      case GameEvent.erased:
        SoundService.instance.play(Sfx.select);
      case GameEvent.moved:
        SoundService.instance.play(Sfx.whoosh);
      case GameEvent.placed:
        SoundService.instance.play(Sfx.snap);
      case GameEvent.blocked:
        SoundService.instance.play(Sfx.thud);
        SoundService.instance.buzz(Buzz.light);
    }
  }

  /// Words solved within 20 seconds of each other make a combo, and each
  /// one rings a step higher.
  void _playSolvedDing() {
    final DateTime now = DateTime.now();
    final DateTime? last = _lastSolveTime;
    if (last != null && now.difference(last) < const Duration(seconds: 20)) {
      _combo++;
    } else {
      _combo = 1;
    }
    _lastSolveTime = now;
    SoundService.instance.play(Sfx.ding(_combo));
    SoundService.instance.buzz(Buzz.light);
  }

  void _showClueSheet(CrosswordEngine engine) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => ListenableBuilder(
        listenable: engine,
        builder: (context, _) => SizedBox(
          height: 420,
          child: ClueList(
            engine: engine,
            onClueTap: () => Navigator.of(sheetContext).pop(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CrosswordPuzzle? puzzle = _puzzle;
    final CrosswordEngine? engine = _engine;

    return Scaffold(
      appBar: AppBar(
        title: puzzle == null
            ? const Text('Play Game')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    puzzle.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${_difficulty.label} · ${puzzle.words.length} words'
                    ' · ⏱ ${Helpers.formatDuration(_seconds)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
        actions: engine == null
            ? null
            : [
                IconButton(
                  tooltip: 'Reveal a letter',
                  icon: const Icon(Icons.lightbulb_outline_rounded),
                  onPressed: () => _onTool(_Tool.revealLetter),
                ),
                PopupMenuButton<_Tool>(
                  tooltip: 'More options',
                  onSelected: _onTool,
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: _Tool.checkWord,
                      child: Text('Check word'),
                    ),
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
                    PopupMenuItem(
                      value: _Tool.clearWord,
                      child: Text('Clear word'),
                    ),
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
      body: _buildBody(engine),
    );
  }

  Widget _buildBody(CrosswordEngine? engine) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final String? message = _message;
    if (engine == null || message != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.category_rounded,
                  size: 64,
                  color: AppColors.forestGreen,
                ),
                const SizedBox(height: 12),
                Text(
                  message ?? 'No puzzle available.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                if (_needsTopic) ...[
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.category),
                    child: const Text('Choose Topic'),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    final ValidationResult? validation = _validation;
    if (validation != null && !validation.isValid) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'This puzzle has a problem and cannot be played:\n\n'
            '${validation.errors.join('\n')}',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: engine,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final double w = constraints.maxWidth;
            final double h = constraints.maxHeight;

            // A phone held sideways is too short for grid, clue bar and
            // keyboard one above the other. Put the grid on the left and
            // the clue bar and keyboard on the right instead. The full
            // clue list opens from the Clues button.
            if (w > h && h < 480) {
              final double keyHeight = ((h - 130) / 3 - 6).clamp(30.0, 46.0);
              return SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      flex: 11,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: CrosswordGrid(engine: engine),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      flex: 10,
                      child: Column(
                        children: [
                          ActiveClueBar(engine: engine),
                          _ProgressRow(
                            engine: engine,
                            onShowClues: () => _showClueSheet(engine),
                          ),
                          const Spacer(),
                          if (_reviewing)
                            _ReviewBar(
                              daily: widget.daily,
                              onResults: () => _showResults(engine),
                              onNext: () => _leaveReview(),
                            )
                          else
                            GameKeyboard(
                              onLetter: engine.enterLetter,
                              onBackspace: engine.backspace,
                              keyHeight: keyHeight,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            // Side panel: big screens, or any screen held sideways.
            final bool side = w >= 900 || (w > h && w >= 640);
            // Clue tabs under the grid: tall screens such as tablets
            // held upright.
            final bool tabs = !side && h >= 720 && w >= 500;
            final Widget board = Column(
              children: [
                ActiveClueBar(engine: engine),
                Expanded(
                  flex: tabs ? 3 : 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CrosswordGrid(engine: engine),
                  ),
                ),
                if (tabs) ...[
                  const Divider(height: 1),
                  Expanded(flex: 2, child: ClueTabs(engine: engine)),
                  const Divider(height: 1),
                ],
                _ProgressRow(
                  engine: engine,
                  onShowClues:
                      side || tabs ? null : () => _showClueSheet(engine),
                ),
                if (_reviewing)
                  _ReviewBar(
                    daily: widget.daily,
                    onResults: () => _showResults(engine),
                    onNext: () => _leaveReview(),
                  )
                else
                  GameKeyboard(
                    onLetter: engine.enterLetter,
                    onBackspace: engine.backspace,
                  ),
              ],
            );
            if (!side) {
              return SafeArea(top: false, child: board);
            }
            return SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(child: board),
                  const VerticalDivider(width: 1),
                  SizedBox(
                    width: w >= 900 ? 340 : 260,
                    child: ClueList(engine: engine),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Shown in place of the keyboard while the player looks over a
/// finished puzzle.
class _ReviewBar extends StatelessWidget {
  final bool daily;
  final VoidCallback onResults;
  final VoidCallback onNext;

  const _ReviewBar({
    required this.daily,
    required this.onResults,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.forestGreen),
                const SizedBox(width: 6),
                const Flexible(
                  child: Text(
                    'Puzzle solved! Look over your answers.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onResults,
                    icon: const Icon(Icons.emoji_events_rounded),
                    label: const Text('Results'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: onNext,
                    child: Text(daily ? 'Done' : 'Next Puzzle'),
                  ),
                ),
              ],
            ),
          ],
        ),
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
          if (showClues != null) ...[
            const SizedBox(width: 10),
            FilledButton.tonalIcon(
              onPressed: showClues,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              icon: const Icon(Icons.list_alt_rounded),
              label: const Text('Clues'),
            ),
          ],
        ],
      ),
    );
  }
}
