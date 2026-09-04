import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/daily_log.dart';
import '../../../../domain/models/developmental_stage.dart';
import '../../../../domain/models/user.dart';
import '../../../../domain/use_cases/calculate_score.dart';
import '../../../../domain/use_cases/calculate_xp.dart';
import '../../../../domain/use_cases/developmental_stage_engine.dart';
import '../../../../domain/use_cases/evaluate_streak.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/repositories/log_repository.dart';

final dailyLogViewModelProvider =
    StateNotifierProvider<DailyLogViewModel, DailyLogFormState>((ref) {
  final sister = ref.watch(sisterUserProvider).value;
  final guardian = ref.watch(currentUserProvider).value;
  final stage = sister != null
      ? DevelopmentalStageEngine.resolveStage(sister: sister)
      : DevelopmentalStage.middleSchool;

  return DailyLogViewModel(
    sister: sister,
    guardian: guardian,
    stage: stage,
    logRepository: ref.watch(logRepositoryProvider),
    userRepository: ref.watch(userRepositoryProvider),
  );
});

class DailyLogFormState {
  final String date;
  final Map<String, SubjectData> subjects;
  final String behavior;
  final List<String> extras;
  final List<String> availableExtras;
  final String notes;
  final int calculatedScore;
  final int calculatedXp;
  final bool isSaving;
  final DevelopmentalStage stage;

  const DailyLogFormState({
    required this.date,
    required this.subjects,
    required this.behavior,
    required this.extras,
    required this.availableExtras,
    required this.notes,
    required this.calculatedScore,
    required this.calculatedXp,
    this.isSaving = false,
    this.stage = DevelopmentalStage.middleSchool,
  });

  DailyLogFormState copyWith({
    String? date,
    Map<String, SubjectData>? subjects,
    String? behavior,
    List<String>? extras,
    List<String>? availableExtras,
    String? notes,
    int? calculatedScore,
    int? calculatedXp,
    bool? isSaving,
    DevelopmentalStage? stage,
  }) {
    return DailyLogFormState(
      date: date ?? this.date,
      subjects: subjects ?? this.subjects,
      behavior: behavior ?? this.behavior,
      extras: extras ?? this.extras,
      availableExtras: availableExtras ?? this.availableExtras,
      notes: notes ?? this.notes,
      calculatedScore: calculatedScore ?? this.calculatedScore,
      calculatedXp: calculatedXp ?? this.calculatedXp,
      isSaving: isSaving ?? this.isSaving,
      stage: stage ?? this.stage,
    );
  }
}

class DailyLogViewModel extends StateNotifier<DailyLogFormState> {
  final User? _sister;
  final User? _guardian;
  final LogRepository _logRepository;
  final UserRepository _userRepository;

  DailyLogViewModel({
    required User? sister,
    required User? guardian,
    required DevelopmentalStage stage,
    required LogRepository logRepository,
    required UserRepository userRepository,
  })  : _sister = sister,
        _guardian = guardian,
        _logRepository = logRepository,
        _userRepository = userRepository,
        super(_initialState(stage));

  static DailyLogFormState _initialState(DevelopmentalStage stage) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final defaultSubjects = <String, SubjectData>{
      for (final s in stage.defaultSubjects)
        s: const SubjectData(mark: 85, homework: 'yes'),
    };

    final availableExtras = List<String>.from(stage.recommendedExtras);
    final initialExtras = availableExtras.isNotEmpty
        ? [availableExtras.first]
        : ['Daily Focus Practice'];

    final score = CalculateScore.calculate(
      subjects: defaultSubjects,
      behavior: 'good',
      extras: initialExtras,
    );

    return DailyLogFormState(
      date: today,
      subjects: defaultSubjects,
      behavior: 'good',
      extras: initialExtras,
      availableExtras: availableExtras,
      notes: '',
      calculatedScore: score,
      calculatedXp: CalculateXp.fromScore(score),
      stage: stage,
    );
  }

  void _recompute() {
    final score = CalculateScore.calculate(
      subjects: state.subjects,
      behavior: state.behavior,
      extras: state.extras,
    );
    final xp = CalculateXp.fromScore(score);
    state = state.copyWith(
      calculatedScore: score,
      calculatedXp: xp,
    );
  }

  void updateDate(String date) {
    state = state.copyWith(date: date);
  }

  void updateSubject(String subject, SubjectData data) {
    final updated = Map<String, SubjectData>.from(state.subjects);
    updated[subject] = data;
    state = state.copyWith(subjects: updated);
    _recompute();
  }

  void addSubject(String subjectName, [SubjectData? data]) {
    final trimmed = subjectName.trim();
    if (trimmed.isEmpty) return;
    final updated = Map<String, SubjectData>.from(state.subjects);
    updated[trimmed] = data ?? const SubjectData(mark: 85, homework: 'yes');
    state = state.copyWith(subjects: updated);
    _recompute();
  }

  void removeSubject(String subjectName) {
    final updated = Map<String, SubjectData>.from(state.subjects);
    updated.remove(subjectName);
    state = state.copyWith(subjects: updated);
    _recompute();
  }

  void updateBehavior(String behavior) {
    state = state.copyWith(behavior: behavior);
    _recompute();
  }

  void toggleExtra(String extra) {
    final list = List<String>.from(state.extras);
    if (list.contains(extra)) {
      list.remove(extra);
    } else {
      list.add(extra);
    }
    state = state.copyWith(extras: list);
    _recompute();
  }

  void addExtraActivity(String activityName) {
    final trimmed = activityName.trim();
    if (trimmed.isEmpty) return;
    final available = List<String>.from(state.availableExtras);
    if (!available.contains(trimmed)) {
      available.add(trimmed);
    }
    final selected = List<String>.from(state.extras);
    if (!selected.contains(trimmed)) {
      selected.add(trimmed);
    }
    state = state.copyWith(
      availableExtras: available,
      extras: selected,
    );
    _recompute();
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  Future<DailyLog> submitLog() async {
    state = state.copyWith(isSaving: true);

    try {
      final sisterUid = _sister?.uid ?? 'demo_sister_uid';
      final guardianUid = _guardian?.uid ?? 'demo_guardian_uid';

      // Check missions
      final missionsCompleted = CheckMissions.check(
        subjects: state.subjects,
        behavior: state.behavior,
        extras: state.extras,
        score: state.calculatedScore,
      );

      final log = DailyLog(
        id: 'log_${state.date}_$sisterUid',
        date: state.date,
        subjects: state.subjects,
        behavior: state.behavior,
        extras: state.extras,
        notes: state.notes,
        score: state.calculatedScore,
        xpAwarded: state.calculatedXp,
        missionsCompleted: missionsCompleted,
        sisterUid: sisterUid,
        guardianUid: guardianUid,
      );

      await _logRepository.saveDailyLog(log);

      // Evaluate streak & update sister progress
      if (_sister != null) {
        final streakResult = EvaluateStreak.evaluate(
          lastLogDate: _sister.lastLogDate,
          currentStreak: _sister.streakDays,
          streakFreezes: _sister.streakFreezes,
        );

        final newXp = _sister.xp + state.calculatedXp;
        final newLevel = User.levelFromXp(newXp);
        final newAvatarStage = User.avatarStageFromLevel(newLevel);

        final updatedSister = _sister.copyWith(
          xp: newXp,
          level: newLevel,
          streakDays: streakResult.newStreakDays,
          lastLogDate: streakResult.newLastLogDate,
          streakFreezes: streakResult.newStreakFreezes,
          avatarStage: newAvatarStage,
        );

        await _userRepository.createUser(updatedSister);
      }

      return log;
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}
