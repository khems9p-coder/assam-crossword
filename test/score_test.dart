import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:assamcrossword/data/sample_puzzles.dart';
import 'package:assamcrossword/game/crossword_engine.dart';
import 'package:assamcrossword/models/crossword.dart';
import 'package:assamcrossword/models/difficulty.dart';
import 'package:assamcrossword/services/app_state.dart';
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

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStore.instance.init();
    await AppState.instance.resetLocalData();
  });

  test('points reward speed and take off for hints', () {
    final int fast = ScoreService.pointsFor(
      difficulty: Difficulty.easy,
      wordCount: 6,
      seconds: 30,
      lettersRevealed: 0,
      wordsRevealed: 0,
      mistakes: 0,
    );
    final int slowWithHints = ScoreService.pointsFor(
      difficulty: Difficulty.easy,
      wordCount: 6,
      seconds: 600,
      lettersRevealed: 3,
      wordsRevealed: 1,
      mistakes: 2,
    );
    expect(fast, greaterThan(100));
    expect(slowWithHints, lessThan(100));
    expect(
      ScoreService.pointsFor(
        difficulty: Difficulty.hard,
        wordCount: 12,
        seconds: 9999,
        lettersRevealed: 50,
        wordsRevealed: 10,
        mistakes: 50,
      ),
      10,
    );
  });

  test('stars depend on hints and mistakes', () {
    expect(
      ScoreService.starsFor(lettersRevealed: 0, wordsRevealed: 0, mistakes: 1),
      3,
    );
    expect(
      ScoreService.starsFor(lettersRevealed: 2, wordsRevealed: 0, mistakes: 0),
      2,
    );
    expect(
      ScoreService.starsFor(lettersRevealed: 0, wordsRevealed: 1, mistakes: 0),
      1,
    );
  });

  test('finishing a puzzle saves the best time and the stats', () async {
    final CrosswordEngine game = solvedSample();
    expect(game.isComplete, isTrue);

    final GameResult first = await ScoreService.record(
      topicId: 'assam_wildlife',
      difficulty: Difficulty.easy,
      engine: game,
      seconds: 50,
    );
    expect(first.isNewBest, isTrue);
    expect(first.stars, 3);
    expect(ScoreService.bestTime('assam_wildlife', Difficulty.easy), 50);

    final GameResult second = await ScoreService.record(
      topicId: 'assam_wildlife',
      difficulty: Difficulty.easy,
      engine: game,
      seconds: 70,
    );
    expect(second.isNewBest, isFalse);
    expect(second.previousBest, 50);
    expect(ScoreService.bestTime('assam_wildlife', Difficulty.easy), 50);

    expect(AppState.instance.stats.puzzlesCompleted, 2);
    expect(AppState.instance.stats.bestTimeSeconds, 50);
    expect(
      AppState.instance.stats.totalPoints,
      first.points + second.points,
    );
  });
}
