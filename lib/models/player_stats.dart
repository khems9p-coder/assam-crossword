import 'difficulty.dart';

/// All of a player's numbers in one place.
/// Every screen reads from this, so when gameplay updates it the screens
/// fill in automatically.
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
  final Map<String, int> completedByTopic;
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
    this.completedByTopic = const {},
    this.completedByDifficulty = const {},
    this.unlockedAchievements = const {},
  });

  int? get averageTimeSeconds =>
      puzzlesCompleted == 0 ? null : totalTimeSeconds ~/ puzzlesCompleted;

  double? get accuracy =>
      totalAnswers == 0 ? null : correctAnswers / totalAnswers;

  /// A copy with some numbers changed.
  PlayerStats copyWith({
    int? gamesPlayed,
    int? puzzlesCompleted,
    int? totalPoints,
    int? level,
    int? bestTimeSeconds,
    int? totalTimeSeconds,
    int? correctAnswers,
    int? totalAnswers,
    int? currentStreak,
    int? bestStreak,
    int? dailyCompleted,
    Map<String, int>? completedByArea,
    Map<String, int>? completedByTopic,
    Map<Difficulty, int>? completedByDifficulty,
    Set<String>? unlockedAchievements,
  }) {
    return PlayerStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      puzzlesCompleted: puzzlesCompleted ?? this.puzzlesCompleted,
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
      bestTimeSeconds: bestTimeSeconds ?? this.bestTimeSeconds,
      totalTimeSeconds: totalTimeSeconds ?? this.totalTimeSeconds,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalAnswers: totalAnswers ?? this.totalAnswers,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      dailyCompleted: dailyCompleted ?? this.dailyCompleted,
      completedByArea: completedByArea ?? this.completedByArea,
      completedByTopic: completedByTopic ?? this.completedByTopic,
      completedByDifficulty:
          completedByDifficulty ?? this.completedByDifficulty,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gamesPlayed': gamesPlayed,
      'puzzlesCompleted': puzzlesCompleted,
      'totalPoints': totalPoints,
      'level': level,
      'bestTimeSeconds': bestTimeSeconds,
      'totalTimeSeconds': totalTimeSeconds,
      'correctAnswers': correctAnswers,
      'totalAnswers': totalAnswers,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'dailyCompleted': dailyCompleted,
      'completedByArea': completedByArea,
      'completedByTopic': completedByTopic,
      'completedByDifficulty': {
        for (final MapEntry<Difficulty, int> entry
            in completedByDifficulty.entries)
          entry.key.name: entry.value,
      },
      'unlockedAchievements': unlockedAchievements.toList(),
    };
  }

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    int readInt(String key, [int fallback = 0]) {
      final Object? value = json[key];
      return value is int ? value : fallback;
    }

    Map<String, int> readIntMap(Object? raw) {
      final Map<String, int> result = {};
      if (raw is Map) {
        raw.forEach((key, value) {
          if (key is String && value is int) {
            result[key] = value;
          }
        });
      }
      return result;
    }

    final Map<Difficulty, int> byDifficulty = {};
    readIntMap(json['completedByDifficulty']).forEach((key, value) {
      for (final Difficulty level in Difficulty.values) {
        if (level.name == key) {
          byDifficulty[level] = value;
        }
      }
    });

    final Object? best = json['bestTimeSeconds'];
    final Object? achievements = json['unlockedAchievements'];

    return PlayerStats(
      gamesPlayed: readInt('gamesPlayed'),
      puzzlesCompleted: readInt('puzzlesCompleted'),
      totalPoints: readInt('totalPoints'),
      level: readInt('level', 1),
      bestTimeSeconds: best is int ? best : null,
      totalTimeSeconds: readInt('totalTimeSeconds'),
      correctAnswers: readInt('correctAnswers'),
      totalAnswers: readInt('totalAnswers'),
      currentStreak: readInt('currentStreak'),
      bestStreak: readInt('bestStreak'),
      dailyCompleted: readInt('dailyCompleted'),
      completedByArea: readIntMap(json['completedByArea']),
      completedByTopic: readIntMap(json['completedByTopic']),
      completedByDifficulty: byDifficulty,
      unlockedAchievements: achievements is List
          ? achievements.whereType<String>().toSet()
          : const {},
    );
  }
}
