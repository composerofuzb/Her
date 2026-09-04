import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/log_model.dart';
import '../models/achievement_model.dart';

/// Service managing all Cloud Firestore operations with safe in-memory fallback
class FirestoreService {
  final FirebaseFirestore? _firestore;

  // In-memory fallback caches for offline/demo operation
  final Map<String, UserModel> _mockUsers = {};
  final Map<String, List<LogModel>> _mockLogs = {}; // sisterUid -> logs
  final Map<String, List<AchievementModel>> _mockAchievements = {};
  final Map<String, StreamController<UserModel>> _userControllers = {};
  final Map<String, StreamController<List<LogModel>>> _logControllers = {};
  final Map<String, StreamController<List<AchievementModel>>> _achievementControllers = {};

  FirestoreService({FirebaseFirestore? firestore}) : _firestore = firestore;

  // =========================================================================
  // USERS
  // =========================================================================

  Future<UserModel?> getUser(String uid) async {
    if (_firestore == null) {
      return _mockUsers[uid];
    }

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('FirestoreService.getUser error: $e');
      return _mockUsers[uid];
    }
  }

  Future<void> createUser(UserModel user) async {
    if (_firestore == null) {
      _mockUsers[user.uid] = user;
      _userControllers[user.uid]?.add(user);
      return;
    }

    try {
      await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
    } catch (e) {
      debugPrint('FirestoreService.createUser error: $e');
      _mockUsers[user.uid] = user;
      _userControllers[user.uid]?.add(user);
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    if (_firestore == null) {
      final existing = _mockUsers[uid];
      if (existing != null) {
        final updated = existing.copyWith(
          displayName: data['displayName'] as String? ?? existing.displayName,
          xp: (data['xp'] as num?)?.toInt() ?? existing.xp,
          level: (data['level'] as num?)?.toInt() ?? existing.level,
          streakDays: (data['streakDays'] as num?)?.toInt() ?? existing.streakDays,
          lastLogDate: data['lastLogDate'] as String? ?? existing.lastLogDate,
          streakFreezes: (data['streakFreezes'] as num?)?.toInt() ?? existing.streakFreezes,
          avatarStage: (data['avatarStage'] as num?)?.toInt() ?? existing.avatarStage,
          currencySymbol: data['currencySymbol'] as String? ?? existing.currencySymbol,
        );
        _mockUsers[uid] = updated;
        _userControllers[uid]?.add(updated);
      }
      return;
    }

    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      debugPrint('FirestoreService.updateUser error: $e');
    }
  }

  Stream<UserModel?> watchUser(String uid) {
    if (_firestore == null) {
      _userControllers.putIfAbsent(uid, () => StreamController<UserModel>.broadcast());
      final cached = _mockUsers[uid];
      if (cached != null) {
        Future.microtask(() => _userControllers[uid]?.add(cached));
      }
      return _userControllers[uid]!.stream;
    }

    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  // =========================================================================
  // LOGS
  // =========================================================================

  Future<void> saveLog(LogModel log) async {
    if (_firestore == null) {
      final list = _mockLogs.putIfAbsent(log.sisterUid, () => []);
      list.removeWhere((l) => l.date == log.date);
      list.insert(0, log);
      _logControllers[log.sisterUid]?.add(List.unmodifiable(list));
      return;
    }

    try {
      await _firestore.collection('logs').doc(log.id).set(log.toFirestore());
    } catch (e) {
      debugPrint('FirestoreService.saveLog error: $e');
      final list = _mockLogs.putIfAbsent(log.sisterUid, () => []);
      list.removeWhere((l) => l.date == log.date);
      list.insert(0, log);
      _logControllers[log.sisterUid]?.add(List.unmodifiable(list));
    }
  }

  Future<LogModel?> getLogByDate(String sisterUid, String date) async {
    if (_firestore == null) {
      final list = _mockLogs[sisterUid] ?? [];
      try {
        return list.firstWhere((l) => l.date == date);
      } catch (_) {
        return null;
      }
    }

    try {
      final query = await _firestore
          .collection('logs')
          .where('sisterUid', isEqualTo: sisterUid)
          .where('date', isEqualTo: date)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return LogModel.fromFirestore(query.docs.first);
    } catch (e) {
      debugPrint('FirestoreService.getLogByDate error: $e');
      return null;
    }
  }

  Stream<List<LogModel>> watchLogs(String sisterUid, {int limit = 30}) {
    if (_firestore == null) {
      _logControllers.putIfAbsent(
        sisterUid,
        () => StreamController<List<LogModel>>.broadcast(),
      );
      final cached = _mockLogs[sisterUid] ?? [];
      Future.microtask(() => _logControllers[sisterUid]?.add(cached));
      return _logControllers[sisterUid]!.stream;
    }

    return _firestore
        .collection('logs')
        .where('sisterUid', isEqualTo: sisterUid)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => LogModel.fromFirestore(doc)).toList());
  }

  // =========================================================================
  // ACHIEVEMENTS
  // =========================================================================

  Stream<List<AchievementModel>> watchAchievements(String sisterUid) {
    if (_firestore == null) {
      _achievementControllers.putIfAbsent(
        sisterUid,
        () => StreamController<List<AchievementModel>>.broadcast(),
      );
      final cached = _mockAchievements[sisterUid] ?? [];
      Future.microtask(() => _achievementControllers[sisterUid]?.add(cached));
      return _achievementControllers[sisterUid]!.stream;
    }

    return _firestore
        .collection('achievements')
        .where('sisterUid', isEqualTo: sisterUid)
        .orderBy('unlockedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AchievementModel.fromFirestore(doc)).toList());
  }

  Future<void> unlockAchievement(AchievementModel achievement) async {
    if (_firestore == null) {
      final list = _mockAchievements.putIfAbsent(achievement.sisterUid, () => []);
      if (!list.any((a) => a.badgeId == achievement.badgeId)) {
        list.add(achievement);
        _achievementControllers[achievement.sisterUid]?.add(List.unmodifiable(list));
      }
      return;
    }

    try {
      await _firestore
          .collection('achievements')
          .doc(achievement.id)
          .set(achievement.toFirestore());
    } catch (e) {
      debugPrint('FirestoreService.unlockAchievement error: $e');
    }
  }
}
