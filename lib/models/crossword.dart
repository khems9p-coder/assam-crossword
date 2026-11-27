import 'difficulty.dart';

enum ClueDirection {
  across,
  down;

  String get label => this == ClueDirection.across ? 'Across' : 'Down';

  ClueDirection get other =>
      this == ClueDirection.across ? ClueDirection.down : ClueDirection.across;
}

/// One square on the grid.
class CellPos {
  final int row;
  final int col;

  const CellPos(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is CellPos && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => '($row, $col)';
}

/// One answer in the puzzle, with its clue and where it sits.
class CrosswordWord {
  final String answer;
  final String clue;
  final int row;
  final int col;
  final ClueDirection direction;

  const CrosswordWord({
    required this.answer,
    required this.clue,
    required this.row,
    required this.col,
    required this.direction,
  });

  int get length => answer.length;

  CellPos cellAt(int index) => direction == ClueDirection.across
      ? CellPos(row, col + index)
      : CellPos(row + index, col);

  List<CellPos> get cells => [for (int i = 0; i < length; i++) cellAt(i)];

  /// Position of [pos] inside this word, or -1 if it is not part of it.
  int indexOf(CellPos pos) {
    if (direction == ClueDirection.across) {
      if (pos.row != row) {
        return -1;
      }
      final int i = pos.col - col;
      return (i >= 0 && i < length) ? i : -1;
    }
    if (pos.col != col) {
      return -1;
    }
    final int i = pos.row - row;
    return (i >= 0 && i < length) ? i : -1;
  }

  bool contains(CellPos pos) => indexOf(pos) >= 0;
}

/// A complete crossword: grid size plus all its words.
class CrosswordPuzzle {
  final String id;
  final String title;
  final String topicId;
  final Difficulty difficulty;
  final int rows;
  final int cols;
  final List<CrosswordWord> words;

  const CrosswordPuzzle({
    required this.id,
    required this.title,
    required this.topicId,
    required this.difficulty,
    required this.rows,
    required this.cols,
    required this.words,
  });
}
