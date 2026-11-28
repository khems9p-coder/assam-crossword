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

  final List<Topic> allTopics = [
    for (final SubjectArea area in CategoryData.areas) ...area.topics,
  ];

  test('the question bank loads without problems', () {
    expect(QuestionBank.instance.problems, isEmpty);
    expect(QuestionBank.instance.totalEntries, greaterThanOrEqualTo(500));
  });

  test('all 34 topics have at least 12 questions', () {
    expect(allTopics.length, 34);
    for (final Topic topic in allTopics) {
      expect(
        QuestionBank.instance.entriesFor(topic.id).length,
        greaterThanOrEqualTo(12),
        reason: topic.name,
      );
    }
  });

  test('every topic makes valid puzzles at every difficulty', () {
    for (final Topic topic in allTopics) {
      for (final Difficulty level in Difficulty.values) {
        for (int number = 1; number <= 2; number++) {
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

  test('the next puzzle mostly uses different words', () {
    Set<String> wordsOf(String topicId, int number) => PuzzleService.build(
          topicId,
          Difficulty.easy,
          number,
        )!
            .words
            .map((w) => w.answer)
            .toSet();
    int repeated = 0;
    int total = 0;
    for (final Topic topic in allTopics) {
      final Set<String> second = wordsOf(topic.id, 2);
      repeated += second.intersection(wordsOf(topic.id, 1)).length;
      total += second.length;
    }
    expect(repeated / total, lessThan(0.5));
  });

  test('the same puzzle number always gives the same puzzle', () {
    final CrosswordPuzzle a =
        PuzzleService.build('eng_idioms', Difficulty.medium, 2)!;
    final CrosswordPuzzle b =
        PuzzleService.build('eng_idioms', Difficulty.medium, 2)!;
    expect(
      a.words.map((w) => '${w.answer}${w.row}${w.col}').toList(),
      b.words.map((w) => '${w.answer}${w.row}${w.col}').toList(),
    );
  });
}
