import 'dart:math' show Random;

import 'package:flutter/foundation.dart';

import '../models/crossword.dart';
import '../models/difficulty.dart';

/// Things that happen during play, reported so the game can play sounds.
enum GameEvent {
  selected, // a square was tapped
  moved, // jumped to another clue
  placed, // a letter went into a square
  erased, // a letter was deleted
  blocked, // the move was not allowed (locked squares)
}

/// The rules of play for one crossword.
/// The screen only shows what this engine says and passes taps and key
/// presses to it.
///
/// A word that is fully correct turns green and its letters are locked:
/// they cannot be typed over or deleted. Revealed letters are locked too.
///
/// Starter letters: a few squares are filled in at the start (more on
/// Easy, fewer on Hard). They are locked and never fill a whole word.
class CrosswordEngine extends ChangeNotifier {
  CrosswordEngine(this.puzzle, {double givenShare = 0})
      : _solution = List.generate(
          puzzle.rows,
          (_) => List<String?>.filled(puzzle.cols, null),
        ),
        _entries = List.generate(
          puzzle.rows,
          (_) => List<String>.filled(puzzle.cols, ''),
        ) {
    for (final CrosswordWord word in puzzle.words) {
      for (int i = 0; i < word.length; i++) {
        final CellPos cell = word.cellAt(i);
        _solution[cell.row][cell.col] = word.answer[i];
      }
    }

    // Clue numbers go in reading order: left to right, top to bottom.
    final Set<CellPos> starts = {
      for (final CrosswordWord w in puzzle.words) w.cellAt(0),
    };
    int next = 0;
    for (int r = 0; r < puzzle.rows; r++) {
      for (int c = 0; c < puzzle.cols; c++) {
        final CellPos cell = CellPos(r, c);
        if (starts.contains(cell)) {
          next++;
          _numbers[cell] = next;
        }
      }
    }

    _orderedWords = [
      ..._sorted(ClueDirection.across),
      ..._sorted(ClueDirection.down),
    ];
    _placeGivens(givenShare);
    _fillGivens();
    _selectFirst();
  }

  /// How much of each word is filled in at the start.
  static double givenShareFor(Difficulty difficulty) => switch (difficulty) {
        Difficulty.easy => 0.34,
        Difficulty.medium => 0.2,
        Difficulty.hard => 0.1,
      };

  final CrosswordPuzzle puzzle;
  final List<List<String?>> _solution;
  final List<List<String>> _entries;
  final Map<CellPos, int> _numbers = {};
  final Set<CellPos> _revealed = {};
  final Set<CellPos> _wrong = {};
  final Set<CellPos> _given = {};
  final Set<CrosswordWord> _solved = {};
  final Set<CellPos> _solvedCells = {};
  late final List<CrosswordWord> _orderedWords;

  CellPos? _selected;
  ClueDirection _direction = ClueDirection.across;
  int _incorrectAttempts = 0;
  int _lettersRevealed = 0;
  int _wordsRevealed = 0;
  int _checksUsed = 0;

  static final RegExp _oneLetter = RegExp(r'^[A-Z]$');

  /// Called for every [GameEvent] (used for sound effects).
  void Function(GameEvent event)? onEvent;

  void _emit(GameEvent event) => onEvent?.call(event);

  // ---------- Reading the board ----------

  int get rows => puzzle.rows;
  int get cols => puzzle.cols;
  CellPos? get selected => _selected;
  ClueDirection get direction => _direction;
  int get incorrectAttempts => _incorrectAttempts;
  int get lettersRevealed => _lettersRevealed;
  int get wordsRevealed => _wordsRevealed;
  int get checksUsed => _checksUsed;
  int get solvedWordCount => _solved.length;

  List<CrosswordWord> get acrossWords =>
      _orderedWords.where((w) => w.direction == ClueDirection.across).toList();

  List<CrosswordWord> get downWords =>
      _orderedWords.where((w) => w.direction == ClueDirection.down).toList();

  bool isBlock(int row, int col) => _solution[row][col] == null;

  String entryAt(int row, int col) => _entries[row][col];

  int? numberAt(int row, int col) => _numbers[CellPos(row, col)];

  int numberOf(CrosswordWord word) => _numbers[word.cellAt(0)] ?? 0;

  bool isRevealed(int row, int col) => _revealed.contains(CellPos(row, col));

  /// True for a starter letter that was filled in at the start.
  bool isGiven(int row, int col) => _given.contains(CellPos(row, col));

  bool isWrong(int row, int col) => _wrong.contains(CellPos(row, col));

  bool isSelected(int row, int col) => _selected == CellPos(row, col);

  /// True when this square belongs to a word that is fully correct.
  bool isInSolvedWord(int row, int col) =>
      _solvedCells.contains(CellPos(row, col));

  /// True when the letter here can no longer be changed.
  bool isLocked(int row, int col) => _isLocked(CellPos(row, col));

  bool isWordSolved(CrosswordWord word) => _solved.contains(word);

  CrosswordWord? wordAt(CellPos cell, ClueDirection direction) {
    for (final CrosswordWord w in puzzle.words) {
      if (w.direction == direction && w.contains(cell)) {
        return w;
      }
    }
    return null;
  }

  CrosswordWord? get activeWord {
    final CellPos? cell = _selected;
    return cell == null ? null : wordAt(cell, _direction);
  }

  bool isInActiveWord(int row, int col) =>
      activeWord?.contains(CellPos(row, col)) ?? false;

  int get totalCells {
    int count = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (!isBlock(r, c)) {
          count++;
        }
      }
    }
    return count;
  }

  int get filledCells {
    int count = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (!isBlock(r, c) && _entries[r][c].isNotEmpty) {
          count++;
        }
      }
    }
    return count;
  }

  int get correctCells {
    int count = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (!isBlock(r, c) && _entries[r][c] == _solution[r][c]) {
          count++;
        }
      }
    }
    return count;
  }

  /// How much of the grid has letters in it (0.0 to 1.0).
  double get completion => totalCells == 0 ? 0 : filledCells / totalCells;

  bool get isComplete => correctCells == totalCells;

  // ---------- Moving around ----------

  /// Tap a square. Tapping the same square again switches Across/Down.
  /// On a new square, an unsolved word is preferred over a solved one.
  void selectCell(int row, int col) {
    if (isBlock(row, col)) {
      return;
    }
    final CellPos cell = CellPos(row, col);
    if (_selected == cell) {
      if (wordAt(cell, _direction.other) != null) {
        _direction = _direction.other;
      }
    } else {
      _selected = cell;
      final CrosswordWord? current = wordAt(cell, _direction);
      final CrosswordWord? other = wordAt(cell, _direction.other);
      if (current == null ||
          (_solved.contains(current) &&
              other != null &&
              !_solved.contains(other))) {
        _direction = _direction.other;
      }
    }
    _emit(GameEvent.selected);
    notifyListeners();
  }

  void toggleDirection() {
    final CellPos? cell = _selected;
    if (cell != null && wordAt(cell, _direction.other) != null) {
      _direction = _direction.other;
      _emit(GameEvent.selected);
      notifyListeners();
    }
  }

  /// Jump to a word (for example, when its clue is tapped).
  void selectWord(CrosswordWord word) {
    _select(word);
    _emit(GameEvent.moved);
  }

  void _select(CrosswordWord word) {
    _direction = word.direction;
    _selected = word.cellAt(0);
    for (final CellPos cell in word.cells) {
      if (_entries[cell.row][cell.col].isEmpty) {
        _selected = cell;
        break;
      }
    }
    notifyListeners();
  }

  void nextWord() => _moveWord(1);

  void previousWord() => _moveWord(-1);

  void _moveWord(int step) {
    final CrosswordWord? current = activeWord;
    int index = current == null ? 0 : _orderedWords.indexOf(current);
    index = (index + step) % _orderedWords.length;
    if (index < 0) {
      index += _orderedWords.length;
    }
    selectWord(_orderedWords[index]);
  }

  /// After a word is solved, move on to the next word that is not solved.
  void _goToNextUnsolved(CrosswordWord from) {
    final int start = _orderedWords.indexOf(from);
    for (int step = 1; step <= _orderedWords.length; step++) {
      final CrosswordWord word =
          _orderedWords[(start + step) % _orderedWords.length];
      if (!_solved.contains(word)) {
        _select(word);
        return;
      }
    }
  }

  // ---------- Typing ----------

  /// Types a letter in the selected square, skipping locked squares.
  void enterLetter(String letter) {
    final CellPos? cell = _selected;
    final CrosswordWord? word = activeWord;
    if (cell == null || word == null) {
      return;
    }
    final String upper = letter.toUpperCase();
    if (!_oneLetter.hasMatch(upper)) {
      return;
    }

    int index = word.indexOf(cell);
    while (index < word.length && _isLocked(word.cellAt(index))) {
      index++;
    }
    if (index >= word.length) {
      _emit(GameEvent.blocked); // Every square left in this word is locked.
      return;
    }
    final CellPos target = word.cellAt(index);
    _entries[target.row][target.col] = upper;
    _wrong.remove(target);
    _selected = target;

    int next = index + 1;
    while (next < word.length && _isLocked(word.cellAt(next))) {
      next++;
    }
    if (next < word.length) {
      _selected = word.cellAt(next);
    }

    _emit(GameEvent.placed);
    final List<CrosswordWord> newlySolved = _refreshSolved();
    if (newlySolved.contains(word) && !isComplete) {
      _goToNextUnsolved(word);
    }
    notifyListeners();
  }

  /// Delete the letter here, or if empty, step back and delete that one.
  /// Locked letters are never deleted.
  void backspace() {
    final CellPos? cell = _selected;
    final CrosswordWord? word = activeWord;
    if (cell == null || word == null) {
      return;
    }
    if (_entries[cell.row][cell.col].isNotEmpty && !_isLocked(cell)) {
      _clearCell(cell);
      _emit(GameEvent.erased);
    } else {
      int index = word.indexOf(cell) - 1;
      while (index >= 0 && _isLocked(word.cellAt(index))) {
        index--;
      }
      if (index >= 0) {
        final CellPos previous = word.cellAt(index);
        _selected = previous;
        _clearCell(previous);
        _emit(GameEvent.erased);
      } else {
        _emit(GameEvent.blocked);
      }
    }
    notifyListeners();
  }

  /// Delete only the letter in the selected square.
  void deleteLetter() {
    final CellPos? cell = _selected;
    if (cell == null) {
      return;
    }
    _clearCell(cell);
    notifyListeners();
  }

  void clearWord() {
    final CrosswordWord? word = activeWord;
    if (word == null) {
      return;
    }
    for (final CellPos cell in word.cells) {
      _clearCell(cell);
    }
    _selected = word.cellAt(0);
    notifyListeners();
  }

  void _clearCell(CellPos cell) {
    if (_isLocked(cell)) {
      return;
    }
    _entries[cell.row][cell.col] = '';
    _wrong.remove(cell);
  }

  // ---------- Checking and hints ----------

  /// Marks wrong letters in the active word. Returns how many were wrong.
  int checkWord() {
    final CrosswordWord? word = activeWord;
    if (word == null) {
      return 0;
    }
    _checksUsed++;
    final int wrong = _markWrong(word.cells);
    notifyListeners();
    return wrong;
  }

  /// Marks wrong letters anywhere on the grid. Returns how many were wrong.
  int checkPuzzle() {
    _checksUsed++;
    final List<CellPos> all = [
      for (int r = 0; r < rows; r++)
        for (int c = 0; c < cols; c++)
          if (!isBlock(r, c)) CellPos(r, c),
    ];
    final int wrong = _markWrong(all);
    notifyListeners();
    return wrong;
  }

  int _markWrong(List<CellPos> cells) {
    int wrong = 0;
    for (final CellPos cell in cells) {
      final String entry = _entries[cell.row][cell.col];
      if (entry.isNotEmpty && entry != _solution[cell.row][cell.col]) {
        if (_wrong.add(cell)) {
          wrong++;
        }
      }
    }
    _incorrectAttempts += wrong;
    return wrong;
  }

  void revealLetter() {
    final CellPos? cell = _selected;
    if (cell == null || _isCorrect(cell)) {
      return;
    }
    _reveal(cell);
    _lettersRevealed++;
    _refreshSolved();
    notifyListeners();
  }

  void revealWord() {
    final CrosswordWord? word = activeWord;
    if (word == null) {
      return;
    }
    bool changed = false;
    for (final CellPos cell in word.cells) {
      if (!_isCorrect(cell)) {
        _reveal(cell);
        changed = true;
      }
    }
    if (changed) {
      _wordsRevealed++;
      _refreshSolved();
      if (!isComplete) {
        _goToNextUnsolved(word);
      }
      notifyListeners();
    }
  }

  bool _isCorrect(CellPos cell) =>
      _entries[cell.row][cell.col] == _solution[cell.row][cell.col];

  bool _isLocked(CellPos cell) =>
      _given.contains(cell) ||
      _revealed.contains(cell) ||
      _solvedCells.contains(cell);

  /// Chooses the starter letters. The same puzzle always gets the same
  /// ones, and no word is ever completely filled in.
  void _placeGivens(double share) {
    if (share <= 0) {
      return;
    }
    int seed = 7;
    for (final int unit in puzzle.id.codeUnits) {
      seed = (seed * 31 + unit) & 0x7fffffff;
    }
    final Random random = Random(seed);
    for (final CrosswordWord word in _orderedWords) {
      final int wanted = (word.length * share).round();
      int count = word.cells.where(_given.contains).length;
      final List<CellPos> cells = word.cells..shuffle(random);
      for (final CellPos cell in cells) {
        if (count >= wanted) {
          break;
        }
        if (_given.contains(cell)) {
          continue;
        }
        _given.add(cell);
        final bool fillsAWord = puzzle.words.any(
          (w) => w.contains(cell) && w.cells.every(_given.contains),
        );
        if (fillsAWord) {
          _given.remove(cell);
          continue;
        }
        count++;
      }
    }
  }

  void _fillGivens() {
    for (final CellPos cell in _given) {
      _entries[cell.row][cell.col] = _solution[cell.row][cell.col] ?? '';
    }
  }

  void _reveal(CellPos cell) {
    _entries[cell.row][cell.col] = _solution[cell.row][cell.col] ?? '';
    _revealed.add(cell);
    _wrong.remove(cell);
  }

  /// Finds words that have just become fully correct and locks them.
  List<CrosswordWord> _refreshSolved() {
    final List<CrosswordWord> newlySolved = [];
    for (final CrosswordWord word in puzzle.words) {
      if (_solved.contains(word)) {
        continue;
      }
      if (word.cells.every(_isCorrect)) {
        _solved.add(word);
        _solvedCells.addAll(word.cells);
        _wrong.removeAll(word.cells);
        newlySolved.add(word);
      }
    }
    return newlySolved;
  }

  // ---------- Starting again ----------

  void restart() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        _entries[r][c] = '';
      }
    }
    _revealed.clear();
    _wrong.clear();
    _solved.clear();
    _solvedCells.clear();
    _incorrectAttempts = 0;
    _lettersRevealed = 0;
    _wordsRevealed = 0;
    _checksUsed = 0;
    _fillGivens();
    _selectFirst();
    notifyListeners();
  }

  // ---------- Helpers ----------

  List<CrosswordWord> _sorted(ClueDirection direction) {
    final List<CrosswordWord> list =
        puzzle.words.where((w) => w.direction == direction).toList();
    list.sort((a, b) => numberOf(a).compareTo(numberOf(b)));
    return list;
  }

  void _selectFirst() {
    final CrosswordWord first = _orderedWords.first;
    _selected = first.cellAt(0);
    _direction = first.direction;
  }
}
