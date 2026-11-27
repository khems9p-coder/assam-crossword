import 'package:flutter_test/flutter_test.dart';

import 'package:assamcrossword/data/sample_puzzles.dart';
import 'package:assamcrossword/game/crossword_engine.dart';
import 'package:assamcrossword/game/puzzle_validator.dart';
import 'package:assamcrossword/models/crossword.dart';
import 'package:assamcrossword/models/difficulty.dart';

CrosswordPuzzle makePuzzle(int rows, int cols, List<CrosswordWord> words) {
  return CrosswordPuzzle(
    id: 'test',
    title: 'Test',
    topicId: 'assam_geography',
    difficulty: Difficulty.easy,
    rows: rows,
    cols: cols,
    words: words,
  );
}

CrosswordWord across(String answer, int row, int col) => CrosswordWord(
      answer: answer,
      clue: 'clue',
      row: row,
      col: col,
      direction: ClueDirection.across,
    );

CrosswordWord down(String answer, int row, int col) => CrosswordWord(
      answer: answer,
      clue: 'clue',
      row: row,
      col: col,
      direction: ClueDirection.down,
    );

void main() {
  group('PuzzleValidator', () {
    test('the sample puzzle is valid', () {
      final ValidationResult result =
          PuzzleValidator.validate(SamplePuzzles.assamStarter);
      expect(result.errors, isEmpty);
    });

    test('crossing words with different letters are caught', () {
      final ValidationResult result = PuzzleValidator.validate(
        makePuzzle(3, 3, [across('CAT', 0, 0), down('DOG', 0, 0)]),
      );
      expect(result.isValid, isFalse);
    });

    test('words that do not fit are caught', () {
      final ValidationResult result = PuzzleValidator.validate(
        makePuzzle(3, 3, [across('TIGER', 0, 0)]),
      );
      expect(result.isValid, isFalse);
    });

    test('accidental extra words are caught', () {
      final ValidationResult result = PuzzleValidator.validate(
        makePuzzle(3, 3, [across('CAT', 0, 0), across('OX', 1, 0)]),
      );
      expect(result.isValid, isFalse);
    });

    test('disconnected words are caught', () {
      final ValidationResult result = PuzzleValidator.validate(
        makePuzzle(3, 3, [across('CAT', 0, 0), across('DOG', 2, 0)]),
      );
      expect(result.isValid, isFalse);
    });
  });

  group('CrosswordEngine', () {
    late CrosswordEngine game;

    CrosswordWord word(String answer) =>
        game.puzzle.words.firstWhere((w) => w.answer == answer);

    setUp(() {
      game = CrosswordEngine(SamplePuzzles.assamStarter);
    });

    test('clues are numbered in reading order', () {
      expect(game.numberOf(word('TEA')), 1);
      expect(game.numberOf(word('TIGER')), 1);
      expect(game.numberOf(word('GAS')), 2);
      expect(game.numberOf(word('SKI')), 3);
      expect(game.numberOf(word('RHINO')), 4);
      expect(game.totalCells, 14);
    });

    test('typing fills the word and moves to the next square', () {
      expect(game.activeWord?.answer, 'TEA');
      game.enterLetter('t');
      game.enterLetter('E');
      game.enterLetter('A');
      expect(game.entryAt(0, 0), 'T');
      expect(game.entryAt(0, 1), 'E');
      expect(game.entryAt(0, 2), 'A');
    });

    test('a solved word turns green, locks and moves on', () {
      game.enterLetter('T');
      game.enterLetter('E');
      game.enterLetter('A');
      expect(game.isWordSolved(word('TEA')), isTrue);
      expect(game.isInSolvedWord(0, 1), isTrue);
      expect(game.isLocked(0, 0), isTrue);
      expect(game.activeWord?.answer, 'GAS');
    });

    test('typing skips over locked letters', () {
      game.enterLetter('T');
      game.enterLetter('E');
      game.enterLetter('A');
      game.selectCell(0, 0);
      expect(game.activeWord?.answer, 'TIGER');
      game.enterLetter('X');
      expect(game.entryAt(0, 0), 'T');
      expect(game.entryAt(1, 0), 'X');
    });

    test('backspace and clear never delete locked letters', () {
      game.enterLetter('T');
      game.enterLetter('E');
      game.enterLetter('A');
      game.selectWord(word('TIGER'));
      game.backspace();
      game.clearWord();
      expect(game.entryAt(0, 0), 'T');
      game.selectWord(word('TEA'));
      game.clearWord();
      expect(game.entryAt(0, 1), 'E');
    });

    test('tapping the same square switches Across and Down', () {
      game.selectCell(0, 0);
      expect(game.direction, ClueDirection.down);
      expect(game.activeWord?.answer, 'TIGER');
    });

    test('backspace clears and steps back', () {
      game.enterLetter('T');
      game.enterLetter('E');
      game.backspace();
      expect(game.entryAt(0, 1), '');
      expect(game.selected, const CellPos(0, 1));
    });

    test('check marks wrong letters', () {
      game.enterLetter('X');
      final int wrong = game.checkWord();
      expect(wrong, 1);
      expect(game.isWrong(0, 0), isTrue);
      expect(game.incorrectAttempts, 1);
    });

    test('revealing every word completes the puzzle', () {
      for (final CrosswordWord w in game.puzzle.words) {
        game.selectWord(w);
        game.revealWord();
      }
      expect(game.isComplete, isTrue);
      expect(game.completion, 1.0);
    });

    test('starter letters are filled in and locked', () {
      final CrosswordEngine easy =
          CrosswordEngine(SamplePuzzles.assamStarter, givenShare: 0.34);
      int countGivens() {
        int count = 0;
        for (int r = 0; r < easy.rows; r++) {
          for (int c = 0; c < easy.cols; c++) {
            if (!easy.isBlock(r, c) && easy.isGiven(r, c)) {
              count++;
              expect(easy.isLocked(r, c), isTrue);
              expect(easy.entryAt(r, c), isNotEmpty);
            }
          }
        }
        return count;
      }

      final int givens = countGivens();
      expect(givens, greaterThan(0));
      for (final CrosswordWord w in easy.puzzle.words) {
        expect(w.cells.every((p) => easy.isGiven(p.row, p.col)), isFalse);
      }
      easy.restart();
      expect(countGivens(), givens);
    });

    test('events are reported for sound effects', () {
      final List<GameEvent> events = [];
      game.onEvent = events.add;
      game.enterLetter('T');
      game.enterLetter('E');
      game.enterLetter('A');
      expect(events, [GameEvent.placed, GameEvent.placed, GameEvent.placed]);
      game.selectWord(word('TEA'));
      game.enterLetter('X');
      expect(events.sublist(3), [GameEvent.moved, GameEvent.blocked]);
    });

    test('restart clears everything', () {
      game.enterLetter('T');
      game.revealLetter();
      game.restart();
      expect(game.filledCells, 0);
      expect(game.solvedWordCount, 0);
      expect(game.lettersRevealed, 0);
      expect(game.activeWord?.answer, 'TEA');
    });
  });
}
