import 'package:flutter_test/flutter_test.dart';
import 'package:starpath/domain/models/daily_log.dart';
import 'package:starpath/domain/use_cases/calculate_score.dart';
import 'package:starpath/domain/use_cases/calculate_xp.dart';
import 'package:starpath/domain/use_cases/evaluate_streak.dart';

void main() {
  group('StarPath Scoring & XP Logic', () {
    test('CalculateXp returns correct tier XP awards', () {
      expect(CalculateXp.fromScore(95), 100);
      expect(CalculateXp.fromScore(80), 75);
      expect(CalculateXp.fromScore(65), 50);
      expect(CalculateXp.fromScore(50), 25);
      expect(CalculateXp.fromScore(30), 10);
    });

    test('CalculateScore computes balanced formula accurately', () {
      final score = CalculateScore.calculate(
        subjects: {
          'Math': const SubjectData(mark: 90, homework: 'yes'),
          'Science': const SubjectData(mark: 80, homework: 'yes'),
        },
        behavior: 'excellent',
        extras: ['Reading', 'Violin'],
      );
      // Math + Science avg = 85 (50% -> 42.5)
      // Homework yes = 100 (20% -> 20)
      // Behavior excellent = 100 (15% -> 15)
      // Extras 2 items = 50 pts (15% -> 7.5)
      // Total = 42.5 + 20 + 15 + 7.5 = 85
      expect(score, 85);
    });

    test('EvaluateStreak increments streak when logged yesterday', () {
      final now = DateTime(2026, 9, 5);
      final result = EvaluateStreak.evaluate(
        lastLogDate: '2026-09-04',
        currentStreak: 13,
        streakFreezes: 1,
        now: now,
      );
      expect(result.newStreakDays, 14);
      expect(result.outcome, StreakOutcome.continued);
    });
  });
}
