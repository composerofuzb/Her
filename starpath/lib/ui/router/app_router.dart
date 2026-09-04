import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/user_repository.dart';
import '../features/auth/views/login_screen.dart';
import '../features/auth/views/onboarding_screen.dart';
import '../features/sister_home/views/sister_home_screen.dart';
import '../features/sister_home/views/achievements_screen.dart';
import '../features/guardian_home/views/guardian_home_screen.dart';
import '../features/daily_log/views/daily_log_screen.dart';
import '../features/settings/views/settings_screen.dart';

import '../features/character/views/character_customization_screen.dart';
import '../features/settings/views/ai_providers_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final currentUser = ref.watch(currentUserProvider).value;

  return GoRouter(
    initialLocation: '/login',
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggingIn = state.matchedLocation == '/login';
      final isOnboarding = state.matchedLocation == '/onboarding';

      // Not logged in -> go to login unless onboarding
      if (currentUser == null) {
        return (isLoggingIn || isOnboarding) ? null : '/login';
      }

      // Logged in as Sister
      if (currentUser.isSister) {
        if (isLoggingIn || state.matchedLocation.startsWith('/guardian')) {
          return '/sister';
        }
      }

      // Logged in as Guardian
      if (currentUser.isGuardian) {
        if (isLoggingIn || state.matchedLocation.startsWith('/sister')) {
          return '/guardian';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/sister',
        builder: (context, state) => const SisterHomeScreen(),
        routes: [
          GoRoute(
            path: 'achievements',
            builder: (context, state) => const AchievementsScreen(),
          ),
          GoRoute(
            path: 'character',
            builder: (context, state) => const CharacterCustomizationScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/guardian',
        builder: (context, state) => const GuardianHomeScreen(),
        routes: [
          GoRoute(
            path: 'log',
            builder: (context, state) => const DailyLogScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'ai-providers',
            builder: (context, state) => const AiProvidersScreen(),
          ),
          GoRoute(
            path: 'character',
            builder: (context, state) => const CharacterCustomizationScreen(),
          ),
        ],
      ),
    ],
  );
});

