import 'package:flutter_test/flutter_test.dart';

import 'package:assamcrossword/data/category_data.dart';
import 'package:assamcrossword/data/question_bank.dart';
import 'package:assamcrossword/game/puzzle_validator.dart';
import 'package:assamcrossword/models/crossword.dart';
import 'package:assamcrossword/models/difficulty.dart';
import 'package:assamcrossword/services/puzzle_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await QuestionBank.instance.load();
  });

  final SubjectArea assam =
      CategoryData.areas.firstWhere((area) => area.id == 'assam');

  test('the question bank loads without problems', () {
    expect(QuestionBank.instance.problems, isEmpty);
    expect(QuestionBank.instance.totalEntries, greaterThanOrEqualTo(90));
  });

  test('every Assam topic has at least 12 questions', () {
    for (final Topic topic in assam.topics) {
      expect(
        QuestionBank.instance.entriesFor(topic.id).length,
        greaterThanOrEqualTo(12),
        reason: topic.name,
      );
    }
  });

  test('every Assam topic makes valid puzzles at every difficulty', () {
    for (final Topic topic in assam.topics) {
      for (final Difficulty level in Difficulty.values) {
        for (int number = 1; number <= 3; number++) {
          final CrosswordPuzzle? puzzle =
              PuzzleService.build(topic.id, level, number);
          final String name = '${topic.name} ${level.label} #$number';
          expect(puzzle, isNotNull, reason: name);
          expect(PuzzleValidator.validate(puzzle!).errors, isEmpty,
              reason: name);
          expect(puzzle.words.length, greaterThanOrEqualTo(4), reason: name);
          expect(puzzle.rows, lessThanOrEqualTo(level.gridSize), reason: name);
          expect(puzzle.cols, lessThanOrEqualTo(level.gridSize), reason: name);
        }
      }
    }
  });

  test('the same puzzle number always gives the same puzzle', () {
    final CrosswordPuzzle a =
        PuzzleService.build('assam_culture', Difficulty.medium, 2)!;
    final CrosswordPuzzle b =
        PuzzleService.build('assam_culture', Difficulty.medium, 2)!;
    expect(
      a.words.map((w) => '${w.answer}${w.row}${w.col}').toList(),
      b.words.map((w) => '${w.answer}${w.row}${w.col}').toList(),
    );
  });
}
