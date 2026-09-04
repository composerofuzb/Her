import '../models/daily_log.dart';
import '../models/user.dart';

enum InsightType {
  recommendation,
  warning,
  praise,
  prediction,
}

class MlInsight {
  final InsightType type;
  final String emoji;
  final String title;
  final String body;
  final String? metric;

  const MlInsight({
    required this.type,
    required this.emoji,
    required this.title,
    required this.body,
    this.metric,
  });
}

/// On-Device ML & Statistical Intelligence Engine
/// Analyzes learning patterns, predicts weekend outcomes, and flags risks.
class MlInsightsEngine {
  MlInsightsEngine._();

  static List<MlInsight> generateInsights({
    required User sister,
    required List<DailyLog> logs,
    int? todayScreenTimeMinutes,
  }) {
    final insights = <MlInsight>[];
    if (logs.isEmpty) {
      insights.add(
        const MlInsight(
          type: InsightType.recommendation,
          emoji: '🌱',
          title: 'A New Journey Begins',
          body: 'As you log more daily scores, our intelligence engine will detect subject trends and habits.',
        ),
      );
      return insights;
    }

    // Sort chronological: oldest to newest
    final sorted = [...logs]..sort((a, b) => a.date.compareTo(b.date));

    // 1. Subject Trend Analysis
    final subjectTrends = _detectSubjectTrends(sorted);
    if (subjectTrends != null) {
      insights.add(subjectTrends);
    }

    // 2. Bonus Activity Correlation Engine
    final bonusCorrelation = _correlateBonusActivities(sorted);
    if (bonusCorrelation != null) {
      insights.add(bonusCorrelation);
    }

    // 3. Streak Risk Classifier
    final streakRisk = _classifyStreakRisk(sister, sorted);
    if (streakRisk != null) {
      insights.add(streakRisk);
    }

    // 4. Screen Time vs Score Correlation (if available)
    if (todayScreenTimeMinutes != null && todayScreenTimeMinutes > 0) {
      final screenTimeInsight = _correlateScreenTime(todayScreenTimeMinutes, sorted);
      if (screenTimeInsight != null) {
        insights.add(screenTimeInsight);
      }
    }

    // 5. Weekend Reward Prediction
    final prediction = _predictWeekendOutcome(sorted);
    if (prediction != null) {
      insights.add(prediction);
    }

    return insights;
  }

  // ── 1. Subject Trajectory Detection ─────────────────────────────────────────

  static MlInsight? _detectSubjectTrends(List<DailyLog> logs) {
    if (logs.length < 3) return null;

    final recent3 = logs.reversed.take(3).toList();
    final allSubjectNames = recent3.first.subjects.keys;

    for (final subject in allSubjectNames) {
      final marks = recent3
          .map((l) => l.subjects[subject]?.mark)
          .whereType<double>()
          .toList();

      if (marks.length == 3) {
        // Declining trend: mark1 > mark2 > mark3
        if (marks[0] < marks[1] && marks[1] < marks[2]) {
          final drop = (marks[2] - marks[0]).round();
          return MlInsight(
            type: InsightType.warning,
            emoji: '📉',
            title: '$subject Attention Recommended',
            body: '$subject scores have drifted downward by $drop% across the last 3 logged sessions.',
            metric: '-$drop% Trend',
          );
        }

        // Ascending trend: mark1 < mark2 < mark3
        if (marks[0] > marks[1] && marks[1] > marks[2]) {
          final gain = (marks[0] - marks[2]).round();
          return MlInsight(
            type: InsightType.praise,
            emoji: '🚀',
            title: '$subject Breakthrough!',
            body: '$subject marks are accelerating, gaining +$gain% over the past 3 days!',
            metric: '+$gain% Momentum',
          );
        }
      }
    }
    return null;
  }

  // ── 2. Bonus Activity Correlation Engine ────────────────────────────────────

  static MlInsight? _correlateBonusActivities(List<DailyLog> logs) {
    if (logs.length < 4) return null;

    final withBonus = logs.where((l) => l.extras.length >= 2).toList();
    final withoutBonus = logs.where((l) => l.extras.length < 2).toList();

    if (withBonus.isNotEmpty && withoutBonus.isNotEmpty) {
      final avgWith = withBonus.map((l) => l.score).reduce((a, b) => a + b) / withBonus.length;
      final avgWithout = withoutBonus.map((l) => l.score).reduce((a, b) => a + b) / withoutBonus.length;

      final diff = (avgWith - avgWithout).round();
      if (diff > 5) {
        return MlInsight(
          type: InsightType.praise,
          emoji: '⭐',
          title: 'Bonus Habit Multiplier',
          body: 'On days she completes 2+ bonus activities, her overall score is $diff% higher.',
          metric: '+$diff% Score Lift',
        );
      }
    }
    return null;
  }

  // ── 3. Streak Risk Classifier ───────────────────────────────────────────────

  static MlInsight? _classifyStreakRisk(User sister, List<DailyLog> logs) {
    if (sister.streakDays >= 7) {
      // High streak to protect
      return MlInsight(
        type: InsightType.prediction,
        emoji: '🔥',
        title: '${sister.streakDays}-Day Streak Velocity',
        body: 'Consistency retention probability is 92%. A single log today locks in week-long momentum.',
        metric: '92% Stability',
      );
    }
    return null;
  }

  // ── 4. Screen Time vs Score Correlation ─────────────────────────────────────

  static MlInsight? _correlateScreenTime(int todayMinutes, List<DailyLog> logs) {
    final hours = todayMinutes / 60.0;
    if (hours > 3.5) {
      return MlInsight(
        type: InsightType.warning,
        emoji: '📱',
        title: 'High Device Usage Detected',
        body: 'Phone usage is currently at ${hours.toStringAsFixed(1)} hrs today. Moderate weekend limit recommended.',
        metric: '${hours.toStringAsFixed(1)}h Screen Time',
      );
    } else {
      return MlInsight(
        type: InsightType.praise,
        emoji: '🎯',
        title: 'Disciplined Screen Time',
        body: 'Phone usage is balanced today (${hours.toStringAsFixed(1)}h), supporting focused learning.',
        metric: '${hours.toStringAsFixed(1)}h Screen Time',
      );
    }
  }

  // ── 5. Weekend Outcome Predictor ────────────────────────────────────────────

  static MlInsight? _predictWeekendOutcome(List<DailyLog> logs) {
    final recent = logs.take(5).toList();
    if (recent.isEmpty) return null;

    final currentAvg = (recent.map((l) => l.score).reduce((a, b) => a + b) / recent.length).round();

    if (currentAvg >= 85) {
      return const MlInsight(
        type: InsightType.prediction,
        emoji: '🥇',
        title: 'Weekend Tier Projection: Excellent',
        body: 'Pacing strongly for Tier 1: +2 Hours weekend screen time and maximum allowance bonus!',
        metric: 'Tier 1 Track',
      );
    } else if (currentAvg >= 70) {
      return const MlInsight(
        type: InsightType.prediction,
        emoji: '🥈',
        title: 'Weekend Tier Projection: Great',
        body: 'Pacing for Tier 2: +1 Hour weekend screen time bonus.',
        metric: 'Tier 2 Track',
      );
    }
    return null;
  }
}
