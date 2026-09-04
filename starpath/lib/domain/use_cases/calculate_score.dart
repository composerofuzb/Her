import '../models/daily_log.dart';

/// Ported exactly from the web app's scoring.js
/// All functions are side-effect free and unit-testable.
class CalculateScore {
  CalculateScore._();

  static const _defaultWeights = ScoreWeights(
    academics: 0.50,
    homework: 0.20,
    behavior: 0.15,
    extras: 0.15,
  );

  static const _behaviorMap = {
    'excellent': 100.0,
    'good': 80.0,
    'neutral': 60.0,
    'poor': 30.0,
    'bad': 0.0,
  };

  static const _hwValues = {
    'yes': 1.0,
    'partial': 0.5,
    'no': 0.0,
  };

  /// Calculate a daily performance score (0–100) from a log entry.
  ///
  /// Matches the web app's calcDailyScore() exactly:
  ///   - Academics (50%): average of all subject marks
  ///   - Homework (20%): yes=100, partial=50, no=0 — averaged
  ///   - Behavior (15%): excellent=100, good=80, neutral=60, poor=30, bad=0
  ///   - Extras (15%): each extra = 25 pts, capped at 100
  static int calculate({
    required Map<String, SubjectData> subjects,
    required String behavior,
    required List<String> extras,
    ScoreWeights? weights,
  }) {
    final w = weights ?? _defaultWeights;


    // ── Academics ────────────────────────────────────────────────────────────
    final subjectList = subjects.values.toList();
    final academicScore = subjectList.isEmpty
        ? 0.0
        : subjectList.map((s) => s.mark).reduce((a, b) => a + b) /
            subjectList.length;

    // ── Homework ─────────────────────────────────────────────────────────────
    final hwScores = subjectList.map((s) => (_hwValues[s.homework] ?? 0.0));
    final hwScore = subjectList.isEmpty
        ? 0.0
        : (hwScores.reduce((a, b) => a + b) / subjectList.length) * 100;

    // ── Behavior ─────────────────────────────────────────────────────────────
    final behaviorScore = _behaviorMap[behavior] ?? 60.0;

    // ── Extras ───────────────────────────────────────────────────────────────
    final extrasScore = (extras.length * 25.0).clamp(0.0, 100.0);

    final raw = academicScore * w.academics +
        hwScore * w.homework +
        behaviorScore * w.behavior +
        extrasScore * w.extras;

    return raw.clamp(0.0, 100.0).round();
  }

  /// Calculate the average score for a list of daily scores.
  static int weeklyAverage(List<int> scores) {
    if (scores.isEmpty) return 0;
    return (scores.reduce((a, b) => a + b) / scores.length).round();
  }

  /// Get tier label and emoji from a score
  static ({String label, String emoji}) tierForScore(int score) {
    if (score >= 90) return (label: 'Excellent', emoji: '🥇');
    if (score >= 75) return (label: 'Great', emoji: '🥈');
    if (score >= 60) return (label: 'Good', emoji: '🥉');
    if (score >= 45) return (label: 'Fair', emoji: '📘');
    return (label: 'Needs Work', emoji: '📉');
  }
}

class ScoreWeights {
  final double academics;
  final double homework;
  final double behavior;
  final double extras;

  const ScoreWeights({
    required this.academics,
    required this.homework,
    required this.behavior,
    required this.extras,
  });
}

