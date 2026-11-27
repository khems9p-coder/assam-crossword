import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'cloud_service.dart';

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

  User _requireUser() {
    final User? current = _auth().currentUser;
    if (current == null) {
      throw const AuthFailure('Please log in again.');
    }
    return current;
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

  Future<void> updateName(String name) async {
    final User current = _requireUser();
    try {
      await current.updateDisplayName(name.trim());
      await current.reload();
      _user = FirebaseAuth.instance.currentUser;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_friendlyMessage(e));
    }
  }

  /// Firebase requires the current password before sensitive changes.
  Future<void> _reauthenticate(User current, String password) async {
    final String? email = current.email;
    if (email == null) {
      throw const AuthFailure('This account has no email address.');
    }
    final AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await current.reauthenticateWithCredential(credential);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final User current = _requireUser();
    try {
      await _reauthenticate(current, currentPassword);
      await current.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_friendlyMessage(e, checkingPassword: true));
    }
  }

  /// Permanently deletes the Firebase account. The player's online data
  /// (progress and leaderboard row) is deleted first; if that fails, the
  /// account is kept so nothing is left behind.
  Future<void> deleteAccount(String currentPassword) async {
    final User current = _requireUser();
    try {
      await _reauthenticate(current, currentPassword);
      try {
        await CloudService.instance.deleteMyData(current.uid);
      } catch (_) {
        throw const AuthFailure(
          'Could not delete your online data. Check your internet '
          'connection and try again. Your account was not deleted.',
        );
      }
      await current.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_friendlyMessage(e, checkingPassword: true));
    }
  }

  static String _friendlyMessage(
    FirebaseAuthException e, {
    bool checkingPassword = false,
  }) {
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
        return checkingPassword
            ? 'Your current password is incorrect.'
            : 'Email or password is incorrect.';
      case 'requires-recent-login':
        return 'For your security, please log out, log in again, and retry.';
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
