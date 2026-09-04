import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../domain/models/user.dart';
import '../services/firestore_service.dart';
import 'auth_repository.dart';

import '../../domain/models/character_customization.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  try {
    if (Firebase.apps.isNotEmpty) {
      return FirestoreService(firestore: FirebaseFirestore.instance);
    }
  } catch (e) {
    debugPrint('Firebase not available for FirestoreService: $e');
  }
  return FirestoreService();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});

/// Watches the current user's profile based on auth state
final currentUserProvider = StreamProvider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  final uid = authState.value;
  if (uid == null) return Stream.value(null);

  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.watchUser(uid);
});

/// Watches the sister user profile (either current user if sister, or linked sister if guardian)
final sisterUserProvider = StreamProvider<User?>((ref) {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) return Stream.value(null);

  final userRepo = ref.watch(userRepositoryProvider);
  if (currentUser.isSister) {
    return userRepo.watchUser(currentUser.uid);
  }

  // Guardian: watch linked sister
  final sisterUid = currentUser.linkedUid;
  if (sisterUid == null) return Stream.value(null);
  return userRepo.watchUser(sisterUid);
});

class UserRepository {
  final FirestoreService _firestoreService;

  UserRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  User _toDomain(UserModel model) {
    return User(
      uid: model.uid,
      displayName: model.displayName,
      role: model.role,
      linkedUid: model.isGuardian ? model.linkedSisterUid : model.linkedGuardianUid,
      xp: model.xp,
      level: model.level,
      streakDays: model.streakDays,
      lastLogDate: model.lastLogDate,
      streakFreezes: model.streakFreezes,
      avatarStage: model.avatarStage,
      birthDate: model.birthDate,
      simulatedAge: model.simulatedAge,
      character: CharacterCustomization.fromMap(model.characterData),
    );
  }

  UserModel _toModel(User domain, {List<String>? subjects, String? currencySymbol}) {
    return UserModel(
      uid: domain.uid,
      displayName: domain.displayName,
      role: domain.role,
      linkedSisterUid: domain.isGuardian ? domain.linkedUid : null,
      linkedGuardianUid: domain.isSister ? domain.linkedUid : null,
      xp: domain.xp,
      level: domain.level,
      streakDays: domain.streakDays,
      lastLogDate: domain.lastLogDate,
      streakFreezes: domain.streakFreezes,
      avatarStage: domain.avatarStage,
      subjects: subjects ?? const ['Math', 'Science', 'English', 'History', 'PE'],
      currencySymbol: currencySymbol ?? '\$',
      birthDate: domain.birthDate,
      simulatedAge: domain.simulatedAge,
      characterData: domain.character.toMap(),
    );
  }

  Future<User?> getUser(String uid) async {
    final model = await _firestoreService.getUser(uid);
    return model != null ? _toDomain(model) : null;
  }

  Future<void> createUser(User user, {List<String>? subjects, String? currencySymbol}) {
    return _firestoreService.createUser(
      _toModel(user, subjects: subjects, currencySymbol: currencySymbol),
    );
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) {
    return _firestoreService.updateUser(uid, data);
  }

  Future<void> updateCharacter(String uid, CharacterCustomization character) {
    return _firestoreService.updateUser(uid, {
      'characterData': character.toMap(),
    });
  }

  Future<void> updateSimulatedAge(String uid, int? age) {
    return _firestoreService.updateUser(uid, {
      'simulatedAge': age,
    });
  }

  Stream<User?> watchUser(String uid) {
    return _firestoreService.watchUser(uid).map((model) => model != null ? _toDomain(model) : null);
  }
}

extension on UserModel {
  bool get isGuardian => role == 'guardian';
}

