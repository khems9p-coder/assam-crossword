import 'difficulty.dart';

/// All of a player's numbers in one place.
/// Every screen reads from this, so when gameplay updates it later
/// (Phases 10-11) the screens fill in automatically.
class PlayerStats {
  final int gamesPlayed;
  final int puzzlesCompleted;
  final int totalPoints;
  final int level;
  final int? bestTimeSeconds;
  final int totalTimeSeconds;
  final int correctAnswers;
  final int totalAnswers;
  final int currentStreak;
  final int bestStreak;
  final int dailyCompleted;
  final Map<String, int> completedByArea;
  final Map<Difficulty, int> completedByDifficulty;
  final Set<String> unlockedAchievements;

  const PlayerStats({
    this.gamesPlayed = 0,
    this.puzzlesCompleted = 0,
    this.totalPoints = 0,
    this.level = 1,
    this.bestTimeSeconds,
    this.totalTimeSeconds = 0,
    this.correctAnswers = 0,
    this.totalAnswers = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.dailyCompleted = 0,
    this.completedByArea = const {},
    this.completedByDifficulty = const {},
    this.unlockedAchievements = const {},
  });

  int? get averageTimeSeconds =>
      puzzlesCompleted == 0 ? null : totalTimeSeconds ~/ puzzlesCompleted;

  double? get accuracy =>
      totalAnswers == 0 ? null : correctAnswers / totalAnswers;
}
