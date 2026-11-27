import '../data/category_data.dart';
import '../data/question_bank.dart';
import '../game/puzzle_generator.dart';
import '../models/crossword.dart';
import '../models/difficulty.dart';
import 'local_store.dart';

/// Picks the crossword for a topic and difficulty and remembers which
/// puzzle number the player has reached (saved on the device).
class PuzzleService {
  PuzzleService._();

  static String _key(String topicId, Difficulty difficulty) =>
      '$topicId:${difficulty.name}';

  static int currentNumber(String topicId, Difficulty difficulty) {
    final Object? value = LocalStore.instance
        .readJson(LocalStore.keyPuzzles)?[_key(topicId, difficulty)];
    return value is int && value > 0 ? value : 1;
  }

  /// Moves on to the next puzzle after the current one is finished.
  static Future<void> markCompleted(
    String topicId,
    Difficulty difficulty,
    int number,
  ) async {
    if (number != currentNumber(topicId, difficulty)) {
      return;
    }
    final Map<String, dynamic> data = Map<String, dynamic>.from(
      LocalStore.instance.readJson(LocalStore.keyPuzzles) ??
          const <String, dynamic>{},
    );
    data[_key(topicId, difficulty)] = number + 1;
    await LocalStore.instance.writeJson(LocalStore.keyPuzzles, data);
  }

  static CrosswordPuzzle? build(
    String topicId,
    Difficulty difficulty,
    int number,
  ) {
    final Topic? topic = CategoryData.findTopic(topicId);
    return PuzzleGenerator.generate(
      id: '${topicId}_${difficulty.name}_$number',
      title: '${topic?.name ?? 'Crossword'} #$number',
      topicId: topicId,
      difficulty: difficulty,
      entries: QuestionBank.instance.entriesFor(topicId),
      seed: _seed(topicId, difficulty, number),
    );
  }

  /// A fixed number made from the topic name, so puzzles are the same on
  /// every device.
  static int _seed(String topicId, Difficulty difficulty, int number) {
    int hash = 17;
    for (final int unit in topicId.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return (hash + difficulty.index * 100003 + number * 7919) & 0x7fffffff;
  }
}
