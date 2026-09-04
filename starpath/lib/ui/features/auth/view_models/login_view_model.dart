import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../domain/models/user.dart';

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, AsyncValue<void>>((ref) {
  return LoginViewModel(
    authRepository: ref.watch(authRepositoryProvider),
    userRepository: ref.watch(userRepositoryProvider),
  );
});

class LoginViewModel extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  LoginViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        super(const AsyncValue.data(null));

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final uid = await _authRepository.signIn(email: email, password: password);

      // Auto-provision profile document if first time or missing in Firestore
      final existing = await _userRepository.getUser(uid);
      if (existing == null) {
        final emailLower = email.toLowerCase();
        final isSister = emailLower.contains('sevinch') || emailLower.contains('sister');
        final isGuardian = emailLower.contains('james') || emailLower.contains('guardian');

        final user = User(
          uid: uid,
          displayName: isSister ? 'Sevinch' : (isGuardian ? 'James' : email.split('@').first),
          role: isSister ? 'sister' : (isGuardian ? 'guardian' : 'sister'),
          linkedUid: isSister ? 'cRtmsOpHavcQRS1kgQd7OlMnY6u2' : 'HNUd3qgwEFTA9WmIyaAcyQBhZoU2',
          xp: 100,
          level: 1,
          streakDays: 1,
          birthDate: '2014-01-12',
          lastLogDate: DateTime.now().toIso8601String().substring(0, 10),
        );
        await _userRepository.createUser(user);
      }

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void signInDemo({required bool isGuardian}) {
    _authRepository.signInDemo(isGuardian: isGuardian);
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}
