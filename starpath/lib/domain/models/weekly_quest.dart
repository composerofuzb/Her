import 'daily_log.dart';

enum WeeklyQuestType {
  fiveDayStreak,
  weeklyAvgAbove80,
  zeroMissedHomework,
  threeBonusActivities,
}

extension WeeklyQuestTypeX on WeeklyQuestType {
  String get title {
    switch (this) {
      case WeeklyQuestType.fiveDayStreak:
        return '5-Day Study Warrior';
      case WeeklyQuestType.weeklyAvgAbove80:
        return 'High Achiever';
      case WeeklyQuestType.zeroMissedHomework:
        return 'Homework Master';
      case WeeklyQuestType.threeBonusActivities:
        return 'Going the Extra Mile';
    }
  }

  String get description {
    switch (this) {
      case WeeklyQuestType.fiveDayStreak:
        return 'Log performance on at least 5 days this week';
      case WeeklyQuestType.weeklyAvgAbove80:
        return 'Maintain a weekly average score of 80 or higher';
      case WeeklyQuestType.zeroMissedHomework:
        return 'Zero missed homework assignments across all subjects';
      case WeeklyQuestType.threeBonusActivities:
        return 'Complete 3 or more bonus activities during the week';
    }
  }

  String get emoji {
    switch (this) {
      case WeeklyQuestType.fiveDayStreak:
        return '🔥';
      case WeeklyQuestType.weeklyAvgAbove80:
        return '🌟';
      case WeeklyQuestType.zeroMissedHomework:
        return '📚';
      case WeeklyQuestType.threeBonusActivities:
        return '⚡';
    }
  }

  int get xpReward {
    switch (this) {
      case WeeklyQuestType.fiveDayStreak:
        return 100;
      case WeeklyQuestType.weeklyAvgAbove80:
        return 75;
      case WeeklyQuestType.zeroMissedHomework:
        return 50;
      case WeeklyQuestType.threeBonusActivities:
        return 40;
    }
  }

  int get targetValue {
    switch (this) {
      case WeeklyQuestType.fiveDayStreak:
        return 5;
      case WeeklyQuestType.weeklyAvgAbove80:
        return 80;
      case WeeklyQuestType.zeroMissedHomework:
        return 1; // 1 = 100% completed
      case WeeklyQuestType.threeBonusActivities:
        return 3;
    }
  }
}

class WeeklyQuest {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int xpReward;
  final int currentProgress;
  final int targetProgress;
  final bool completed;
  final WeeklyQuestType type;

  const WeeklyQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.xpReward,
    required this.currentProgress,
    required this.targetProgress,
    required this.completed,
    required this.type,
  });

  double get progressFraction {
    if (targetProgress <= 0) return 1.0;
    return (currentProgress / targetProgress).clamp(0.0, 1.0);
  }

  /// Calculate all weekly quests from the week's logs
  static List<WeeklyQuest> evaluateWeekly(List<DailyLog> weekLogs) {
    // 1. Five day streak
    final daysCount = weekLogs.map((l) => l.date).toSet().length;
    final quest1Completed = daysCount >= 5;

    // 2. Weekly average >= 80
    final avgScore = weekLogs.isEmpty
        ? 0
        : (weekLogs.map((l) => l.score).reduce((a, b) => a + b) / weekLogs.length).round();
    final quest2Completed = avgScore >= 80 && weekLogs.isNotEmpty;

    // 3. Zero missed homework
    var totalHomeworks = 0;
    var missedHomeworks = 0;
    for (final log in weekLogs) {
      for (final sub in log.subjects.values) {
        totalHomeworks++;
        if (sub.homework == 'no') missedHomeworks++;
      }
    }
    final quest3Completed = totalHomeworks > 0 && missedHomeworks == 0;

    // 4. Three bonus activities
    final totalExtras = weekLogs.fold<int>(0, (sum, log) => sum + log.extras.length);
    final quest4Completed = totalExtras >= 3;

    return [
      WeeklyQuest(
        id: WeeklyQuestType.fiveDayStreak.name,
        title: WeeklyQuestType.fiveDayStreak.title,
        description: WeeklyQuestType.fiveDayStreak.description,
        emoji: WeeklyQuestType.fiveDayStreak.emoji,
        xpReward: WeeklyQuestType.fiveDayStreak.xpReward,
        currentProgress: daysCount,
        targetProgress: 5,
        completed: quest1Completed,
        type: WeeklyQuestType.fiveDayStreak,
      ),
      WeeklyQuest(
        id: WeeklyQuestType.weeklyAvgAbove80.name,
        title: WeeklyQuestType.weeklyAvgAbove80.title,
        description: WeeklyQuestType.weeklyAvgAbove80.description,
        emoji: WeeklyQuestType.weeklyAvgAbove80.emoji,
        xpReward: WeeklyQuestType.weeklyAvgAbove80.xpReward,
        currentProgress: avgScore,
        targetProgress: 80,
        completed: quest2Completed,
        type: WeeklyQuestType.weeklyAvgAbove80,
      ),
      WeeklyQuest(
        id: WeeklyQuestType.zeroMissedHomework.name,
        title: WeeklyQuestType.zeroMissedHomework.title,
        description: WeeklyQuestType.zeroMissedHomework.description,
        emoji: WeeklyQuestType.zeroMissedHomework.emoji,
        xpReward: WeeklyQuestType.zeroMissedHomework.xpReward,
        currentProgress: (totalHomeworks > 0 && missedHomeworks == 0) ? 1 : 0,
        targetProgress: 1,
        completed: quest3Completed,
        type: WeeklyQuestType.zeroMissedHomework,
      ),
      WeeklyQuest(
        id: WeeklyQuestType.threeBonusActivities.name,
        title: WeeklyQuestType.threeBonusActivities.title,
        description: WeeklyQuestType.threeBonusActivities.description,
        emoji: WeeklyQuestType.threeBonusActivities.emoji,
        xpReward: WeeklyQuestType.threeBonusActivities.xpReward,
        currentProgress: totalExtras,
        targetProgress: 3,
        completed: quest4Completed,
        type: WeeklyQuestType.threeBonusActivities,
      ),
    ];
  }
}
