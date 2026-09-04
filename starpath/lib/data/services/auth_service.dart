import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';

/// Authentication service wrapping FirebaseAuth with graceful offline/demo fallback
class AuthService {
  final fb_auth.FirebaseAuth? _firebaseAuth;

  AuthService({fb_auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth;

  /// Current user UID
  String? get currentUid => _firebaseAuth?.currentUser?.uid;

  /// Auth state changes stream
  Stream<String?> authStateChanges() {
    if (_firebaseAuth == null) {
      // Offline fallback: stream of null or current state
      return Stream.value(currentUid);
    }
    return _firebaseAuth.authStateChanges().map((user) => user?.uid);
  }

  /// Sign in with email and password
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (_firebaseAuth == null) {
      debugPrint('AuthService: Firebase not initialized. Mocking sign in for: $email');
      return 'demo_uid_${email.hashCode}';
    }

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        throw Exception('User UID is null after login');
      }
      return uid;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Authentication failed (${e.code})');
    }
  }

  /// Create a new account with email and password
  Future<String> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (_firebaseAuth == null) {
      debugPrint('AuthService: Firebase not initialized. Mocking signup for: $email');
      return 'demo_uid_${email.hashCode}';
    }

    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        throw Exception('User UID is null after account creation');
      }
      return uid;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Account creation failed (${e.code})');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (_firebaseAuth != null) {
      await _firebaseAuth.signOut();
    }
  }
}
