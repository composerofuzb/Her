import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  try {
    if (Firebase.apps.isNotEmpty) {
      return AuthService(firebaseAuth: fb_auth.FirebaseAuth.instance);
    }
  } catch (e) {
    debugPrint('Firebase not available for AuthService: $e');
  }
  return AuthService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(authService: ref.watch(authServiceProvider));
});

final authStateProvider = StreamProvider<String?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Repository responsible for authentication state and operations
class AuthRepository {
  final AuthService _authService;

  AuthRepository({required AuthService authService}) : _authService = authService;

  String? get currentUid => _authService.currentUid;

  Stream<String?> authStateChanges() => _authService.authStateChanges();

  Future<String> signIn({
    required String email,
    required String password,
  }) {
    return _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<String> signUp({
    required String email,
    required String password,
  }) {
    return _authService.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  void signInDemo({required bool isGuardian}) {
    _authService.signInDemo(isGuardian: isGuardian);
  }

  Future<void> signOut() => _authService.signOut();
}
