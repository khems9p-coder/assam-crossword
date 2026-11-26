import 'package:flutter/foundation.dart';

import '../data/category_data.dart';
import '../models/difficulty.dart';
import '../models/player_stats.dart';

/// Remembers the player's choices, stats and settings while the app is open.
/// (Saving them permanently on the device is added in Phase 6.)
class AppState extends ChangeNotifier {
  AppState._();

  static final AppState instance = AppState._();

  // ---- Game choices ----
  String? _topicId;
  Difficulty _difficulty = Difficulty.easy;

  String? get topicId => _topicId;

  Topic? get topic {
    final String? id = _topicId;
    return id == null ? null : CategoryData.findTopic(id);
  }

  Difficulty get difficulty => _difficulty;

  void selectTopic(String id) {
    _topicId = id;
    notifyListeners();
  }

  void selectDifficulty(Difficulty level) {
    _difficulty = level;
    notifyListeners();
  }

  // ---- Player stats ----
  PlayerStats _stats = const PlayerStats();

  PlayerStats get stats => _stats;

  void updateStats(PlayerStats stats) {
    _stats = stats;
    notifyListeners();
  }

  // ---- Settings ----
  bool _soundOn = true;
  bool _musicOn = false;
  bool _vibrationOn = true;
  double _textScale = 1.0;

  bool get soundOn => _soundOn;
  bool get musicOn => _musicOn;
  bool get vibrationOn => _vibrationOn;
  double get textScale => _textScale;

  void setSoundOn(bool value) {
    _soundOn = value;
    notifyListeners();
  }

  void setMusicOn(bool value) {
    _musicOn = value;
    notifyListeners();
  }

  void setVibrationOn(bool value) {
    _vibrationOn = value;
    notifyListeners();
  }

  void setTextScale(double value) {
    _textScale = value;
    notifyListeners();
  }
}
