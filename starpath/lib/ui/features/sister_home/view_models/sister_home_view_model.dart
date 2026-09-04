import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/user.dart';
import '../../../../domain/models/daily_log.dart';
import '../../../../domain/models/mission.dart';
import '../../../../domain/models/weekly_quest.dart';
import '../../../../data/models/achievement_model.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/repositories/log_repository.dart';
import '../../../../data/repositories/achievement_repository.dart';
import '../../../../domain/use_cases/evaluate_achievements.dart';
import '../../../../domain/models/developmental_stage.dart';
import '../../../../domain/use_cases/developmental_stage_engine.dart';

final sisterHomeViewModelProvider =
    StateNotifierProvider<SisterHomeViewModel, SisterHomeState>((ref) {
  final sister = ref.watch(sisterUserProvider).value;
  final todayLog = ref.watch(todayLogProvider);
  final logs = ref.watch(sisterLogsProvider).value ?? [];
  final achievements = ref.watch(unlockedAchievementsProvider).value ?? [];
  final stage = sister != null
      ? DevelopmentalStageEngine.resolveStage(sister: sister)
      : DevelopmentalStage.middleSchool;

  return SisterHomeViewModel(
    sister: sister,
    todayLog: todayLog,
    logs: logs,
    stage: stage,
    achievements: achievements,
    userRepository: ref.watch(userRepositoryProvider),
    achievementRepository: ref.watch(achievementRepositoryProvider),
  );
});

class SisterHomeState {
  final User? sister;
  final DailyLog? todayLog;
  final List<DailyLog> logs;
  final List<Mission> missions;
  final List<WeeklyQuest> weeklyQuests;
  final List<AchievementModel> achievements;
  final bool isLoading;

  const SisterHomeState({
    this.sister,
    this.todayLog,
    required this.logs,
    required this.missions,
    required this.weeklyQuests,
    required this.achievements,
    this.isLoading = false,
  });

  SisterHomeState copyWith({
    User? sister,
    DailyLog? todayLog,
    List<DailyLog>? logs,
    List<Mission>? missions,
    List<WeeklyQuest>? weeklyQuests,
    List<AchievementModel>? achievements,
    bool? isLoading,
  }) {
    return SisterHomeState(
      sister: sister ?? this.sister,
      todayLog: todayLog ?? this.todayLog,
      logs: logs ?? this.logs,
      missions: missions ?? this.missions,
      weeklyQuests: weeklyQuests ?? this.weeklyQuests,
      achievements: achievements ?? this.achievements,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SisterHomeViewModel extends StateNotifier<SisterHomeState> {
  final UserRepository _userRepository;
  final AchievementRepository _achievementRepository;

  SisterHomeViewModel({
    required User? sister,
    required DailyLog? todayLog,
    required List<DailyLog> logs,
    required DevelopmentalStage stage,
    required List<AchievementModel> achievements,
    required UserRepository userRepository,
    required AchievementRepository achievementRepository,
  })  : _userRepository = userRepository,
        _achievementRepository = achievementRepository,
        super(
          SisterHomeState(
            sister: sister,
            todayLog: todayLog,
            logs: logs,
            missions: _buildMissions(todayLog, stage),
            weeklyQuests: WeeklyQuest.evaluateWeekly(logs.take(7).toList()),
            achievements: achievements,
          ),
        );

  static List<Mission> _buildMissions(DailyLog? log, DevelopmentalStage stage) {
    final completedTypes = log?.missionsCompleted ?? [];
    return Mission.stageMissions(stage).map((m) {
      return m.copyWith(completed: completedTypes.contains(m.type.name));
    }).toList();
  }

  /// Consumes one streak freeze if available
  Future<bool> useStreakFreeze() async {
    final sister = state.sister;
    if (sister == null || sister.streakFreezes <= 0) return false;

    final updated = sister.copyWith(
      streakFreezes: sister.streakFreezes - 1,
    );
    await _userRepository.createUser(updated);
    state = state.copyWith(sister: updated);
    return true;
  }

  /// Evaluates and auto-unlocks any achievements that were earned
  Future<List<BadgeDefinition>> checkForNewAchievements() async {
    final sister = state.sister;
    if (sister == null) return [];

    final unlockedIds = state.achievements.map((a) => a.badgeId).toSet();
    final newlyEarned = EvaluateAchievements.evaluate(
      sister: sister,
      allLogs: state.logs,
      alreadyUnlockedBadgeIds: unlockedIds,
    );

    for (final badge in newlyEarned) {
      await _achievementRepository.unlockBadge(
        sisterUid: sister.uid,
        badgeId: badge.id,
        title: badge.title,
        emoji: badge.emoji,
      );
    }

    return newlyEarned;
  }
}
