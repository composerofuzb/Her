import '../models/developmental_stage.dart';

/// Offline psychological coaching engine grounded in:
/// - Deci & Ryan's Self-Determination Theory (Autonomy, Competence, Relatedness)
/// - Carol Dweck's Growth Mindset (Process & effort praise over static trait praise)
/// - Mihaly Csikszentmihalyi's Flow State and deliberate practice principles
class PsychologicalOfflineCoachingEngine {
  PsychologicalOfflineCoachingEngine._();

  /// Generates instant, rich psychological coaching when device is offline or all AI APIs are exhausted
  static String generateCoaching({
    required String sisterName,
    required DevelopmentalStage stage,
    required int score,
    required int streakDays,
    String? topSubject,
    String? focusSubject,
    int extrasCount = 0,
  }) {
    final buffer = StringBuffer();

    // 1. Stage-specific Greeting & Psychological Anchor
    switch (stage) {
      case DevelopmentalStage.middleSchool:
        if (score >= 85) {
          buffer.write('🌟 Supernova performance today, $sisterName! ');
          buffer.write(
              'Your focus was out of this world. Scoring $score% proves that putting in daily effort builds real superpowers! ');
        } else if (score >= 65) {
          buffer.write('⭐ Strong work today, $sisterName! ');
          buffer.write(
              'Solid $score% day. Remember: every practice session builds new neural pathways in your brain! ');
        } else {
          buffer.write('🌱 Warm embrace today, $sisterName. ');
          buffer.write(
              'A score of $score% is just today\'s pit stop. Even the brightest stars recharge before their next launch! ');
        }
        break;

      case DevelopmentalStage.highSchool:
        if (score >= 85) {
          buffer.write('🎯 Exceptional execution today, $sisterName. ');
          buffer.write(
              'Operating at $score% demonstrates deep self-regulation and focus mastery. You own your academic trajectory! ');
        } else if (score >= 65) {
          buffer.write('⚡ Steady momentum, $sisterName. ');
          buffer.write(
              'A $score% performance shows consistent grit. Fine-tuning your study blocks will turn good into mastery! ');
        } else {
          buffer.write('💡 Reset and recalibrate, $sisterName. ');
          buffer.write(
              'A tough day ($score%) provides the most valuable data. Analyze what caused friction and adapt your environment tomorrow. ');
        }
        break;

      case DevelopmentalStage.university:
        if (score >= 85) {
          buffer.write('🌌 Intellectual mastery on display, $sisterName. ');
          buffer.write(
              'Your $score% achievement reflects rigorous discipline and flow-state depth. You are building world-class competence! ');
        } else if (score >= 65) {
          buffer.write('⚖️ Resilient balance, $sisterName. ');
          buffer.write(
              'Maintaining $score% while balancing university demands shows sustainable endurance. Protect your deep work routines! ');
        } else {
          buffer.write('🌿 Strategic self-compassion, $sisterName. ');
          buffer.write(
              'Academic and life design is a marathon, not a sprint. Take restorative downtime tonight to return with clarity tomorrow. ');
        }
        break;
    }

    // 2. Specific Context Insight (Subjects & Extras)
    if (topSubject != null && topSubject.isNotEmpty) {
      buffer.write('Your mastery in $topSubject shone especially bright. ');
    }
    if (focusSubject != null && focusSubject.isNotEmpty && score < 85) {
      buffer.write(
          'For $focusSubject, try breaking review sessions into smaller 15-minute high-focus sprints. ');
    }

    // 3. Streak & Tangible Reward Reinforcement
    if (streakDays >= 7) {
      buffer.write(
          '🔥 That $streakDays-day streak is blazing! Keep protecting that momentum for the weekend reward chest! 🎁');
    } else if (streakDays >= 3) {
      buffer.write('⚡ $streakDays days logged in a row — your consistency habit is locking in!');
    }

    return buffer.toString();
  }

  /// Interactive character dialogue bubbles for live character interaction
  static List<String> getCharacterQuotes({
    required DevelopmentalStage stage,
    required String sisterName,
  }) {
    switch (stage) {
      case DevelopmentalStage.middleSchool:
        return [
          "Let's conquer today's missions together! 🚀",
          "You're smarter than you think and braver than you feel! ⭐",
          "Did you finish your homework? The weekend reward chest awaits! 🎁",
          "Practicing a little every day is like planting starlight! 🌱",
          "Tap my star pin to keep our cosmic streak alive! 💫",
        ];
      case DevelopmentalStage.highSchool:
        return [
          "Deep work beats long hours every time. Let's focus! ⏱️",
          "You're in the driver's seat of your future, $sisterName. 🎯",
          "One exam, one project at a time. You've got this! 📝",
          "Protect your focus like the superpower it is. ⚡",
          "Remember to take 5 minutes to breathe and stretch! 🏃‍♀️",
        ];
      case DevelopmentalStage.university:
        return [
          "Competence is built quietly through deliberate practice. 🌌",
          "Own your knowledge. What you learn today builds your life's work. 💼",
          "Deep flow state unlocks solutions you didn't know you had. 🧠",
          "Rest is not a reward for work; it's a prerequisite for excellence. 🌿",
          "Architect your habits, and your habits will architect you. 👑",
        ];
    }
  }
}
