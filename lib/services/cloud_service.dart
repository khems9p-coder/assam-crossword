import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/difficulty.dart';
import '../models/player_stats.dart';
import 'app_state.dart';
import 'auth_service.dart';

/// One row of the leaderboard.
class LeaderEntry {
  final String uid;
  final String name;
  final int points;
  final int puzzles;
  final int level;
  final Map<Difficulty, int> byDifficulty;

  const LeaderEntry({
    required this.uid,
    required this.name,
    required this.points,
    required this.puzzles,
    required this.level,
    required this.byDifficulty,
  });

  /// The number used for ranking: points for "All", otherwise the number
  /// of puzzles finished at that difficulty.
  int valueFor(Difficulty? filter) =>
      filter == null ? points : (byDifficulty[filter] ?? 0);

  factory LeaderEntry.fromMap(String uid, Map<String, dynamic> data) {
    int readInt(String key) {
      final Object? value = data[key];
      return value is num ? value.toInt() : 0;
    }

    final Object? name = data['name'];
    return LeaderEntry(
      uid: uid,
      name: name is String && name.trim().isNotEmpty ? name : 'Player',
      points: readInt('points'),
      puzzles: readInt('puzzles'),
      level: readInt('level'),
      byDifficulty: {
        for (final Difficulty d in Difficulty.values) d: readInt(d.name),
      },
    );
  }
}

/// Saves signed-in players' progress to Cloud Firestore and reads the
/// leaderboard. Guests and offline players keep playing on the device;
/// nothing here ever stops the game.
///
/// users/{uid}        - the player's full stats (only they can read it)
/// leaderboard/{uid}  - name and scores shown to everyone
class CloudService {
  CloudService._();

  static final CloudService instance = CloudService._();

  String? _syncedUid;

  bool get _ready =>
      AuthService.instance.available && AuthService.instance.isSignedIn;

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// Called once from main(), after AuthService.start().
  void start() {
    AuthService.instance.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  void _onAuthChanged() {
    final String? uid = AuthService.instance.user?.uid;
    if (uid == null) {
      _syncedUid = null;
      return;
    }
    if (uid != _syncedUid) {
      _syncedUid = uid;
      unawaited(syncNow());
    } else {
      // Same player, e.g. after a name change: upload the latest.
      unawaited(push());
    }
  }

  /// Joins the cloud copy with this device's progress, keeping the best
  /// of both, then saves the result in both places.
  Future<void> syncNow() async {
    if (!_ready) {
      return;
    }
    final String uid = AuthService.instance.user!.uid;
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc =
          await _db.collection('users').doc(uid).get();
      final Object? cloud = doc.data()?['stats'];
      if (cloud is Map) {
        final PlayerStats merged = PlayerStats.merge(
          AppState.instance.stats,
          PlayerStats.fromJson(Map<String, dynamic>.from(cloud)),
        );
        AppState.instance.updateStats(merged);
      }
      await push();
    } catch (error) {
      debugPrint('Cloud sync skipped: $error');
    }
  }

  /// Uploads this device's progress for the signed-in player.
  Future<void> push() async {
    if (!_ready) {
      return;
    }
    final String uid = AuthService.instance.user!.uid;
    final PlayerStats stats = AppState.instance.stats;
    final String name = AuthService.instance.displayName;
    try {
      await _db.collection('users').doc(uid).set({
        'name': name,
        'stats': stats.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _db.collection('leaderboard').doc(uid).set({
        'name': name.length > 40 ? name.substring(0, 40) : name,
        'points': stats.totalPoints,
        'puzzles': stats.puzzlesCompleted,
        'level': stats.level,
        for (final Difficulty d in Difficulty.values)
          d.name: stats.completedByDifficulty[d] ?? 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      debugPrint('Cloud save skipped: $error');
    }
  }

  /// Top 50 players: by points, or by puzzles finished at a difficulty.
  /// Returns an empty list if online features are not available.
  Future<List<LeaderEntry>> top(Difficulty? filter) async {
    if (!AuthService.instance.available) {
      return const [];
    }
    final String field = filter == null ? 'points' : filter.name;
    final QuerySnapshot<Map<String, dynamic>> result = await _db
        .collection('leaderboard')
        .orderBy(field, descending: true)
        .limit(50)
        .get();
    return [
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in result.docs)
        LeaderEntry.fromMap(doc.id, doc.data()),
    ].where((LeaderEntry e) => e.valueFor(filter) > 0).toList();
  }

  /// Removes the player's online data. Used before deleting an account.
  Future<void> deleteMyData(String uid) async {
    await _db.collection('leaderboard').doc(uid).delete();
    await _db.collection('users').doc(uid).delete();
  }
}
