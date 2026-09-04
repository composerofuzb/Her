import 'package:intl/intl.dart';
import '../models/daily_log.dart';
import '../models/mission.dart';

/// Streak evaluation use case
class EvaluateStreak {
  EvaluateStreak._();

  static final _fmt = DateFormat('yyyy-MM-dd');

  /// Evaluate streak given the last log date and current streak count.
  ///
  /// Returns [StreakResult] describing the outcome.
  ///
  /// Logic:
  ///   - If lastLogDate == yesterday → streak continues (increment)
  ///   - If lastLogDate == today → already logged (no change)
  ///   - If lastLogDate is older → streak resets (or use freeze)
  static StreakResult evaluate({
    required String? lastLogDate,
    required int currentStreak,
    required int streakFreezes,
    DateTime? now,
  }) {
    final today = _fmt.format(now ?? DateTime.now());
    final yesterday = _fmt.format(
      (now ?? DateTime.now()).subtract(const Duration(days: 1)),
    );

    if (lastLogDate == null) {
      // First ever log
      return StreakResult(
        newStreakDays: 1,
        newLastLogDate: today,
        newStreakFreezes: streakFreezes,
        outcome: StreakOutcome.started,
      );
    }

    if (lastLogDate == today) {
      // Already logged today — no change
      return StreakResult(
        newStreakDays: currentStreak,
        newLastLogDate: today,
        newStreakFreezes: streakFreezes,
        outcome: StreakOutcome.alreadyLogged,
      );
    }

    if (lastLogDate == yesterday) {
      // Streak continues
      return StreakResult(
        newStreakDays: currentStreak + 1,
        newLastLogDate: today,
        newStreakFreezes: streakFreezes,
        outcome: StreakOutcome.continued,
      );
    }

    // Missed a day — check for freeze
    if (streakFreezes > 0) {
      return StreakResult(
        newStreakDays: currentStreak,
        newLastLogDate: today,
        newStreakFreezes: streakFreezes - 1,
        outcome: StreakOutcome.frozenSaved,
      );
    }

    // Streak broken
    return StreakResult(
      newStreakDays: 1, // start fresh with today
      newLastLogDate: today,
      newStreakFreezes: streakFreezes,
      outcome: StreakOutcome.broken,
    );
  }

  /// Check if the streak is at a milestone (7, 14, 30, 50, 100 days)
  static bool isMilestone(int streakDays) {
    const milestones = [7, 14, 30, 50, 100];
    return milestones.contains(streakDays);
  }
}

enum StreakOutcome {
  started,
  continued,
  alreadyLogged,
  frozenSaved,
  broken,
}

class StreakResult {
  final int newStreakDays;
  final String newLastLogDate;
  final int newStreakFreezes;
  final StreakOutcome outcome;

  const StreakResult({
    required this.newStreakDays,
    required this.newLastLogDate,
    required this.newStreakFreezes,
    required this.outcome,
  });
}

/// Mission completion checker
class CheckMissions {
  CheckMissions._();

  static List<String> check({
    required Map<String, SubjectData> subjects,
    required String behavior,
    required List<String> extras,
    required int score,
    DateTime? loggedAt,
  }) {
    final completed = <String>[];

    // Log all subjects
    if (subjects.isNotEmpty) {
      completed.add(MissionType.logAllSubjects.name);
    }

    // Average mark ≥ 80
    if (subjects.isNotEmpty) {
      final avg =
          subjects.values.map((s) => s.mark).reduce((a, b) => a + b) /
              subjects.length;
      if (avg >= 80) {
        completed.add(MissionType.averageMarkAbove80.name);
      }
    }

    // All homework complete
    final allHomework =
        subjects.values.every((s) => s.homework == 'yes');
    if (allHomework && subjects.isNotEmpty) {
      completed.add(MissionType.allHomeworkComplete.name);
    }

    // 2+ bonus activities
    if (extras.length >= 2) {
      completed.add(MissionType.twoBonusActivities.name);
    }

    // Log before 8 PM
    final now = loggedAt ?? DateTime.now();
    if (now.hour < 20) {
      completed.add(MissionType.logBefore8pm.name);
    }

    return completed;
  }
}
