import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'category_data.dart';

/// One question: the answer, its clue, and how hard it is (1 to 3).
class BankEntry {
  final String topicId;
  final String answer;
  final String clue;
  final int level;

  const BankEntry({
    required this.topicId,
    required this.answer,
    required this.clue,
    required this.level,
  });
}

/// Loads the built-in questions from the JSON files in assets/data/.
/// To add questions, edit those files. No code changes are needed.
/// Every entry is checked; bad entries are skipped and listed in [problems].
class QuestionBank {
  QuestionBank._();

  static final QuestionBank instance = QuestionBank._();

  /// Add new question files here (and put the file in assets/data/).
  static const List<String> files = [
    'assets/data/assam_bank.json',
    'assets/data/assam_bank_2.json',
    'assets/data/assam_bank_3.json',
    'assets/data/india_bank_1.json',
    'assets/data/india_bank_2.json',
    'assets/data/india_bank_3.json',
    'assets/data/india_bank_4.json',
    'assets/data/english_bank.json',
    'assets/data/english_bank_2.json',
  ];

  static final RegExp _lettersOnly = RegExp(r'^[A-Z]+$');

  final Map<String, List<BankEntry>> _byTopic = {};
  final List<String> problems = [];
  Future<void>? _loading;
  bool _loaded = false;

  bool get isLoaded => _loaded;

  int get totalEntries =>
      _byTopic.values.fold(0, (sum, list) => sum + list.length);

  Future<void> load() => _loading ??= _loadAll();

  Future<void> _loadAll() async {
    for (final String file in files) {
      try {
        addJson(await rootBundle.loadString(file), source: file);
      } catch (error) {
        problems.add('$file: $error');
      }
    }
    _loaded = true;
    if (problems.isNotEmpty) {
      debugPrint('Question bank problems:\n${problems.join('\n')}');
    }
  }

  /// Reads one JSON file of questions.
  void addJson(String raw, {String source = 'data'}) {
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map || decoded['entries'] is! List) {
      problems.add('$source: the file needs an "entries" list');
      return;
    }
    final List<dynamic> items = decoded['entries'] as List<dynamic>;

    for (int i = 0; i < items.length; i++) {
      final Object? item = items[i];
      final String where = '$source entry ${i + 1}';
      if (item is! Map) {
        problems.add('$where: is not a valid entry');
        continue;
      }
      final Object? topic = item['topic'];
      final Object? answer = item['answer'];
      final Object? clue = item['clue'];
      final Object? level = item['level'];

      if (topic is! String || answer is! String || clue is! String) {
        problems.add('$where: needs "topic", "answer" and "clue"');
        continue;
      }
      if (CategoryData.findTopic(topic) == null) {
        problems.add('$where: unknown topic "$topic"');
        continue;
      }
      final String normalized = normalize(answer);
      if (!_lettersOnly.hasMatch(normalized) ||
          normalized.length < 3 ||
          normalized.length > 13) {
        problems.add('$where: answer "$answer" must be 3 to 13 letters');
        continue;
      }
      if (clue.trim().isEmpty) {
        problems.add('$where: the clue is empty');
        continue;
      }
      final List<BankEntry> list =
          _byTopic.putIfAbsent(topic, () => <BankEntry>[]);
      if (list.any((e) => e.answer == normalized)) {
        problems.add('$where: duplicate answer "$normalized" in $topic');
        continue;
      }
      list.add(BankEntry(
        topicId: topic,
        answer: normalized,
        clue: clue.trim(),
        level: level is int ? level.clamp(1, 3) : 2,
      ));
    }
  }

  /// "Wood Duck" becomes "WOODDUCK".
  static String normalize(String text) =>
      text.toUpperCase().replaceAll(RegExp('[^A-Z]'), '');

  List<BankEntry> entriesFor(String topicId) =>
      List<BankEntry>.unmodifiable(_byTopic[topicId] ?? const <BankEntry>[]);

  /// True when a topic has enough questions to build crosswords.
  bool hasPuzzles(String topicId) => (_byTopic[topicId]?.length ?? 0) >= 6;
}
