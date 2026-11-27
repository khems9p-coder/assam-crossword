import '../data/category_data.dart';
import '../game/crossword_engine.dart';
import '../models/achievement.dart';
import '../models/difficulty.dart';
import '../models/player_stats.dart';
import 'achievement_service.dart';
import 'app_state.dart';
import 'daily_service.dart';
import 'local_store.dart';

/// What the player earned for one finished puzzle.
class GameResult {
  final int seconds;
  final int points;
  final int stars;
  final bool countsForBestTime;
  final bool isNewBest;
  final int? previousBest;
  final bool isDaily;
  final int? dailyStreak;
  final List<Achievement> newAchievements;

  const GameResult({
    required this.seconds,
    required this.points,
    required this.stars,
    required this.countsForBestTime,
    required this.isNewBest,
    required this.previousBest,
    this.isDaily = false,
    this.dailyStreak,
    this.newAchievements = const [],
  });
}

/// Works out points and stars, saves best times, updates the player's
/// stats and unlocks achievements when a puzzle is finished.
class ScoreService {
  ScoreService._();

  /// Extra points for finishing the Daily Challenge (first time each day).
  static const int dailyBonus = 50;

  static int basePoints(Difficulty difficulty) => switch (difficulty) {
        Difficulty.easy => 100,
        Difficulty.medium => 200,
        Difficulty.hard => 300,
      };

  /// Points: the base for the difficulty, plus up to half again for
  /// speed, minus penalties for hints and mistakes. Never less than 10.
  static int pointsFor({
    required Difficulty difficulty,
    required int wordCount,
    required int seconds,
    required int lettersRevealed,
    required int wordsRevealed,
    required int mistakes,
  }) {
    final int base = basePoints(difficulty);
    final int target = wordCount * 30;
    final int saved = (target - seconds).clamp(0, target);
    final int speedBonus = target == 0 ? 0 : (base * saved) ~/ (target * 2);
    final int total = base +
        speedBonus -
        lettersRevealed * 10 -
        wordsRevealed * 30 -
        mistakes * 5;
    return total < 10 ? 10 : total;
  }

  /// 3 stars: no hints and at most 2 mistakes.
  /// 2 stars: no whole word revealed and at most 2 letters revealed.
  /// 1 star: finished.
  static int starsFor({
    required int lettersRevealed,
    required int wordsRevealed,
    required int mistakes,
  }) {
    if (lettersRevealed == 0 && wordsRevealed == 0 && mistakes <= 2) {
      return 3;
    }
    if (wordsRevealed == 0 && lettersRevealed <= 2) {
      return 2;
    }
    return 1;
  }

  static String _key(String topicId, Difficulty difficulty) =>
      '$topicId:${difficulty.name}';

  /// Best time for a topic and difficulty, or null if none yet.
  static int? bestTime(String topicId, Difficulty difficulty) {
    final Object? value = LocalStore.instance
        .readJson(LocalStore.keyBestTimes)?[_key(topicId, difficulty)];
    return value is int ? value : null;
  }

  /// Saves everything about a finished puzzle and returns the result.
  /// A time only counts as a best time if no whole word was revealed.
  static Future<GameResult> record({
    required String topicId,
    required Difficulty difficulty,
    required CrosswordEngine engine,
    required int seconds,
    bool isDaily = false,
  }) async {
    final int lettersRevealed = engine.lettersRevealed;
    final int wordsRevealed = engine.wordsRevealed;
    final int mistakes = engine.incorrectAttempts;

    // Daily Challenge: only the first finish of the day counts for the
    // streak and the bonus.
    bool firstDailyFinish = false;
    if (isDaily) {
      firstDailyFinish = await DailyService.markDone(DailyService.today());
    }

    int points = pointsFor(
      difficulty: difficulty,
      wordCount: engine.puzzle.words.length,
      seconds: seconds,
      lettersRevealed: lettersRevealed,
      wordsRevealed: wordsRevealed,
      mistakes: mistakes,
    );
    if (firstDailyFinish) {
      points += dailyBonus;
    }
    final int stars = starsFor(
      lettersRevealed: lettersRevealed,
      wordsRevealed: wordsRevealed,
      mistakes: mistakes,
    );

    final bool counts = wordsRevealed == 0;
    final int? previous = isDaily ? null : bestTime(topicId, difficulty);
    final bool isNewBest =
        !isDaily && counts && (previous == null || seconds < previous);
    if (isNewBest) {
      final Map<String, dynamic> times = Map<String, dynamic>.from(
        LocalStore.instance.readJson(LocalStore.keyBestTimes) ??
            const <String, dynamic>{},
      );
      times[_key(topicId, difficulty)] = seconds;
      await LocalStore.instance.writeJson(LocalStore.keyBestTimes, times);
    }

    final PlayerStats old = AppState.instance.stats;
    PlayerStats updated = _updatedStats(
      old: old,
      topicId: topicId,
      difficulty: difficulty,
      engine: engine,
      seconds: seconds,
      points: points,
      countsForBestTime: counts,
    );

    int? dailyStreak;
    if (isDaily) {
      dailyStreak = DailyService.currentStreak();
      updated = updated.copyWith(
        currentStreak: dailyStreak,
        bestStreak:
            dailyStreak > updated.bestStreak ? dailyStreak : updated.bestStreak,
        dailyCompleted: updated.dailyCompleted + (firstDailyFinish ? 1 : 0),
      );
    }

    final Set<String> earned = AchievementService.earned(
      updated,
      perfectGame: mistakes == 0 && lettersRevealed == 0 && wordsRevealed == 0,
      speedyGame:
          AchievementService.isSpeedy(difficulty, seconds, wordsRevealed),
    );
    final List<Achievement> fresh =
        AchievementService.newOnes(old.unlockedAchievements, earned);
    if (fresh.isNotEmpty) {
      updated = updated.copyWith(
        unlockedAchievements: {
          ...old.unlockedAchievements,
          for (final Achievement a in fresh) a.id,
        },
      );
    }
    AppState.instance.updateStats(updated);

    return GameResult(
      seconds: seconds,
      points: points,
      stars: stars,
      countsForBestTime: counts,
      isNewBest: isNewBest,
      previousBest: previous,
      isDaily: isDaily,
      dailyStreak: dailyStreak,
      newAchievements: fresh,
    );
  }

  static String? _areaOf(String topicId) {
    for (final SubjectArea area in CategoryData.areas) {
      for (final Topic topic in area.topics) {
        if (topic.id == topicId) {
          return area.id;
        }
      }
    }
    return null;
  }

  static PlayerStats _updatedStats({
    required PlayerStats old,
    required String topicId,
    required Difficulty difficulty,
    required CrosswordEngine engine,
    required int seconds,
    required int points,
    required bool countsForBestTime,
  }) {
    final int totalPoints = old.totalPoints + points;

    final int? oldBest = old.bestTimeSeconds;
    int? best = oldBest;
    if (countsForBestTime && (oldBest == null || seconds < oldBest)) {
      best = seconds;
    }

    final Map<String, int> byArea = Map<String, int>.of(old.completedByArea);
    final String? area = _areaOf(topicId);
    if (area != null) {
      byArea[area] = (byArea[area] ?? 0) + 1;
    }
    final Map<String, int> byTopic = Map<String, int>.of(old.completedByTopic);
    byTopic[topicId] = (byTopic[topicId] ?? 0) + 1;
    final Map<Difficulty, int> byDifficulty =
        Map<Difficulty, int>.of(old.completedByDifficulty);
    byDifficulty[difficulty] = (byDifficulty[difficulty] ?? 0) + 1;

    // Words solved without revealing them count as correct answers.
    final int words = engine.puzzle.words.length;
    final int correct = (words - engine.wordsRevealed).clamp(0, words);

    return old.copyWith(
      gamesPlayed: old.gamesPlayed + 1,
      puzzlesCompleted: old.puzzlesCompleted + 1,
      totalPoints: totalPoints,
      level: 1 + totalPoints ~/ 500,
      bestTimeSeconds: best,
      totalTimeSeconds: old.totalTimeSeconds + seconds,
      correctAnswers: old.correctAnswers + correct,
      totalAnswers: old.totalAnswers + words,
      completedByArea: byArea,
      completedByTopic: byTopic,
      completedByDifficulty: byDifficulty,
    );
  }
}
