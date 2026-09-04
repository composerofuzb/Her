import 'package:flutter/services.dart';

/// Choreographs tactile haptic feedback for StarPath gamification events.
/// Uses Flutter's high-performance native HapticFeedback engine.
class HapticChoreographer {
  HapticChoreographer._();

  /// Short light tap on XP gain
  static Future<void> onXpGained() async {
    await HapticFeedback.lightImpact();
  }

  /// Heavy double tap for level-up celebration
  static Future<void> onLevelUp() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 160));
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 240));
    await HapticFeedback.mediumImpact();
  }

  /// Triple medium tap for streak milestones (7, 14, 30 days)
  static Future<void> onStreakMilestone() async {
    for (int i = 0; i < 3; i++) {
      await HapticFeedback.mediumImpact();
      if (i < 2) await Future.delayed(const Duration(milliseconds: 120));
    }
  }

  /// Medium impact for daily mission complete
  static Future<void> onMissionComplete() async {
    await HapticFeedback.mediumImpact();
  }

  /// Crisp double tap for weekly quest completion
  static Future<void> onQuestComplete() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Fanfare haptic sequence when an achievement badge is unlocked
  static Future<void> onBadgeUnlocked() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// Sharp icy pulse when streak freeze is consumed
  static Future<void> onFreezeUsed() async {
    await HapticFeedback.selectionClick();
    await Future.delayed(const Duration(milliseconds: 60));
    await HapticFeedback.mediumImpact();
  }

  /// Drumroll/rumble haptic pattern as Sunday reward chest opens
  static Future<void> onRewardChestOpen() async {
    for (int i = 0; i < 4; i++) {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 90));
    }
    await HapticFeedback.heavyImpact();
  }

  /// Vibrate pulse for streak broken
  static Future<void> onStreakBroken() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 120));
    await HapticFeedback.heavyImpact();
  }
}
