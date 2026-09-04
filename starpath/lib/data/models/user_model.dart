import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore document model for a user
class UserModel {
  final String uid;
  final String displayName;
  final String role; // 'guardian' | 'sister'
  final String? linkedSisterUid;
  final String? linkedGuardianUid;
  final int xp;
  final int level;
  final int streakDays;
  final String? lastLogDate;
  final int streakFreezes;
  final int avatarStage;
  final List<String> subjects;
  final String currencySymbol;
  final String birthDate;
  final int? simulatedAge;
  final Map<String, dynamic>? characterData;

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.role,
    this.linkedSisterUid,
    this.linkedGuardianUid,
    this.xp = 0,
    this.level = 1,
    this.streakDays = 0,
    this.lastLogDate,
    this.streakFreezes = 1,
    this.avatarStage = 0,
    this.subjects = const ['Math', 'Science', 'English', 'History', 'PE'],
    this.currencySymbol = '\$',
    this.birthDate = '2014-01-12',
    this.simulatedAge,
    this.characterData,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      role: data['role'] as String? ?? 'sister',
      linkedSisterUid: data['linkedSisterUid'] as String?,
      linkedGuardianUid: data['linkedGuardianUid'] as String?,
      xp: (data['xp'] as num?)?.toInt() ?? 0,
      level: (data['level'] as num?)?.toInt() ?? 1,
      streakDays: (data['streakDays'] as num?)?.toInt() ?? 0,
      lastLogDate: data['lastLogDate'] as String?,
      streakFreezes: (data['streakFreezes'] as num?)?.toInt() ?? 1,
      avatarStage: (data['avatarStage'] as num?)?.toInt() ?? 0,
      subjects: (data['subjects'] as List<dynamic>?)
              ?.map((s) => s as String)
              .toList() ??
          const ['Math', 'Science', 'English', 'History', 'PE'],
      currencySymbol: data['currencySymbol'] as String? ?? '\$',
      birthDate: data['birthDate'] as String? ?? '2014-01-12',
      simulatedAge: (data['simulatedAge'] as num?)?.toInt(),
      characterData: data['characterData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'displayName': displayName,
        'role': role,
        'linkedSisterUid': linkedSisterUid,
        'linkedGuardianUid': linkedGuardianUid,
        'xp': xp,
        'level': level,
        'streakDays': streakDays,
        'lastLogDate': lastLogDate,
        'streakFreezes': streakFreezes,
        'avatarStage': avatarStage,
        'subjects': subjects,
        'currencySymbol': currencySymbol,
        'birthDate': birthDate,
        'simulatedAge': simulatedAge,
        'characterData': characterData,
      };

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? role,
    String? linkedSisterUid,
    String? linkedGuardianUid,
    int? xp,
    int? level,
    int? streakDays,
    String? lastLogDate,
    int? streakFreezes,
    int? avatarStage,
    List<String>? subjects,
    String? currencySymbol,
    String? birthDate,
    int? simulatedAge,
    bool clearSimulatedAge = false,
    Map<String, dynamic>? characterData,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      linkedSisterUid: linkedSisterUid ?? this.linkedSisterUid,
      linkedGuardianUid: linkedGuardianUid ?? this.linkedGuardianUid,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streakDays: streakDays ?? this.streakDays,
      lastLogDate: lastLogDate ?? this.lastLogDate,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      avatarStage: avatarStage ?? this.avatarStage,
      subjects: subjects ?? this.subjects,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      birthDate: birthDate ?? this.birthDate,
      simulatedAge: clearSimulatedAge ? null : (simulatedAge ?? this.simulatedAge),
      characterData: characterData ?? this.characterData,
    );
  }
}
