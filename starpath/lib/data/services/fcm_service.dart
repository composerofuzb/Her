import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService();
});

class FcmService {
  final FirebaseMessaging? _messaging;

  FcmService({FirebaseMessaging? messaging}) : _messaging = messaging;

  Future<void> initialize() async {
    if (_messaging == null) {
      debugPrint('FcmService: Running in mock mode (no Firebase active)');
      return;
    }

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('FCM: Notifications authorized');
        final token = await _messaging.getToken();
        debugPrint('FCM Token: $token');
      }

      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Received foreground notification: ${message.notification?.title}');
      });
    } catch (e) {
      debugPrint('FcmService.initialize error: $e');
    }
  }

  /// Dispatches or schedules in-app notifications
  void simulateNotification({
    required String title,
    required String body,
  }) {
    debugPrint('📢 NOTIFICATION: $title — $body');
  }

  // Pre-configured notification templates from StarPath Plan
  static ({String title, String body}) streakWarning(int streakDays) => (
        title: '🔥 Streak at risk!',
        body: 'Log your progress before midnight to keep your $streakDays-day streak alive!',
      );

  static ({String title, String body}) levelUpCelebration(String sisterName, int level) => (
        title: '🎉 Level Up!',
        body: '$sisterName just reached Level $level in StarPath! Check her progress.',
      );

  static ({String title, String body}) weeklyRewardReady() => (
        title: '📦 Weekly Reward Ready!',
        body: 'Your weekly performance tier is finalized. Tap to unlock your reward chest!',
      );
}
