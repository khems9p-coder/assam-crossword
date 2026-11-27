import 'dart:math';

import '../data/question_bank.dart';
import '../models/crossword.dart';
import '../models/difficulty.dart';
import 'puzzle_validator.dart';

/// Builds a crossword layout from a topic's questions.
/// The same seed and puzzle number always give the same puzzle. Every
/// result is checked by [PuzzleValidator] before it is used.
///
/// To avoid repeats, the questions are dealt like a deck of cards: each
/// puzzle number starts further along the deck, so words from the last
/// puzzle come last in the queue for the next one.
class PuzzleGenerator {
  PuzzleGenerator._();

  static const int minWords = 4;
  static const int attempts = 30;

  static int maxWordsFor(Difficulty difficulty) => switch (difficulty) {
        Difficulty.easy => 6,
        Difficulty.medium => 9,
        Difficulty.hard => 12,
      };

  /// [seed] is fixed for a topic and difficulty; [number] is the puzzle
  /// number (1, 2, 3, ...).
  static CrosswordPuzzle? generate({
    required String id,
    required String title,
    required String topicId,
    required Difficulty difficulty,
    required List<BankEntry> entries,
    required int seed,
    int number = 1,
  }) {
    final int size = difficulty.gridSize;
    final int maxWords = maxWordsFor(difficulty);
    final List<BankEntry> pool =
        entries.where((e) => e.answer.length <= size).toList();
    if (pool.length < minWords) {
      return null;
    }
    final List<BankEntry> deck = _deckFor(pool, difficulty, maxWords, seed);
    final int start = ((number - 1) * maxWords) % deck.length;
    final List<BankEntry> queue = [
      ...deck.sublist(start),
      ...deck.sublist(0, start),
    ];

    CrosswordPuzzle? best;
    for (int attempt = 0; attempt < attempts; attempt++) {
      final int attemptSeed =
          ((seed ^ (number * 7919)) & 0x7fffffff) * 31 + attempt;
      final _Board board = _build(queue, size, maxWords, Random(attemptSeed));
      if (board.placed.length < minWords) {
        continue;
      }
      final CrosswordPuzzle puzzle = board.toPuzzle(
        id: id,
        title: title,
        topicId: topicId,
        difficulty: difficulty,
      );
      if (!PuzzleValidator.validate(puzzle).isValid) {
        continue;
      }
      if (best == null || puzzle.words.length > best.words.length) {
        best = puzzle;
      }
      if (best.words.length >= maxWords) {
        break;
      }
    }
    return best;
  }

  /// The topic's questions in a fixed shuffled order. Easy leaves out the
  /// hardest questions and Hard leaves out the easiest, when there are
  /// enough questions to do so.
  static List<BankEntry> _deckFor(
    List<BankEntry> pool,
    Difficulty difficulty,
    int maxWords,
    int seed,
  ) {
    final int preferred = difficulty.index + 1;
    final List<BankEntry> near =
        pool.where((e) => (e.level - preferred).abs() <= 1).toList();
    final List<BankEntry> deck =
        List<BankEntry>.of(near.length >= maxWords * 2 ? near : pool)
          ..sort((a, b) => a.answer.compareTo(b.answer));
    deck.shuffle(Random(seed));
    return deck;
  }

  static _Board _build(
    List<BankEntry> queue,
    int size,
    int maxWords,
    Random random,
  ) {
    // The next few words in the queue are tried first, in a random order.
    final List<BankEntry> window = queue.take(maxWords).toList()
      ..shuffle(random);
    final List<BankEntry> candidates = [...window, ...queue.skip(maxWords)];

    // Start with the longest of those words across the middle.
    BankEntry first = window.first;
    for (final BankEntry entry in window) {
      if (entry.answer.length > first.answer.length) {
        first = entry;
      }
    }
    candidates.remove(first);

    final _Board board = _Board(size * 3, size);
    board.place(
      first,
      board.n ~/ 2,
      (board.n - first.answer.length) ~/ 2,
      ClueDirection.across,
    );

    bool progress = true;
    while (board.placed.length < maxWords && progress) {
      progress = false;
      for (final BankEntry entry in List<BankEntry>.of(candidates)) {
        if (board.placed.length >= maxWords) {
          break;
        }
        final _Spot? spot = board.bestSpot(entry.answer, random);
        if (spot != null) {
          board.place(entry, spot.row, spot.col, spot.direction);
          candidates.remove(entry);
          progress = true;
        }
      }
    }
    return board;
  }
}

class _Spot {
  final int row;
  final int col;
  final ClueDirection direction;

  const _Spot(this.row, this.col, this.direction);
}

class _Placed {
  final BankEntry entry;
  final int row;
  final int col;
  final ClueDirection direction;

  const _Placed(this.entry, this.row, this.col, this.direction);
}

class _Board {
  _Board(this.n, this.limit)
      : _cells = List.generate(n, (_) => List<String?>.filled(n, null)),
        _across = List.generate(n, (_) => List<bool>.filled(n, false)),
        _down = List.generate(n, (_) => List<bool>.filled(n, false));

  final int n;
  final int limit;
  final List<List<String?>> _cells;
  final List<List<bool>> _across;
  final List<List<bool>> _down;
  final List<_Placed> placed = [];
  int _minR = 1 << 30;
  int _maxR = -1;
  int _minC = 1 << 30;
  int _maxC = -1;

  String? _at(int r, int c) =>
      (r < 0 || c < 0 || r >= n || c >= n) ? null : _cells[r][c];

  /// Number of crossings if the word fits here without breaking any rule,
  /// otherwise -1.
  int _crossings(String word, int r, int c, ClueDirection dir) {
    final int dr = dir == ClueDirection.down ? 1 : 0;
    final int dc = dir == ClueDirection.across ? 1 : 0;
    final int endR = r + dr * (word.length - 1);
    final int endC = c + dc * (word.length - 1);
    if (r < 0 || c < 0 || endR >= n || endC >= n) {
      return -1;
    }
    // The squares just before and after the word must be empty.
    if (_at(r - dr, c - dc) != null || _at(endR + dr, endC + dc) != null) {
      return -1;
    }
    int crossings = 0;
    for (int i = 0; i < word.length; i++) {
      final int rr = r + dr * i;
      final int cc = c + dc * i;
      final String? existing = _cells[rr][cc];
      if (existing != null) {
        if (existing != word[i]) {
          return -1;
        }
        final bool used =
            dir == ClueDirection.across ? _across[rr][cc] : _down[rr][cc];
        if (used) {
          return -1;
        }
        crossings++;
      } else {
        // New letters must not touch other letters side by side.
        if (_at(rr - dc, cc - dr) != null || _at(rr + dc, cc + dr) != null) {
          return -1;
        }
      }
    }
    if (max(_maxR, endR) - min(_minR, r) + 1 > limit ||
        max(_maxC, endC) - min(_minC, c) + 1 > limit) {
      return -1;
    }
    return crossings;
  }

  _Spot? bestSpot(String word, Random random) {
    _Spot? best;
    int bestCrossings = 0;
    for (final _Placed p in placed) {
      for (int k = 0; k < p.entry.answer.length; k++) {
        final int rr = p.row + (p.direction == ClueDirection.down ? k : 0);
        final int cc = p.col + (p.direction == ClueDirection.across ? k : 0);
        for (int i = 0; i < word.length; i++) {
          if (word[i] != _cells[rr][cc]) {
            continue;
          }
          for (final ClueDirection dir in ClueDirection.values) {
            final int r0 = dir == ClueDirection.down ? rr - i : rr;
            final int c0 = dir == ClueDirection.across ? cc - i : cc;
            final int crossings = _crossings(word, r0, c0, dir);
            if (crossings > 0 &&
                (crossings > bestCrossings ||
                    (crossings == bestCrossings && random.nextBool()))) {
              bestCrossings = crossings;
              best = _Spot(r0, c0, dir);
            }
          }
        }
      }
    }
    return best;
  }

  void place(BankEntry entry, int r, int c, ClueDirection dir) {
    final int dr = dir == ClueDirection.down ? 1 : 0;
    final int dc = dir == ClueDirection.across ? 1 : 0;
    final int length = entry.answer.length;
    for (int i = 0; i < length; i++) {
      final int rr = r + dr * i;
      final int cc = c + dc * i;
      _cells[rr][cc] = entry.answer[i];
      if (dir == ClueDirection.across) {
        _across[rr][cc] = true;
      } else {
        _down[rr][cc] = true;
      }
    }
    _minR = min(_minR, r);
    _maxR = max(_maxR, r + dr * (length - 1));
    _minC = min(_minC, c);
    _maxC = max(_maxC, c + dc * (length - 1));
    placed.add(_Placed(entry, r, c, dir));
  }

  CrosswordPuzzle toPuzzle({
    required String id,
    required String title,
    required String topicId,
    required Difficulty difficulty,
  }) {
    return CrosswordPuzzle(
      id: id,
      title: title,
      topicId: topicId,
      difficulty: difficulty,
      rows: _maxR - _minR + 1,
      cols: _maxC - _minC + 1,
      words: [
        for (final _Placed p in placed)
          CrosswordWord(
            answer: p.entry.answer,
            clue: p.entry.clue,
            row: p.row - _minR,
            col: p.col - _minC,
            direction: p.direction,
          ),
      ],
    );
  }
}
