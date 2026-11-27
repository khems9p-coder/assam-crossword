import '../data/category_data.dart';
import '../data/question_bank.dart';
import '../game/puzzle_generator.dart';
import '../models/crossword.dart';
import '../models/difficulty.dart';
import '../models/player_stats.dart';
import 'app_state.dart';
import 'local_store.dart';

/// The Daily Challenge: one Medium puzzle per day, the same for every
/// player, on a topic that changes each day. Finishing it on
/// consecutive days builds the daily streak.
class DailyService {
  DailyService._();

  static const Difficulty difficulty = Difficulty.medium;

  /// Today's date on this device (local time), without the clock time.
  static DateTime today() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Example: 2026-11-27
  static String dateKey(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  /// 1 for 1 January 2026, 2 for the next day, and so on.
  static int dayNumber(DateTime day) =>
      DateTime.utc(day.year, day.month, day.day)
          .difference(DateTime.utc(2026, 1, 1))
          .inDays +
      1;

  static List<Topic> get _allTopics => [
        for (final SubjectArea area in CategoryData.areas) ...area.topics,
      ];

  /// The topic of the day. Consecutive days get different topics.
  static Topic topicFor(DateTime day) {
    final List<Topic> topics = _allTopics;
    final int index = (dayNumber(day) * 11) % topics.length;
    return topics[index < 0 ? index + topics.length : index];
  }

  /// Builds the puzzle for a day. Needs the question bank to be loaded.
  static CrosswordPuzzle? build(DateTime day) {
    final Topic topic = topicFor(day);
    int seed = 23;
    for (final int unit in dateKey(day).codeUnits) {
      seed = (seed * 31 + unit) & 0x7fffffff;
    }
    return PuzzleGenerator.generate(
      id: 'daily_${dateKey(day)}',
      title: 'Daily · ${topic.name}',
      topicId: topic.id,
      difficulty: difficulty,
      entries: QuestionBank.instance.entriesFor(topic.id),
      seed: seed,
      number: dayNumber(day),
    );
  }

  /// Dates on which the Daily Challenge was finished.
  static Set<String> completedDates() {
    final Object? list =
        LocalStore.instance.readJson(LocalStore.keyDaily)?['dates'];
    return list is List ? list.whereType<String>().toSet() : <String>{};
  }

  static bool isDone(DateTime day) => completedDates().contains(dateKey(day));

  /// Days in a row the challenge was finished, counting back from today
  /// (or from yesterday, if today's is not done yet).
  static int streak(Set<String> dates, DateTime today) {
    DateTime day = today;
    if (!dates.contains(dateKey(day))) {
      day = day.subtract(const Duration(days: 1));
    }
    int count = 0;
    while (dates.contains(dateKey(day))) {
      count++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return count;
  }

  static int currentStreak() => streak(completedDates(), today());

  /// Saves that [day]'s challenge is finished. Returns false if it was
  /// already finished before (a replay).
  static Future<bool> markDone(DateTime day) async {
    final Set<String> dates = completedDates();
    if (!dates.add(dateKey(day))) {
      return false;
    }
    final List<String> sorted = dates.toList()..sort();
    // Keep the last 400 days; that is plenty for streaks.
    final List<String> kept =
        sorted.length > 400 ? sorted.sublist(sorted.length - 400) : sorted;
    await LocalStore.instance.writeJson(LocalStore.keyDaily, {'dates': kept});
    return true;
  }

  /// If days were missed, the saved streak drops back to the real one.
  /// Called once when the app starts.
  static void refreshStreak() {
    final PlayerStats stats = AppState.instance.stats;
    final int actual = currentStreak();
    if (actual != stats.currentStreak) {
      AppState.instance.updateStats(stats.copyWith(currentStreak: actual));
    }
  }
}
