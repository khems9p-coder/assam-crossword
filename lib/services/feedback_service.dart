import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../utils/constants.dart';
import 'auth_service.dart';
import 'connectivity_service.dart';
import 'local_store.dart';

/// What happened to a piece of feedback.
enum FeedbackOutcome { sent, queued }

/// Sends feedback to the developer through Cloud Firestore.
///
/// Every message is first saved on the device. It is then sent at once
/// if possible; if the device is offline, it waits and is sent
/// automatically when the connection comes back (or when the app opens
/// next time). Each message has its own ID, so it is never stored twice.
class FeedbackService {
  FeedbackService._();

  static final FeedbackService instance = FeedbackService._();

  bool _flushing = false;

  /// Called once from main(), after Firebase has started.
  void start() {
    ConnectivityService.instance.addListener(() {
      if (ConnectivityService.instance.isOnline) {
        unawaited(flush());
      }
    });
    unawaited(flush());
  }

  /// Messages saved on this device and not yet delivered.
  List<Map<String, dynamic>> get pending {
    final Object? list =
        LocalStore.instance.readJson(LocalStore.keyFeedback)?['items'];
    if (list is! List) {
      return [];
    }
    return [
      for (final Object? item in list)
        if (item is Map) Map<String, dynamic>.from(item),
    ];
  }

  Future<void> _savePending(List<Map<String, dynamic>> items) async {
    await LocalStore.instance
        .writeJson(LocalStore.keyFeedback, {'items': items});
  }

  static String _newId() {
    final Random random = Random();
    final String time = DateTime.now().millisecondsSinceEpoch.toString();
    final String extra = List<String>.generate(
      8,
      (_) => random.nextInt(36).toRadixString(36),
    ).join();
    return '$time-$extra';
  }

  /// Keeps text within the limits the server accepts.
  static String _cut(String text, int max) =>
      text.length <= max ? text : text.substring(0, max);

  /// Saves the message, then tries to send it.
  Future<FeedbackOutcome> submit({
    required String name,
    required String email,
    required String category,
    required String message,
  }) async {
    final Map<String, dynamic> item = {
      'id': _newId(),
      'name': _cut(name.trim(), 100),
      'email': _cut(email.trim(), 200),
      'category': _cut(category, 50),
      'message': _cut(message.trim(), 2000),
      'appVersion': AppConstants.appVersion,
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
      'uid': AuthService.instance.user?.uid,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };
    await _savePending([...pending, item]);
    await flush();
    final bool stillWaiting =
        pending.any((Map<String, dynamic> p) => p['id'] == item['id']);
    return stillWaiting ? FeedbackOutcome.queued : FeedbackOutcome.sent;
  }

  /// Tries to deliver every waiting message. Stops at the first one that
  /// cannot be sent (for example, no internet) and tries again later.
  Future<void> flush() async {
    if (_flushing ||
        !AuthService.instance.available ||
        !ConnectivityService.instance.isOnline) {
      return;
    }
    _flushing = true;
    try {
      for (final Map<String, dynamic> item in pending) {
        final String id = item['id'] as String;
        try {
          await FirebaseFirestore.instance
              .collection('feedback')
              .doc(id)
              .set({
                for (final MapEntry<String, dynamic> e in item.entries)
                  if (e.key != 'id') e.key: e.value,
                'receivedAt': FieldValue.serverTimestamp(),
              })
              .timeout(const Duration(seconds: 15));
        } catch (_) {
          break; // Offline or too slow: try again later.
        }
        await _savePending([
          for (final Map<String, dynamic> p in pending)
            if (p['id'] != id) p,
        ]);
      }
    } finally {
      _flushing = false;
    }
  }
}
