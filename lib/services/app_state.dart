import 'package:flutter/foundation.dart';

import '../data/category_data.dart';
import '../models/difficulty.dart';
import '../models/player_stats.dart';

/// Remembers the player's current choices and stats while the app is open.
/// (Saving them permanently on the device is added in Phase 6.)
class AppState extends ChangeNotifier {
  AppState._();

  static final AppState instance = AppState._();

  String? _topicId;
  Difficulty _difficulty = Difficulty.easy;
  PlayerStats _stats = const PlayerStats();

  String? get topicId => _topicId;

  Topic? get topic {
    final String? id = _topicId;
    return id == null ? null : CategoryData.findTopic(id);
  }

  Difficulty get difficulty => _difficulty;

  PlayerStats get stats => _stats;

  void selectTopic(String id) {
    _topicId = id;
    notifyListeners();
  }

  void selectDifficulty(Difficulty level) {
    _difficulty = level;
    notifyListeners();
  }

  void updateStats(PlayerStats stats) {
    _stats = stats;
    notifyListeners();
  }
}
