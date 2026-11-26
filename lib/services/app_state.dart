import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/category_data.dart';
import '../models/difficulty.dart';
import '../models/player_stats.dart';
import 'local_store.dart';

/// The player's choices, stats and settings.
/// Every change is saved on the device straight away, so nothing is lost
/// when the app closes, even without internet.
class AppState extends ChangeNotifier {
  AppState._();

  static final AppState instance = AppState._();

  String? _topicId;
  Difficulty _difficulty = Difficulty.easy;
  PlayerStats _stats = const PlayerStats();
  bool _soundOn = true;
  bool _musicOn = false;
  bool _vibrationOn = true;
  double _textScale = 1.0;

  // ---- Getters ----
  String? get topicId => _topicId;

  Topic? get topic {
    final String? id = _topicId;
    return id == null ? null : CategoryData.findTopic(id);
  }

  Difficulty get difficulty => _difficulty;
  PlayerStats get stats => _stats;
  bool get soundOn => _soundOn;
  bool get musicOn => _musicOn;
  bool get vibrationOn => _vibrationOn;
  double get textScale => _textScale;

  // ---- Loading ----
  Future<void> loadFromDevice() async {
    final LocalStore store = LocalStore.instance;

    final Map<String, dynamic>? settings =
        store.readJson(LocalStore.keySettings);
    if (settings != null) {
      _soundOn = _readBool(settings['soundOn'], _soundOn);
      _musicOn = _readBool(settings['musicOn'], _musicOn);
      _vibrationOn = _readBool(settings['vibrationOn'], _vibrationOn);
      final Object? scale = settings['textScale'];
      if (scale is num) {
        _textScale = scale.toDouble();
      }
    }

    final Map<String, dynamic>? selection =
        store.readJson(LocalStore.keySelection);
    if (selection != null) {
      final Object? id = selection['topicId'];
      _topicId =
          (id is String && CategoryData.findTopic(id) != null) ? id : null;
      final Object? level = selection['difficulty'];
      for (final Difficulty d in Difficulty.values) {
        if (d.name == level) {
          _difficulty = d;
        }
      }
    }

    final Map<String, dynamic>? stats = store.readJson(LocalStore.keyStats);
    if (stats != null) {
      _stats = PlayerStats.fromJson(stats);
    }

    notifyListeners();
  }

  static bool _readBool(Object? value, bool fallback) {
    return value is bool ? value : fallback;
  }

  // ---- Game choices ----
  void selectTopic(String id) {
    _topicId = id;
    _saveSelection();
    notifyListeners();
  }

  void selectDifficulty(Difficulty level) {
    _difficulty = level;
    _saveSelection();
    notifyListeners();
  }

  // ---- Stats ----
  void updateStats(PlayerStats stats) {
    _stats = stats;
    _saveStats();
    notifyListeners();
  }

  // ---- Settings ----
  void setSoundOn(bool value) {
    _soundOn = value;
    _saveSettings();
    notifyListeners();
  }

  void setMusicOn(bool value) {
    _musicOn = value;
    _saveSettings();
    notifyListeners();
  }

  void setVibrationOn(bool value) {
    _vibrationOn = value;
    _saveSettings();
    notifyListeners();
  }

  void setTextScale(double value) {
    _textScale = value;
    _saveSettings();
    notifyListeners();
  }

  // ---- Clear everything saved on this device ----
  Future<void> resetLocalData() async {
    await LocalStore.instance.clearAll();
    _topicId = null;
    _difficulty = Difficulty.easy;
    _stats = const PlayerStats();
    _soundOn = true;
    _musicOn = false;
    _vibrationOn = true;
    _textScale = 1.0;
    notifyListeners();
  }

  // ---- Saving ----
  void _saveSelection() {
    unawaited(LocalStore.instance.writeJson(LocalStore.keySelection, {
      'topicId': _topicId,
      'difficulty': _difficulty.name,
    }));
  }

  void _saveStats() {
    unawaited(
      LocalStore.instance.writeJson(LocalStore.keyStats, _stats.toJson()),
    );
  }

  void _saveSettings() {
    unawaited(LocalStore.instance.writeJson(LocalStore.keySettings, {
      'soundOn': _soundOn,
      'musicOn': _musicOn,
      'vibrationOn': _vibrationOn,
      'textScale': _textScale,
    }));
  }
}
