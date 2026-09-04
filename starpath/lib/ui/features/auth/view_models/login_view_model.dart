import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/auth_repository.dart';

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, AsyncValue<void>>((ref) {
  return LoginViewModel(
    authRepository: ref.watch(authRepositoryProvider),
  );
});

class LoginViewModel extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  LoginViewModel({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AsyncValue.data(null));


  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signIn(email: email, password: password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}
