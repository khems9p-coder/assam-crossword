import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Saves small pieces of app data on the device (works offline).
/// Android: the app's private storage. Web preview: browser storage.
class LocalStore {
  LocalStore._();

  static final LocalStore instance = LocalStore._();

  static const String keySettings = 'settings_v1';
  static const String keySelection = 'selection_v1';
  static const String keyStats = 'stats_v1';
  static const String keyPuzzles = 'puzzles_v1';
  static const String keyBestTimes = 'best_times_v1';

  static const List<String> _allKeys = [
    keySettings,
    keySelection,
    keyStats,
    keyPuzzles,
    keyBestTimes,
  ];

  SharedPreferences? _prefs;

  bool get ready => _prefs != null;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Map<String, dynamic>? readJson(String key) {
    final String? raw = _prefs?.getString(key);
    if (raw == null) {
      return null;
    }
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Damaged data is ignored; the app falls back to defaults.
    }
    return null;
  }

  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    final SharedPreferences? prefs = _prefs;
    if (prefs == null) {
      return;
    }
    await prefs.setString(key, jsonEncode(value));
  }

  /// Removes only this app's saved game data from the device.
  Future<void> clearAll() async {
    final SharedPreferences? prefs = _prefs;
    if (prefs == null) {
      return;
    }
    for (final String key in _allKeys) {
      await prefs.remove(key);
    }
  }
}
