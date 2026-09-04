import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/star_path_button.dart';
import '../../../../domain/models/user.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../router/app_router.dart';

/// Screen displayed when Firebase is not yet initialized.
/// Allows viewing setup steps OR launching directly into offline demo mode!
class FirebaseSetupScreen extends ConsumerWidget {
  final String? error;

  const FirebaseSetupScreen({super.key, this.error});

  void _launchDemo(BuildContext context, WidgetRef ref, {required bool isGuardian}) async {
    final userRepo = ref.read(userRepositoryProvider);
    final authRepo = ref.read(authRepositoryProvider);

    // Sign in to mock auth
    final email = isGuardian ? 'guardian@starpath.app' : 'sister@starpath.app';

    // Seed mock users

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
    );

    const guardian = User(
      uid: 'demo_guardian_uid',
      displayName: 'Guardian',
      role: 'guardian',
      linkedUid: 'demo_sister_uid',
    );

    await userRepo.createUser(sister);
    await userRepo.createUser(guardian);
    await authRepo.signIn(email: email, password: 'password123');

    if (!context.mounted) return;

    // Rebuild with router
    Navigator.of(context).pushReplacement(

      MaterialPageRoute(
        builder: (_) => Consumer(
          builder: (ctx, r, _) {
            final router = r.watch(appRouterProvider);
            return MaterialApp.router(
              title: 'StarPath Demo',
              theme: Theme.of(context),
              routerConfig: router,
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.deepSpace,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text('⭐', style: TextStyle(fontSize: 54)),
              const SizedBox(height: 12),
              Text(
                'StarPath',
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.starGold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Duolingo-style KPI Tracker for your Sister',
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Demo mode action cards
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.cosmicPurple.withOpacity(0.3),
                      AppColors.nebulaCard,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cosmicPurple.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Text(
                      '🎮 Instant Offline Demo',
                      style: AppTypography.titleLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Preview the full experience right now without Firebase setup. Try both roles:',
                      style: AppTypography.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: StarPathButton(
                            label: 'Sister Mode',
                            icon: Icons.person,
                            onPressed: () => _launchDemo(context, ref, isGuardian: false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StarPathButton(
                            label: 'Guardian Mode',
                            isPrimary: false,
                            icon: Icons.admin_panel_settings,
                            onPressed: () => _launchDemo(context, ref, isGuardian: true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Setup instructions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.nebulaCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cloud_sync, color: AppColors.starGold, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Connect Cloud Firebase',
                          style: AppTypography.titleMedium.copyWith(color: AppColors.starGold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _stepItem('1', 'Go to console.firebase.google.com'),
                    _stepItem('2', 'Create project "starpath-kpi"'),
                    _stepItem('3', 'Add Android app with package: com.starpath.app'),
                    _stepItem('4', 'Download google-services.json to android/app/'),
                    _stepItem('5', 'Enable Email/Password Auth & Cloud Firestore'),
                  ],
                ),
              ),

              if (error != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Firebase status: $error',
                    style: AppTypography.bodySmall.copyWith(color: Colors.redAccent),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cosmicPurple.withOpacity(0.2),
              border: Border.all(color: AppColors.cosmicPurple, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
