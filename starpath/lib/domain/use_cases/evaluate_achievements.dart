import '../models/user.dart';
import '../models/daily_log.dart';
import '../../data/models/achievement_model.dart';
import 'calculate_score.dart';

/// Pure use case to evaluate which achievements have been unlocked
class EvaluateAchievements {
  EvaluateAchievements._();

  /// Evaluates all badges and returns list of newly unlocked badge definitions
  static List<BadgeDefinition> evaluate({
    required User sister,
    required List<DailyLog> allLogs,
    required Set<String> alreadyUnlockedBadgeIds,
  }) {
    final newlyUnlocked = <BadgeDefinition>[];

    for (final badge in BadgeCatalog.badges) {
      if (alreadyUnlockedBadgeIds.contains(badge.id)) continue;

      final unlocked = _checkBadge(badge.id, sister, allLogs);
      if (unlocked) {
        newlyUnlocked.add(badge);
      }
    }

    return newlyUnlocked;
  }

  static bool _checkBadge(String badgeId, User sister, List<DailyLog> logs) {
    if (logs.isEmpty) return false;

    switch (badgeId) {
      case 'first_flame':
        // Logged at least 1 day
        return logs.isNotEmpty;

      case 'scholar':
        // 5 consecutive days with 80+ score
        final sorted = [...logs]..sort((a, b) => b.date.compareTo(a.date));
        var consecutive = 0;
        for (final log in sorted) {
          if (log.score >= 80) {
            consecutive++;
            if (consecutive >= 5) return true;
          } else {
            consecutive = 0;
          }
        }
        return false;

      case 'star_student':
        // Any day with 90+ score
        return logs.any((l) => l.score >= 90);

      case 'comeback_kid':
        // Logged after a broken streak (streak == 1 and total logs > 2)
        return sister.streakDays == 1 && logs.length >= 2;

      case 'perfectionist':
        // 100/100 score day
        return logs.any((l) => l.score >= 100);

      case 'month_warrior':
        // 30-day streak
        return sister.streakDays >= 30;

      case 'on_point':
        // Complete all daily missions in a single day
        return logs.any((l) => l.missionsCompleted.length >= 5);

      case 'eagle_eye':
        // Weekly average >= 90
        final recent7 = logs.take(7).map((l) => l.score).toList();
        return recent7.isNotEmpty && CalculateScore.weeklyAverage(recent7) >= 90;

      default:
        return false;
    }
  }
}
