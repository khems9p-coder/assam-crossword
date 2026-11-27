import '../models/crossword.dart';

class ValidationResult {
  final List<String> errors;

  const ValidationResult(this.errors);

  bool get isValid => errors.isEmpty;
}

/// Checks that a puzzle is safe to play:
/// - every answer is capital letters A-Z, has a clue, and is not repeated
/// - every word fits inside the grid
/// - crossing words share the same letter
/// - no accidental extra "words" are formed by touching letters
/// - all words are joined together, so every square can be reached
class PuzzleValidator {
  PuzzleValidator._();

  static final RegExp _letters = RegExp(r'^[A-Z]+$');

  static ValidationResult validate(CrosswordPuzzle puzzle) {
    final List<String> errors = [];

    if (puzzle.rows < 2 || puzzle.cols < 2) {
      errors.add('The grid must be at least 2 x 2.');
    }
    if (puzzle.words.isEmpty) {
      errors.add('The puzzle has no words.');
      return ValidationResult(errors);
    }

    final List<List<String?>> grid = List.generate(
      puzzle.rows,
      (_) => List<String?>.filled(puzzle.cols, null),
    );
    final Set<String> answers = {};
    final Set<String> starts = {};

    for (final CrosswordWord word in puzzle.words) {
      final String name =
          '"${word.answer}" (${word.direction.label} at ${word.row},${word.col})';

      if (!_letters.hasMatch(word.answer)) {
        errors.add('$name must use only capital letters A-Z.');
        continue;
      }
      if (word.length < 2) {
        errors.add('$name must be at least 2 letters long.');
        continue;
      }
      if (word.clue.trim().isEmpty) {
        errors.add('$name has no clue.');
      }
      if (!answers.add(word.answer)) {
        errors.add('$name is a duplicate answer.');
      }
      if (!starts.add('${word.direction.name}:${word.row}:${word.col}')) {
        errors.add('$name starts in the same square as another '
            '${word.direction.label} word.');
      }

      bool fits = true;
      for (final CellPos cell in word.cells) {
        if (cell.row < 0 ||
            cell.col < 0 ||
            cell.row >= puzzle.rows ||
            cell.col >= puzzle.cols) {
          fits = false;
        }
      }
      if (!fits) {
        errors.add('$name does not fit inside the grid.');
        continue;
      }

      for (int i = 0; i < word.length; i++) {
        final CellPos cell = word.cellAt(i);
        final String letter = word.answer[i];
        final String? existing = grid[cell.row][cell.col];
        if (existing != null && existing != letter) {
          errors.add('$name clashes at (${cell.row},${cell.col}): '
              '"$existing" vs "$letter".');
        } else {
          grid[cell.row][cell.col] = letter;
        }
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult(errors);
    }

    // Every line of 2+ touching letters must be exactly one listed word.
    final Set<String> wordKeys = {
      for (final CrosswordWord w in puzzle.words)
        '${w.direction.name}:${w.row}:${w.col}:${w.length}',
    };

    for (final ClueDirection dir in ClueDirection.values) {
      final bool across = dir == ClueDirection.across;
      final int lines = across ? puzzle.rows : puzzle.cols;
      final int lineLength = across ? puzzle.cols : puzzle.rows;

      bool filled(int line, int pos) =>
          across ? grid[line][pos] != null : grid[pos][line] != null;

      for (int line = 0; line < lines; line++) {
        int pos = 0;
        while (pos < lineLength) {
          if (!filled(line, pos)) {
            pos++;
            continue;
          }
          final int start = pos;
          while (pos < lineLength && filled(line, pos)) {
            pos++;
          }
          final int length = pos - start;
          if (length >= 2) {
            final int row = across ? line : start;
            final int col = across ? start : line;
            if (!wordKeys.contains('${dir.name}:$row:$col:$length')) {
              errors.add('Touching letters make an unlisted ${dir.label} '
                  'word at ($row,$col), $length letters long.');
            }
          }
        }
      }
    }

    // All letters must be joined into one connected puzzle.
    final List<CellPos> filledCells = [
      for (int r = 0; r < puzzle.rows; r++)
        for (int c = 0; c < puzzle.cols; c++)
          if (grid[r][c] != null) CellPos(r, c),
    ];
    final Set<CellPos> visited = {filledCells.first};
    final List<CellPos> queue = [filledCells.first];
    while (queue.isNotEmpty) {
      final CellPos current = queue.removeLast();
      for (final CellPos next in [
        CellPos(current.row - 1, current.col),
        CellPos(current.row + 1, current.col),
        CellPos(current.row, current.col - 1),
        CellPos(current.row, current.col + 1),
      ]) {
        if (next.row < 0 ||
            next.col < 0 ||
            next.row >= puzzle.rows ||
            next.col >= puzzle.cols) {
          continue;
        }
        if (grid[next.row][next.col] != null && visited.add(next)) {
          queue.add(next);
        }
      }
    }
    if (visited.length != filledCells.length) {
      errors.add('Some words are not connected to the rest of the puzzle.');
    }

    return ValidationResult(errors);
  }
}
