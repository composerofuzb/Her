import 'package:flutter_test/flutter_test.dart';
import 'package:starpath/domain/models/developmental_stage.dart';
import 'package:starpath/domain/models/user.dart';
import 'package:starpath/domain/use_cases/developmental_stage_engine.dart';

void main() {
  group('Developmental Stage Engine Tests', () {
    final defaultBirthDate = DateTime(2014, 1, 12);

    test('Calculates exact age correctly before and after birthday', () {
      // Maya born Jan 12, 2014
      // On Jan 11, 2026 (day before turning 12)
      expect(
        DevelopmentalStageEngine.calculateAge(defaultBirthDate, DateTime(2026, 1, 11)),
        11,
      );

      // On Jan 12, 2026 (turns 12!)
      expect(
        DevelopmentalStageEngine.calculateAge(defaultBirthDate, DateTime(2026, 1, 12)),
        12,
      );

      // On July 15, 2026
      expect(
        DevelopmentalStageEngine.calculateAge(defaultBirthDate, DateTime(2026, 7, 15)),
        12,
      );

      // Turning 15 on Jan 12, 2029 (High School transition)
      expect(
        DevelopmentalStageEngine.calculateAge(defaultBirthDate, DateTime(2029, 1, 12)),
        15,
      );

      // Turning 19 on Jan 12, 2033 (University transition)
      expect(
        DevelopmentalStageEngine.calculateAge(defaultBirthDate, DateTime(2033, 1, 12)),
        19,
      );
    });

    test('Maps age to correct DevelopmentalStage boundaries', () {
      // Middle School: Ages 11–14
      expect(DevelopmentalStageEngine.stageFromAge(11), DevelopmentalStage.middleSchool);
      expect(DevelopmentalStageEngine.stageFromAge(12), DevelopmentalStage.middleSchool);
      expect(DevelopmentalStageEngine.stageFromAge(13), DevelopmentalStage.middleSchool);
      expect(DevelopmentalStageEngine.stageFromAge(14), DevelopmentalStage.middleSchool);

      // High School: Ages 15–18
      expect(DevelopmentalStageEngine.stageFromAge(15), DevelopmentalStage.highSchool);
      expect(DevelopmentalStageEngine.stageFromAge(16), DevelopmentalStage.highSchool);
      expect(DevelopmentalStageEngine.stageFromAge(17), DevelopmentalStage.highSchool);
      expect(DevelopmentalStageEngine.stageFromAge(18), DevelopmentalStage.highSchool);

      // University / Young Adult: Ages 19+
      expect(DevelopmentalStageEngine.stageFromAge(19), DevelopmentalStage.university);
      expect(DevelopmentalStageEngine.stageFromAge(20), DevelopmentalStage.university);
      expect(DevelopmentalStageEngine.stageFromAge(22), DevelopmentalStage.university);
      expect(DevelopmentalStageEngine.stageFromAge(25), DevelopmentalStage.university);
    });

    test('Resolves stage from User birthDate and handles simulatedAge override', () {
      const sisterActual = User(
        uid: 'maya-1',
        displayName: 'Maya',
        role: 'sister',
        birthDate: '2014-01-12',
      );

      // In 2026, Maya is 12 -> middleSchool
      final stage2026 = DevelopmentalStageEngine.resolveStage(
        sister: sisterActual,
        currentDate: DateTime(2026, 2, 1),
      );
      expect(stage2026, DevelopmentalStage.middleSchool);
      expect(stage2026.stageName, 'Middle School');
      expect(stage2026.title, 'Cosmic Explorer');

      // Simulated age override for High School preview
      final sisterSimulatedHS = sisterActual.copyWith(simulatedAge: 16);
      final stageHS = DevelopmentalStageEngine.resolveStage(
        sister: sisterSimulatedHS,
        currentDate: DateTime(2026, 2, 1),
      );
      expect(stageHS, DevelopmentalStage.highSchool);
      expect(stageHS.title, 'Starlight Scholar');

      // Simulated age override for University preview
      final sisterSimulatedUniv = sisterActual.copyWith(simulatedAge: 21);
      final stageUniv = DevelopmentalStageEngine.resolveStage(
        sister: sisterSimulatedUniv,
        currentDate: DateTime(2026, 2, 1),
      );
      expect(stageUniv, DevelopmentalStage.university);
      expect(stageUniv.title, 'Cosmic Master');
    });

    test('Computes days until January 12 birthday correctly across times of day and leap years', () {
      // Exact day of birthday at midnight
      expect(
        DevelopmentalStageEngine.daysUntilBirthday(defaultBirthDate, DateTime(2026, 1, 12, 0, 0)),
        0,
      );

      // Same birthday at 15:30 in the afternoon (must STILL return 0, not 364!)
      expect(
        DevelopmentalStageEngine.daysUntilBirthday(defaultBirthDate, DateTime(2026, 1, 12, 15, 30)),
        0,
      );

      // Eve of birthday late at night (23:45) -> exactly 1 day remaining!
      expect(
        DevelopmentalStageEngine.daysUntilBirthday(defaultBirthDate, DateTime(2026, 1, 11, 23, 45)),
        1,
      );

      // 2 days before birthday
      expect(
        DevelopmentalStageEngine.daysUntilBirthday(defaultBirthDate, DateTime(2026, 1, 10)),
        2,
      );

      // Day after birthday: counts to next year (2027-01-12)
      final daysAfter = DevelopmentalStageEngine.daysUntilBirthday(
        defaultBirthDate,
        DateTime(2026, 1, 13),
      );
      expect(daysAfter, 364);

      // Leap-year test: born on Feb 29, 2024
      final leapYearBirth = DateTime(2024, 2, 29);
      // In 2024 (leap year), on Feb 28 -> 1 day to Feb 29
      expect(
        DevelopmentalStageEngine.daysUntilBirthday(leapYearBirth, DateTime(2024, 2, 28)),
        1,
      );
      // In 2025 (non-leap year), birthday celebrated Feb 28 -> on Feb 27 -> 1 day
      expect(
        DevelopmentalStageEngine.daysUntilBirthday(leapYearBirth, DateTime(2025, 2, 27)),
        1,
      );
      // In 2025 on Feb 28 -> 0 days (birthday today!)
      expect(
        DevelopmentalStageEngine.daysUntilBirthday(leapYearBirth, DateTime(2025, 2, 28)),
        0,
      );
    });

    test('Provides distinct stage missions and psychology prompts', () {
      final middleMissions = DevelopmentalStageEngine.getStageMissionTitles(
        DevelopmentalStage.middleSchool,
      );
      final hsMissions = DevelopmentalStageEngine.getStageMissionTitles(
        DevelopmentalStage.highSchool,
      );
      final univMissions = DevelopmentalStageEngine.getStageMissionTitles(
        DevelopmentalStage.university,
      );

      expect(middleMissions.any((m) => m.contains('homework')), isTrue);
      expect(hsMissions.any((m) => m.contains('Pomodoro') || m.contains('Deep Focus')), isTrue);
      expect(univMissions.any((m) => m.contains('deep study') || m.contains('research')), isTrue);

      final promptMiddle = DevelopmentalStageEngine.buildSystemPrompt(
        stage: DevelopmentalStage.middleSchool,
        sisterName: 'Maya',
      );
      expect(promptMiddle.contains('Industry vs. Inferiority'), isTrue);

      final promptUniv = DevelopmentalStageEngine.buildSystemPrompt(
        stage: DevelopmentalStage.university,
        sisterName: 'Maya',
      );
      expect(promptUniv.contains('Self-Determination Theory'), isTrue);
    });
  });
}
