import 'package:flutter/foundation.dart';

import '../models/crossword.dart';

/// The rules of play for one crossword.
/// The screen (Phase 7B) only shows what this engine says and passes taps
/// and key presses to it.
class CrosswordEngine extends ChangeNotifier {
  CrosswordEngine(this.puzzle)
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
    _selectFirst();
  }

  final CrosswordPuzzle puzzle;
  final List<List<String?>> _solution;
  final List<List<String>> _entries;
  final Map<CellPos, int> _numbers = {};
  final Set<CellPos> _revealed = {};
  final Set<CellPos> _wrong = {};
  late final List<CrosswordWord> _orderedWords;

  CellPos? _selected;
  ClueDirection _direction = ClueDirection.across;
  int _incorrectAttempts = 0;
  int _lettersRevealed = 0;
  int _wordsRevealed = 0;
  int _checksUsed = 0;

  static final RegExp _oneLetter = RegExp(r'^[A-Z]$');

  // ---------- Reading the board ----------

  int get rows => puzzle.rows;
  int get cols => puzzle.cols;
  CellPos? get selected => _selected;
  ClueDirection get direction => _direction;
  int get incorrectAttempts => _incorrectAttempts;
  int get lettersRevealed => _lettersRevealed;
  int get wordsRevealed => _wordsRevealed;
  int get checksUsed => _checksUsed;

  List<CrosswordWord> get acrossWords =>
      _orderedWords.where((w) => w.direction == ClueDirection.across).toList();

  List<CrosswordWord> get downWords =>
      _orderedWords.where((w) => w.direction == ClueDirection.down).toList();

  bool isBlock(int row, int col) => _solution[row][col] == null;

  String entryAt(int row, int col) => _entries[row][col];

  int? numberAt(int row, int col) => _numbers[CellPos(row, col)];

  int numberOf(CrosswordWord word) => _numbers[word.cellAt(0)] ?? 0;

  bool isRevealed(int row, int col) => _revealed.contains(CellPos(row, col));

  bool isWrong(int row, int col) => _wrong.contains(CellPos(row, col));

  bool isSelected(int row, int col) => _selected == CellPos(row, col);

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
      if (wordAt(cell, _direction) == null) {
        _direction = _direction.other;
      }
    }
    notifyListeners();
  }

  void toggleDirection() {
    final CellPos? cell = _selected;
    if (cell != null && wordAt(cell, _direction.other) != null) {
      _direction = _direction.other;
      notifyListeners();
    }
  }

  /// Jump to a word (for example, when its clue is tapped).
  void selectWord(CrosswordWord word) {
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

  // ---------- Typing ----------

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
    if (!_revealed.contains(cell)) {
      _entries[cell.row][cell.col] = upper;
      _wrong.remove(cell);
    }
    final int index = word.indexOf(cell);
    if (index < word.length - 1) {
      _selected = word.cellAt(index + 1);
    }
    notifyListeners();
  }

  /// Delete the letter here, or if empty, step back and delete that one.
  void backspace() {
    final CellPos? cell = _selected;
    final CrosswordWord? word = activeWord;
    if (cell == null || word == null) {
      return;
    }
    if (_entries[cell.row][cell.col].isNotEmpty) {
      _clearCell(cell);
    } else {
      final int index = word.indexOf(cell);
      if (index > 0) {
        final CellPos previous = word.cellAt(index - 1);
        _selected = previous;
        _clearCell(previous);
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
    if (_revealed.contains(cell)) {
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
      notifyListeners();
    }
  }

  bool _isCorrect(CellPos cell) =>
      _entries[cell.row][cell.col] == _solution[cell.row][cell.col];

  void _reveal(CellPos cell) {
    _entries[cell.row][cell.col] = _solution[cell.row][cell.col] ?? '';
    _revealed.add(cell);
    _wrong.remove(cell);
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
    _incorrectAttempts = 0;
    _lettersRevealed = 0;
    _wordsRevealed = 0;
    _checksUsed = 0;
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
