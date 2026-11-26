import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// A friendly error message to show the player.
class AuthFailure implements Exception {
  final String message;

  const AuthFailure(this.message);

  @override
  String toString() => message;
}

/// Handles accounts through Firebase Authentication.
/// Passwords go only to Firebase. This app never stores them.
class AuthService extends ChangeNotifier {
  AuthService._();

  static final AuthService instance = AuthService._();

  bool _available = false;
  User? _user;
  StreamSubscription<User?>? _subscription;

  bool get available => _available;
  User? get user => _user;
  bool get isSignedIn => _user != null;
  String get email => _user?.email ?? '';
  DateTime? get memberSince => _user?.metadata.creationTime;

  String get displayName {
    final User? current = _user;
    if (current == null) {
      return 'Guest Player';
    }
    final String? name = current.displayName;
    if (name != null && name.trim().isNotEmpty) {
      return name.trim();
    }
    return current.email ?? 'Player';
  }

  /// Called once from main() after Firebase has started.
  void start() {
    _available = true;
    final FirebaseAuth auth = FirebaseAuth.instance;
    _user = auth.currentUser;
    _subscription?.cancel();
    _subscription = auth.userChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
    notifyListeners();
  }

  FirebaseAuth _auth() {
    if (!_available) {
      throw const AuthFailure(
        'Online accounts are not available right now. Check your internet '
        'connection and restart the app.',
      );
    }
    return FirebaseAuth.instance;
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final FirebaseAuth auth = _auth();
    try {
      final UserCredential result = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await result.user?.updateDisplayName(name.trim());
      await result.user?.reload();
      _user = auth.currentUser;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_friendlyMessage(e));
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final FirebaseAuth auth = _auth();
    try {
      await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_friendlyMessage(e));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    final FirebaseAuth auth = _auth();
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_friendlyMessage(e));
    }
  }

  Future<void> signOut() async {
    if (!_available) {
      return;
    }
    await FirebaseAuth.instance.signOut();
  }

  static String _friendlyMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists with this email. Try logging in.';
      case 'invalid-email':
        return "That email address doesn't look right.";
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Email or password is incorrect.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please connect and try again.';
      case 'operation-not-allowed':
        return 'Email sign-in is not switched on for this app yet.';
      default:
        return 'Something went wrong (${e.code}). Please try again.';
    }
  }
}
