import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/log_model.dart';
import '../../domain/models/daily_log.dart';
import '../services/firestore_service.dart';
import 'user_repository.dart';

final logRepositoryProvider = Provider<LogRepository>((ref) {
  return LogRepository(
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});

/// Watches the sister's logs list
final sisterLogsProvider = StreamProvider<List<DailyLog>>((ref) {
  final sister = ref.watch(sisterUserProvider).value;
  if (sister == null) return Stream.value([]);

  final logRepo = ref.watch(logRepositoryProvider);
  return logRepo.watchLogs(sister.uid);
});

/// Watches today's log for the sister
final todayLogProvider = Provider<DailyLog?>((ref) {
  final logs = ref.watch(sisterLogsProvider).value ?? [];
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  try {
    return logs.firstWhere((log) => log.date == today);
  } catch (_) {
    return null;
  }
});

class LogRepository {
  final FirestoreService _firestoreService;

  LogRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  DailyLog _toDomain(LogModel model) {
    return DailyLog(
      id: model.id,
      date: model.date,
      subjects: model.subjects.map(
        (key, s) => MapEntry(key, SubjectData(mark: s.mark, homework: s.homework)),
      ),
      behavior: model.behavior,
      extras: model.extras,
      notes: model.notes,
      score: model.score,
      xpAwarded: model.xpAwarded,
      missionsCompleted: model.missionsCompleted,
      sisterUid: model.sisterUid,
      guardianUid: model.guardianUid,
    );
  }

  LogModel _toModel(DailyLog domain) {
    return LogModel(
      id: domain.id,
      date: domain.date,
      subjects: domain.subjects.map(
        (key, s) => MapEntry(key, SubjectDataModel(mark: s.mark, homework: s.homework)),
      ),
      behavior: domain.behavior,
      extras: domain.extras,
      notes: domain.notes,
      score: domain.score,
      xpAwarded: domain.xpAwarded,
      missionsCompleted: domain.missionsCompleted,
      sisterUid: domain.sisterUid,
      guardianUid: domain.guardianUid,
    );
  }

  Future<void> saveDailyLog(DailyLog log) {
    return _firestoreService.saveLog(_toModel(log));
  }

  Future<DailyLog?> getLogByDate(String sisterUid, String date) async {
    final model = await _firestoreService.getLogByDate(sisterUid, date);
    return model != null ? _toDomain(model) : null;
  }

  Stream<List<DailyLog>> watchLogs(String sisterUid, {int limit = 30}) {
    return _firestoreService
        .watchLogs(sisterUid, limit: limit)
        .map((list) => list.map(_toDomain).toList());
  }
}
