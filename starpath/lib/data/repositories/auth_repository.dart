import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
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

  Future<void> signOut() => _authService.signOut();
}
