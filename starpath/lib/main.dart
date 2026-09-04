// ============================================================
// main.dart — StarPath App Entry Point
// ============================================================
// FIREBASE SETUP REQUIRED:
//   1. Go to https://console.firebase.google.com
//   2. Create a project named "starpath-kpi"
//   3. Add an Android app with package name: com.starpath.app
//   4. Download google-services.json and place it at:
//      android/app/google-services.json
//   5. Follow the Firebase setup instructions in the console
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'ui/router/app_router.dart';
import 'ui/features/auth/views/firebase_setup_screen.dart';

bool _firebaseInitialized = false;
Object? _firebaseError;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    _firebaseInitialized = true;
  } catch (e) {
    _firebaseError = e;
    debugPrint('Firebase initialization failed: $e');
    debugPrint('Please add google-services.json to android/app/ directory.');
  }

  runApp(
    ProviderScope(
      child: StarPathApp(
        firebaseInitialized: _firebaseInitialized,
        firebaseError: _firebaseError,
      ),
    ),
  );
}

class StarPathApp extends ConsumerWidget {
  final bool firebaseInitialized;
  final Object? firebaseError;

  const StarPathApp({
    super.key,
    required this.firebaseInitialized,
    this.firebaseError,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!firebaseInitialized) {
      return MaterialApp(
        title: 'StarPath',
        theme: AppTheme.darkTheme,
        home: FirebaseSetupScreen(error: firebaseError?.toString()),
        debugShowCheckedModeBanner: false,
      );
    }

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'StarPath',
      theme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
