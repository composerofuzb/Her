import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';

/// Authentication service wrapping FirebaseAuth with graceful offline/demo fallback
class AuthService {
  final fb_auth.FirebaseAuth? _firebaseAuth;
  String? _mockUid;
  final StreamController<String?> _mockAuthController =
      StreamController<String?>.broadcast();

  AuthService({fb_auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth;

  /// Current user UID
  String? get currentUid => _mockUid ?? _firebaseAuth?.currentUser?.uid;

  /// Auth state changes stream
  Stream<String?> authStateChanges() {
    if (_firebaseAuth == null) {
      return _mockAuthController.stream;
    }
    // Return live Firebase auth changes, allowing mock override for quick demo
    return _firebaseAuth.authStateChanges().map((user) => _mockUid ?? user?.uid);
  }

  /// Sign in with email and password
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _mockUid = null;

    if (_firebaseAuth == null) {
      debugPrint('AuthService: Firebase not initialized. Mocking sign in for: $email');
      final uid = 'demo_uid_${email.hashCode.abs()}';
      _mockUid = uid;
      _mockAuthController.add(uid);
      return uid;
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
    _mockUid = null;

    if (_firebaseAuth == null) {
      debugPrint('AuthService: Firebase not initialized. Mocking signup for: $email');
      final uid = 'demo_uid_${email.hashCode.abs()}';
      _mockUid = uid;
      _mockAuthController.add(uid);
      return uid;
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

  /// Force a demo login session
  void signInDemo({required bool isGuardian}) {
    final uid = isGuardian ? 'demo_guardian_uid' : 'demo_sister_uid';
    _mockUid = uid;
    _mockAuthController.add(uid);
  }

  /// Sign out
  Future<void> signOut() async {
    _mockUid = null;
    _mockAuthController.add(null);
    if (_firebaseAuth != null) {
      await _firebaseAuth.signOut();
    }
  }
}

