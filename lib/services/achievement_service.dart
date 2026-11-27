import '../models/achievement.dart';
import '../models/difficulty.dart';
import '../models/player_stats.dart';

/// Decides which achievements a player has earned.
class AchievementService {
  AchievementService._();

  /// IDs of every achievement these stats (and this game) qualify for.
  static Set<String> earned(
    PlayerStats stats, {
    bool perfectGame = false,
    bool speedyGame = false,
  }) {
    int topic(String id) => stats.completedByTopic[id] ?? 0;
    int area(String id) => stats.completedByArea[id] ?? 0;

    return {
      if (stats.puzzlesCompleted >= 1) 'first_puzzle',
      if (perfectGame) 'first_perfect',
      if (area('english') >= 5) 'vocab_beginner',
      if (topic('assam_geography') + topic('india_geography') >= 10)
        'geography_explorer',
      if (topic('assam_history') >= 10) 'assam_history_expert',
      if (area('india') >= 25) 'india_gk_champion',
      if (speedyGame) 'speed_solver',
      if (stats.puzzlesCompleted >= 10) 'puzzles_10',
      if (stats.puzzlesCompleted >= 50) 'puzzles_50',
      if (stats.puzzlesCompleted >= 100) 'puzzles_100',
      if (stats.currentStreak >= 7) 'daily_master',
    };
  }

  /// Achievements in [earnedIds] that the player did not have before.
  static List<Achievement> newOnes(Set<String> before, Set<String> earnedIds) {
    return [
      for (final Achievement a in Achievement.all)
        if (earnedIds.contains(a.id) && !before.contains(a.id)) a,
    ];
  }

  /// Speed Solver: a Medium or Hard puzzle in under 5 minutes, no word
  /// revealed.
  static bool isSpeedy(Difficulty difficulty, int seconds, int wordsRevealed) =>
      difficulty != Difficulty.easy && seconds < 300 && wordsRevealed == 0;
}
