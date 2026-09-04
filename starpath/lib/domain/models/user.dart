import 'character_customization.dart';

/// Domain model for a StarPath user.
/// Immutable — create new instances for updates.
class User {
  final String uid;
  final String displayName;
  final String role; // 'guardian' | 'sister'
  final String? linkedUid; // guardian's sister UID or vice versa
  final int xp;
  final int level;
  final int streakDays;
  final String? lastLogDate; // YYYY-MM-DD
  final int streakFreezes;
  final int avatarStage; // 0-4: seedling → star
  final String birthDate; // YYYY-MM-DD (Default: 2014-01-12, turning 12 on Jan 12)
  final int? simulatedAge; // Optional stage simulation / preview
  final CharacterCustomization character;

  const User({
    required this.uid,
    required this.displayName,
    required this.role,
    this.linkedUid,
    this.xp = 0,
    this.level = 1,
    this.streakDays = 0,
    this.lastLogDate,
    this.streakFreezes = 1,
    this.avatarStage = 0,
    this.birthDate = '2014-01-12',
    this.simulatedAge,
    this.character = const CharacterCustomization(),
  });

  bool get isGuardian => role == 'guardian';
  bool get isSister => role == 'sister';

  /// XP needed to reach the next level
  int get xpForNextLevel => xpThresholds[level] ?? 9999;

  /// XP needed to reach the current level
  int get xpForCurrentLevel => xpThresholds[level - 1] ?? 0;

  /// XP progress within current level (0 → xpForNextLevel - xpForCurrentLevel)
  int get xpInCurrentLevel => xp - xpForCurrentLevel;

  /// Total XP span for this level
  int get levelSpan => xpForNextLevel - xpForCurrentLevel;

  /// Progress fraction 0.0–1.0
  double get levelProgress {
    if (levelSpan <= 0) return 1.0;
    return (xpInCurrentLevel / levelSpan).clamp(0.0, 1.0);
  }

  String get levelTitle {
    switch (level) {
      case 1:
        return 'Seedling';
      case 2:
        return 'Sprout';
      case 3:
        return 'Sapling';
      case 4:
        return 'Rising Star';
      case 5:
        return 'Bright Star';
      case 6:
        return 'Shining Star';
      case 7:
        return 'Super Nova';
      case 8:
        return 'Galaxy Born';
      case 9:
        return 'Cosmic Legend';
      default:
        return 'Star Master';
    }
  }

  String get avatarEmoji {
    switch (avatarStage) {
      case 0:
        return '🌱';
      case 1:
        return '🌿';
      case 2:
        return '🌳';
      case 3:
        return '⭐';
      default:
        return '🌌';
    }
  }

  User copyWith({
    String? uid,
    String? displayName,
    String? role,
    String? linkedUid,
    int? xp,
    int? level,
    int? streakDays,
    String? lastLogDate,
    int? streakFreezes,
    int? avatarStage,
    String? birthDate,
    int? simulatedAge,
    bool clearSimulatedAge = false,
    CharacterCustomization? character,
  }) {
    return User(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      linkedUid: linkedUid ?? this.linkedUid,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streakDays: streakDays ?? this.streakDays,
      lastLogDate: lastLogDate ?? this.lastLogDate,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      avatarStage: avatarStage ?? this.avatarStage,
      birthDate: birthDate ?? this.birthDate,
      simulatedAge: clearSimulatedAge ? null : (simulatedAge ?? this.simulatedAge),
      character: character ?? this.character,
    );
  }

  /// XP thresholds per level (Fibonacci-ish scaling)
  static const Map<int, int> xpThresholds = {
    0: 0,
    1: 100,
    2: 250,
    3: 500,
    4: 900,
    5: 1500,
    6: 2500,
    7: 4000,
    8: 6000,
    9: 9000,
    10: 13000,
  };

  /// Compute level from total XP
  static int levelFromXp(int xp) {
    int level = 1;
    for (final entry in xpThresholds.entries) {
      if (xp >= entry.value && entry.key > 0) {
        level = entry.key;
      }
    }
    return level;
  }

  /// Compute avatar stage from level
  static int avatarStageFromLevel(int level) {
    if (level >= 8) return 4;
    if (level >= 6) return 3;
    if (level >= 4) return 2;
    if (level >= 2) return 1;
    return 0;
  }
}
