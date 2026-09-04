import 'package:flutter_test/flutter_test.dart';
import 'package:starpath/domain/models/character_customization.dart';
import 'package:starpath/domain/models/developmental_stage.dart';
import 'package:starpath/domain/models/user.dart';

void main() {
  group('Customizable Living Character Engine Tests', () {
    test('CharacterCustomization default construction and JSON serialization', () {
      const char = CharacterCustomization();
      expect(char.skinToneId, 'warmPeach');
      expect(char.hairStyleId, 'twinBuns');
      expect(char.hairColorId, 'midnightBlack');
      expect(char.outfitId, 'middleSchoolCasual');
      expect(char.accessoryId, 'starPin');
      expect(char.auraId, 'auto');

      final map = char.toMap();
      final fromMap = CharacterCustomization.fromMap(map);
      expect(fromMap.skinToneId, char.skinToneId);
      expect(fromMap.hairStyleId, char.hairStyleId);
      expect(fromMap.outfitId, char.outfitId);

      // copyWith modification
      final modified = char.copyWith(
        skinToneId: 'goldenTan',
        hairStyleId: 'ponytail',
        outfitId: 'starAcademy',
      );
      expect(modified.skinToneId, 'goldenTan');
      expect(modified.hairStyleId, 'ponytail');
      expect(modified.outfitId, 'starAcademy');
      expect(modified.accessoryId, 'starPin');
    });

    test('PerformanceMood evaluates dynamically based on score and streak thresholds', () {
      const char = CharacterCustomization();

      // Radiant Cosmic: Score >= 85
      expect(
        char.evaluateMood(todayScore: 85, streakDays: 0),
        PerformanceMood.radiantCosmic,
      );
      expect(
        char.evaluateMood(todayScore: 98, streakDays: 14),
        PerformanceMood.radiantCosmic,
      );

      // Supercharged Streak: Streak >= 7 and Score >= 60 (but < 85)
      expect(
        char.evaluateMood(todayScore: 80, streakDays: 7),
        PerformanceMood.energizedStreak,
      );
      expect(
        char.evaluateMood(todayScore: 65, streakDays: 21),
        PerformanceMood.energizedStreak,
      );

      // Steady Scholar: Score 60-84 with streak < 7
      expect(
        char.evaluateMood(todayScore: 70, streakDays: 3),
        PerformanceMood.steadyScholar,
      );
      expect(
        char.evaluateMood(todayScore: 60, streakDays: 0),
        PerformanceMood.steadyScholar,
      );

      // Resting Recharge: Score < 60
      expect(
        char.evaluateMood(todayScore: 59, streakDays: 14),
        PerformanceMood.restingRecharge,
      );
      expect(
        char.evaluateMood(todayScore: 0, streakDays: 0),
        PerformanceMood.restingRecharge,
      );
    });

    test('WardrobeCatalog items obey level, streak, and stage unlock gates', () {
      final starterItem = WardrobeCatalog.findItem('middleSchoolCasual')!;
      final varsityJacket = WardrobeCatalog.findItem('varsityJacket')!;
      final graduationGown = WardrobeCatalog.findItem('graduationGown')!;
      final streakFlameAura = WardrobeCatalog.findItem('streakFlame')!;

      // Level 1 User
      expect(
        starterItem.isUnlocked(
          userLevel: 1,
          userXp: 0,
          userStreak: 0,
          currentStage: DevelopmentalStage.middleSchool,
        ),
        isTrue,
      );

      // Varsity jacket requires Level 4 and High School stage
      expect(
        varsityJacket.isUnlocked(
          userLevel: 3,
          userXp: 400,
          userStreak: 5,
          currentStage: DevelopmentalStage.middleSchool,
        ),
        isFalse,
      );
      expect(
        varsityJacket.isUnlocked(
          userLevel: 4,
          userXp: 900,
          userStreak: 5,
          currentStage: DevelopmentalStage.middleSchool,
        ),
        isFalse, // Fails stage gate
      );
      expect(
        varsityJacket.isUnlocked(
          userLevel: 4,
          userXp: 900,
          userStreak: 5,
          currentStage: DevelopmentalStage.highSchool,
        ),
        isTrue, // Meets level and stage gate
      );

      // Graduation gown requires Level 10 and University stage
      expect(
        graduationGown.isUnlocked(
          userLevel: 10,
          userXp: 13000,
          userStreak: 30,
          currentStage: DevelopmentalStage.university,
        ),
        isTrue,
      );

      // Streak flame requires 7-day streak
      expect(
        streakFlameAura.isUnlocked(
          userLevel: 5,
          userXp: 1500,
          userStreak: 4,
        ),
        isFalse,
      );
      expect(
        streakFlameAura.isUnlocked(
          userLevel: 5,
          userXp: 1500,
          userStreak: 7,
        ),
        isTrue,
      );
    });

    test('User integration: user stores and copies character customization', () {
      const user = User(
        uid: 'sister_test',
        displayName: 'Maya',
        role: 'sister',
        character: CharacterCustomization(
          skinToneId: 'goldenTan',
          hairStyleId: 'bob',
          hairColorId: 'cosmicViolet',
        ),
      );

      expect(user.character.skinToneId, 'goldenTan');
      expect(user.character.hairStyleId, 'bob');
      expect(user.character.hairColorId, 'cosmicViolet');

      final updatedUser = user.copyWith(
        character: user.character.copyWith(hairStyleId: 'pixie'),
      );
      expect(updatedUser.character.hairStyleId, 'pixie');
      expect(updatedUser.character.skinToneId, 'goldenTan');
    });
  });
}
