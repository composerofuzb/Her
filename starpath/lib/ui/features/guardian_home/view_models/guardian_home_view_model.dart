import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/user.dart';
import '../../../../domain/models/daily_log.dart';
import '../../../../domain/use_cases/calculate_score.dart';
import '../../../../domain/use_cases/ml_insights_engine.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/repositories/log_repository.dart';
import '../../../../data/services/screen_time_service.dart';

final guardianHomeViewModelProvider =
    StateNotifierProvider<GuardianHomeViewModel, GuardianHomeState>((ref) {
  final sister = ref.watch(sisterUserProvider).value;
  final logs = ref.watch(sisterLogsProvider).value ?? [];
  final todayLog = ref.watch(todayLogProvider);
  final screenTime = ref.watch(screenTimeDataProvider).value;

  return GuardianHomeViewModel(
    sister: sister,
    logs: logs,
    todayLog: todayLog,
    screenTimeMinutes: screenTime?.totalMinutes,
  );
});

class GuardianHomeState {
  final User? sister;
  final List<DailyLog> logs;
  final DailyLog? todayLog;
  final int weeklyScore;
  final ({String label, String emoji}) tier;
  final List<MlInsight> insights;

  const GuardianHomeState({
    this.sister,
    required this.logs,
    this.todayLog,
    required this.weeklyScore,
    required this.tier,
    required this.insights,
  });
}

class GuardianHomeViewModel extends StateNotifier<GuardianHomeState> {
  GuardianHomeViewModel({
    required User? sister,
    required List<DailyLog> logs,
    required DailyLog? todayLog,
    int? screenTimeMinutes,
  }) : super(_computeState(sister, logs, todayLog, screenTimeMinutes));

  static GuardianHomeState _computeState(
    User? sister,
    List<DailyLog> logs,
    DailyLog? todayLog,
    int? screenTimeMinutes,
  ) {
    final recentScores = logs.take(7).map((l) => l.score).toList();
    final weeklyAvg = CalculateScore.weeklyAverage(recentScores);
    final tier = CalculateScore.tierForScore(weeklyAvg);

    final insights = sister != null
        ? MlInsightsEngine.generateInsights(
            sister: sister,
            logs: logs,
            todayScreenTimeMinutes: screenTimeMinutes,
          )
        : <MlInsight>[];

    return GuardianHomeState(
      sister: sister,
      logs: logs,
      todayLog: todayLog,
      weeklyScore: weeklyAvg,
      tier: tier,
      insights: insights,
    );
  }
}
