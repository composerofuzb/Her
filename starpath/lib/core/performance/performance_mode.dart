import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing Redmi 7 / Low-RAM Lite Mode
final performanceModeProvider =
    StateNotifierProvider<PerformanceModeNotifier, PerformanceModeState>((ref) {
  return PerformanceModeNotifier();
});

class PerformanceModeState {
  final bool isLiteMode;
  final bool reduceAnimations;
  final bool disableShadows;
  final bool lowRamClampApplied;

  const PerformanceModeState({
    required this.isLiteMode,
    required this.reduceAnimations,
    required this.disableShadows,
    required this.lowRamClampApplied,
  });

  PerformanceModeState copyWith({
    bool? isLiteMode,
    bool? reduceAnimations,
    bool? disableShadows,
    bool? lowRamClampApplied,
  }) {
    return PerformanceModeState(
      isLiteMode: isLiteMode ?? this.isLiteMode,
      reduceAnimations: reduceAnimations ?? this.reduceAnimations,
      disableShadows: disableShadows ?? this.disableShadows,
      lowRamClampApplied: lowRamClampApplied ?? this.lowRamClampApplied,
    );
  }
}

class PerformanceModeNotifier extends StateNotifier<PerformanceModeState> {
  static const _prefKey = 'starpath_lite_mode_enabled';

  PerformanceModeNotifier()
      : super(const PerformanceModeState(
          isLiteMode: false,
          reduceAnimations: false,
          disableShadows: false,
          lowRamClampApplied: false,
        )) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_prefKey) ?? false;
      if (enabled) {
        setLiteMode(true);
      }
    } catch (_) {
      // Defaults to false if storage read fails
    }
  }

  void setLiteMode(bool enabled) async {
    state = state.copyWith(
      isLiteMode: enabled,
      reduceAnimations: enabled,
      disableShadows: enabled,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, enabled);
    } catch (_) {}

    if (enabled) {
      _applyRamOptimization();
    }
  }

  /// Clamps Flutter's internal image and texture cache to preserve Redmi 7 RAM
  void _applyRamOptimization() {
    try {
      PaintingBinding.instance.imageCache.maximumSizeBytes = 16 * 1024 * 1024; // 16 MB max
      PaintingBinding.instance.imageCache.maximumSize = 30; // 30 entries max
      state = state.copyWith(lowRamClampApplied: true);
    } catch (_) {}
  }
}
