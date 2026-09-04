import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement_model.dart';
import '../services/firestore_service.dart';
import 'user_repository.dart';

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  return AchievementRepository(
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});

/// Watches the unlocked achievements for the sister
final unlockedAchievementsProvider = StreamProvider<List<AchievementModel>>((ref) {
  final sister = ref.watch(sisterUserProvider).value;
  if (sister == null) return Stream.value([]);

  final repo = ref.watch(achievementRepositoryProvider);
  return repo.watchAchievements(sister.uid);
});

class AchievementRepository {
  final FirestoreService _firestoreService;

  AchievementRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  Stream<List<AchievementModel>> watchAchievements(String sisterUid) {
    return _firestoreService.watchAchievements(sisterUid);
  }

  Future<void> unlockBadge({
    required String sisterUid,
    required String badgeId,
    required String title,
    required String emoji,
    int xpAwarded = 50,
  }) async {
    final achievement = AchievementModel(
      id: 'ach_${badgeId}_$sisterUid',
      sisterUid: sisterUid,
      badgeId: badgeId,
      title: title,
      emoji: emoji,
      unlockedAt: DateTime.now(),
      xpAwarded: xpAwarded,
    );
    await _firestoreService.unlockAchievement(achievement);
  }
}
