import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final screenTimeServiceProvider = Provider<ScreenTimeService>((ref) {
  return ScreenTimeService();
});

/// Stream of today's screen time data
final screenTimeDataProvider = FutureProvider<ScreenTimeData>((ref) async {
  final service = ref.watch(screenTimeServiceProvider);
  return service.getTodayUsage();
});

class ScreenTimeData {
  final int totalMinutes;
  final Map<String, int> apps;
  final bool hasPermission;

  const ScreenTimeData({
    required this.totalMinutes,
    required this.apps,
    required this.hasPermission,
  });

  String get formattedTotal {
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours > 0) return '${hours}h ${mins}m';
    return '${mins}m';
  }

  /// Categorize common app packages for human-readable labels & emoji
  static ({String name, String emoji, String category}) parsePackage(String pkg) {
    if (pkg.contains('youtube')) {
      return (name: 'YouTube', emoji: '▶️', category: 'Entertainment');
    }
    if (pkg.contains('roblox') || pkg.contains('game') || pkg.contains('subwaysurf') || pkg.contains('minecraft')) {
      return (name: 'Games', emoji: '🎮', category: 'Gaming');
    }
    if (pkg.contains('chrome') || pkg.contains('browser')) {
      return (name: 'Chrome Browser', emoji: '🌐', category: 'Browsing');
    }
    if (pkg.contains('tiktok') || pkg.contains('instagram')) {
      return (name: 'Social Media', emoji: '📱', category: 'Social');
    }
    if (pkg.contains('duolingo') || pkg.contains('starpath') || pkg.contains('classroom')) {
      return (name: 'Learning Apps', emoji: '📚', category: 'Education');
    }

    final simpleName = pkg.split('.').last;
    return (name: simpleName[0].toUpperCase() + simpleName.substring(1), emoji: '📱', category: 'General');
  }
}

class ScreenTimeService {
  static const _channel = MethodChannel('starpath/usage_stats');

  Future<bool> checkPermission() async {
    try {
      final hasPerm = await _channel.invokeMethod<bool>('hasUsagePermission') ?? false;
      return hasPerm;
    } catch (_) {
      return false;
    }
  }

  Future<void> requestPermission() async {
    try {
      await _channel.invokeMethod('requestUsagePermission');
    } catch (_) {}
  }

  Future<ScreenTimeData> getTodayUsage() async {
    try {
      final hasPerm = await checkPermission();
      if (!hasPerm) {
        // Return demo simulation if permission not yet granted
        return const ScreenTimeData(
          totalMinutes: 185,
          apps: {
            'com.google.android.youtube': 75,
            'com.roblox.client': 50,
            'com.android.chrome': 35,
            'com.starpath.app': 25,
          },
          hasPermission: false,
        );
      }

      final raw = await _channel.invokeMapMethod<String, dynamic>('getTodayUsage');
      if (raw == null) {
        return const ScreenTimeData(totalMinutes: 0, apps: {}, hasPermission: true);
      }

      final total = (raw['totalMinutes'] as num?)?.toInt() ?? 0;
      final rawApps = raw['apps'] as Map<dynamic, dynamic>? ?? {};
      final apps = <String, int>{};

      for (final entry in rawApps.entries) {
        apps[entry.key.toString()] = (entry.value as num).toInt();
      }

      return ScreenTimeData(
        totalMinutes: total,
        apps: apps,
        hasPermission: true,
      );
    } catch (_) {
      // Fallback
      return const ScreenTimeData(
        totalMinutes: 185,
        apps: {
          'com.google.android.youtube': 75,
          'com.roblox.client': 50,
          'com.android.chrome': 35,
          'com.starpath.app': 25,
        },
        hasPermission: false,
      );
    }
  }
}
