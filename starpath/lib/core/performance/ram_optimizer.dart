import 'package:flutter/material.dart';

/// Performance & RAM optimization helpers targeted for low-memory devices (Redmi 7)
class RamOptimizer {
  RamOptimizer._();

  /// Wraps widget in RepaintBoundary to avoid triggering full-screen repaints
  /// when animations play inside child widget
  static Widget isolatedRepaint({required Widget child}) {
    return RepaintBoundary(child: child);
  }

  /// Conditionally applies shadows: returns empty list if in Lite Mode
  static List<BoxShadow>? filterShadows(List<BoxShadow>? shadows, {required bool isLiteMode}) {
    if (isLiteMode) return null;
    return shadows;
  }

  /// Safe memory release trigger when navigating away from large screens
  static void purgeTransientCaches() {
    try {
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (_) {}
  }
}
