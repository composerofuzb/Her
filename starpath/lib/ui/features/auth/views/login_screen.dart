import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/star_path_button.dart';
import '../view_models/login_view_model.dart';
import '../../../../domain/models/user.dart';
import '../../../../data/repositories/user_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 'sevinch@gmail.com');
  final _passCtrl = TextEditingController(text: 'password123');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    await ref.read(loginViewModelProvider.notifier).signIn(
          email: email,
          password: password,
        );
  }

  void _demoLogin({required bool isGuardian}) async {
    final userRepo = ref.read(userRepositoryProvider);
    final loginVm = ref.read(loginViewModelProvider.notifier);

    // Pre-populate mock users
    const sister = User(
      uid: 'demo_sister_uid',
      displayName: 'Maya',
      role: 'sister',
      linkedUid: 'demo_guardian_uid',
      xp: 750,
      level: 4,
      streakDays: 14,
      lastLogDate: '2026-09-04',
      streakFreezes: 1,
      avatarStage: 2,
      birthDate: '2014-01-12',
    );

    const guardian = User(
      uid: 'demo_guardian_uid',
      displayName: 'Guardian',
      role: 'guardian',
      linkedUid: 'demo_sister_uid',
    );

    await userRepo.createUser(sister);
    await userRepo.createUser(guardian);

    // Trigger demo auth stream update so router navigates cleanly
    loginVm.signInDemo(isGuardian: isGuardian);

    if (mounted) {
      context.go(isGuardian ? '/guardian' : '/sister');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewModelProvider);
    final isLoading = loginState.isLoading;

    ref.listen(loginViewModelProvider, (prev, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.deepSpace,
      body: Stack(
        children: [
          // Background ambient star glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cosmicPurple.withOpacity(0.2),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.1, 1.1),
                  duration: const Duration(seconds: 4),
                ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo
                    const Text('⭐', style: TextStyle(fontSize: 64))
                        .animate()
                        .scale(
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1.0, 1.0),
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                        ),
                    const SizedBox(height: 12),
                    Text(
                      'StarPath',
                      style: AppTypography.displayLarge.copyWith(
                        color: AppColors.starGold,
                        letterSpacing: 2,
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 6),
                    Text(
                      'Every star you earn lights tomorrow\'s path',
                      style: AppTypography.bodySmall,
                      textAlign: TextAlign.center,
                    ).animate(delay: 200.ms).fadeIn(),

                    const SizedBox(height: 36),

                    // Login Glassmorphism Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.nebulaCard,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Welcome Back', style: AppTypography.titleLarge),
                          const SizedBox(height: 6),
                          Text(
                            'Sign in with your StarPath account',
                            style: AppTypography.bodySmall,
                          ),
                          const SizedBox(height: 24),

                          // Email field
                          TextField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              labelStyle: const TextStyle(color: Colors.white60),
                              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.cosmicPurpleLight),
                              filled: true,
                              fillColor: AppColors.nebulaDark,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: AppColors.cosmicPurple, width: 1.5),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Password field
                          TextField(
                            controller: _passCtrl,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: Colors.white60),
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.cosmicPurpleLight),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.white38,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: AppColors.nebulaDark,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: AppColors.cosmicPurple, width: 1.5),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Sign In Button
                          StarPathButton(
                            label: 'Sign In',
                            isLoading: isLoading,
                            onPressed: _handleSignIn,
                          ),
                        ],
                      ),
                    ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 28),

                    // Quick Demo Buttons
                    Text('OR TRY QUICK DEMO', style: AppTypography.labelLarge.copyWith(color: Colors.white38)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.starGold,
                              side: BorderSide(color: AppColors.starGold.withOpacity(0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.star, size: 18),
                            label: const Text('Sister Mode'),
                            onPressed: () => _demoLogin(isGuardian: false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.cosmicPurpleLight,
                              side: BorderSide(color: AppColors.cosmicPurple.withOpacity(0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.security, size: 18),
                            label: const Text('Guardian Mode'),
                            onPressed: () => _demoLogin(isGuardian: true),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () => context.go('/onboarding'),
                      child: Text(
                        'Set up as new Guardian →',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.starGold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
