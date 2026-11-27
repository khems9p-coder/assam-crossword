import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:assamcrossword/data/question_bank.dart';
import 'package:assamcrossword/data/sample_puzzles.dart';
import 'package:assamcrossword/game/crossword_engine.dart';
import 'package:assamcrossword/game/puzzle_validator.dart';
import 'package:assamcrossword/models/achievement.dart';
import 'package:assamcrossword/models/crossword.dart';
import 'package:assamcrossword/models/difficulty.dart';
import 'package:assamcrossword/services/achievement_service.dart';
import 'package:assamcrossword/services/app_state.dart';
import 'package:assamcrossword/services/daily_service.dart';
import 'package:assamcrossword/services/local_store.dart';
import 'package:assamcrossword/services/score_service.dart';

/// Solves the sample puzzle by typing, without any hints.
CrosswordEngine solvedSample() {
  final CrosswordEngine game = CrosswordEngine(SamplePuzzles.assamStarter);
  for (final CrosswordWord word in game.puzzle.words) {
    if (game.isWordSolved(word)) {
      continue;
    }
    game.selectWord(word);
    for (int i = 0; i < word.length; i++) {
      final CellPos cell = word.cellAt(i);
      if (!game.isLocked(cell.row, cell.col)) {
        game.enterLetter(word.answer[i]);
      }
    }
  }
  return game;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await QuestionBank.instance.load();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStore.instance.init();
    await AppState.instance.resetLocalData();
  });

  test('the streak counts days in a row', () {
    final DateTime today = DateTime(2026, 11, 27);
    expect(DailyService.streak({}, today), 0);
    expect(
      DailyService.streak({'2026-11-27', '2026-11-26', '2026-11-25'}, today),
      3,
    );
    // Today not played yet: the streak from yesterday still counts.
    expect(DailyService.streak({'2026-11-26', '2026-11-25'}, today), 2);
    expect(DailyService.streak({'2026-11-27', '2026-11-25'}, today), 1);
    expect(DailyService.streak({'2026-11-24'}, today), 0);
    // Across the end of a month.
    expect(
      DailyService.streak({'2026-12-01', '2026-11-30'}, DateTime(2026, 12, 1)),
      2,
    );
  });

  test('every day has a valid puzzle and the topic changes daily', () {
    for (int i = 0; i < 60; i++) {
      final DateTime day = DateTime(2026, 11, 27 + i);
      final DateTime next = DateTime(2026, 11, 28 + i);
      final CrosswordPuzzle? puzzle = DailyService.build(day);
      expect(puzzle, isNotNull, reason: DailyService.dateKey(day));
      expect(PuzzleValidator.validate(puzzle!).errors, isEmpty);
      expect(puzzle.words.length, greaterThanOrEqualTo(4));
      expect(DailyService.topicFor(day).id,
          isNot(DailyService.topicFor(next).id));
    }
    final DateTime day = DateTime(2026, 11, 27);
    expect(
      DailyService.build(day)!.words.map((w) => w.answer).toList(),
      DailyService.build(day)!.words.map((w) => w.answer).toList(),
    );
  });

  test('the daily finish counts once, with bonus and streak', () async {
    final CrosswordEngine game = solvedSample();
    final GameResult first = await ScoreService.record(
      topicId: 'assam_history',
      difficulty: Difficulty.medium,
      engine: game,
      seconds: 100,
      isDaily: true,
    );
    expect(first.isDaily, isTrue);
    expect(first.dailyStreak, 1);
    expect(DailyService.isDone(DailyService.today()), isTrue);
    expect(AppState.instance.stats.dailyCompleted, 1);
    expect(AppState.instance.stats.bestStreak, 1);

    final GameResult replay = await ScoreService.record(
      topicId: 'assam_history',
      difficulty: Difficulty.medium,
      engine: game,
      seconds: 100,
      isDaily: true,
    );
    expect(AppState.instance.stats.dailyCompleted, 1);
    expect(first.points, replay.points + ScoreService.dailyBonus);
  });

  test('achievements unlock once and are saved', () async {
    final CrosswordEngine game = solvedSample();
    final GameResult first = await ScoreService.record(
      topicId: 'assam_wildlife',
      difficulty: Difficulty.easy,
      engine: game,
      seconds: 50,
    );
    final List<String> ids =
        first.newAchievements.map((Achievement a) => a.id).toList();
    expect(ids, containsAll(['first_puzzle', 'first_perfect']));

    final GameResult second = await ScoreService.record(
      topicId: 'assam_wildlife',
      difficulty: Difficulty.easy,
      engine: game,
      seconds: 50,
    );
    expect(second.newAchievements, isEmpty);
    expect(
      AppState.instance.stats.unlockedAchievements,
      containsAll(['first_puzzle', 'first_perfect']),
    );
  });

  test('Speed Solver needs Medium or Hard in under 5 minutes', () {
    expect(AchievementService.isSpeedy(Difficulty.easy, 100, 0), isFalse);
    expect(AchievementService.isSpeedy(Difficulty.medium, 299, 0), isTrue);
    expect(AchievementService.isSpeedy(Difficulty.medium, 300, 0), isFalse);
    expect(AchievementService.isSpeedy(Difficulty.hard, 100, 1), isFalse);
  });
}
