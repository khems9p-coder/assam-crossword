import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Tells the app whether the device currently has a network connection.
class ConnectivityService extends ChangeNotifier {
  ConnectivityService._();

  static final ConnectivityService instance = ConnectivityService._();

  bool _online = true;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool get isOnline => _online;

  Future<void> start() async {
    final Connectivity connectivity = Connectivity();
    try {
      _update(await connectivity.checkConnectivity());
    } catch (_) {
      // If the check fails, assume online and keep going.
    }
    await _subscription?.cancel();
    _subscription = connectivity.onConnectivityChanged.listen(_update);
  }

  void _update(List<ConnectivityResult> results) {
    final bool online = results.any((r) => r != ConnectivityResult.none);
    if (online != _online) {
      _online = online;
      notifyListeners();
    }
  }
}
