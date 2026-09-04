import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore document model for an achievement/badge
class AchievementModel {
  final String id;
  final String sisterUid;
  final String badgeId;
  final String title;
  final String emoji;
  final DateTime? unlockedAt;
  final int xpAwarded;

  const AchievementModel({
    required this.id,
    required this.sisterUid,
    required this.badgeId,
    required this.title,
    required this.emoji,
    this.unlockedAt,
    required this.xpAwarded,
  });

  factory AchievementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AchievementModel(
      id: doc.id,
      sisterUid: data['sisterUid'] as String? ?? '',
      badgeId: data['badgeId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      emoji: data['emoji'] as String? ?? '🏆',
      unlockedAt: (data['unlockedAt'] as Timestamp?)?.toDate(),
      xpAwarded: (data['xpAwarded'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'sisterUid': sisterUid,
        'badgeId': badgeId,
        'title': title,
        'emoji': emoji,
        'unlockedAt': FieldValue.serverTimestamp(),
        'xpAwarded': xpAwarded,
      };
}

/// Catalog of all available badges
class BadgeCatalog {
  static const List<BadgeDefinition> badges = [
    BadgeDefinition(
        id: 'first_flame',
        title: 'First Flame',
        emoji: '🔥',
        description: 'First daily log submitted'),
    BadgeDefinition(
        id: 'scholar',
        title: 'Scholar',
        emoji: '📚',
        description: '5 consecutive days with 80+ score'),
    BadgeDefinition(
        id: 'star_student',
        title: 'Star Student',
        emoji: '🌟',
        description: 'First 90+ score day'),
    BadgeDefinition(
        id: 'comeback_kid',
        title: 'Comeback Kid',
        emoji: '💪',
        description: 'Log the day after a broken streak'),
    BadgeDefinition(
        id: 'perfectionist',
        title: 'Perfectionist',
        emoji: '🏆',
        description: '100/100 score day'),
    BadgeDefinition(
        id: 'month_warrior',
        title: 'Month Warrior',
        emoji: '📅',
        description: '30-day streak'),
    BadgeDefinition(
        id: 'on_point',
        title: 'On Point',
        emoji: '🎯',
        description: 'Complete all daily missions in a day'),
    BadgeDefinition(
        id: 'eagle_eye',
        title: 'Eagle Eye',
        emoji: '🦅',
        description: 'Weekly average ≥ 90'),
  ];
}

class BadgeDefinition {
  final String id;
  final String title;
  final String emoji;
  final String description;

  const BadgeDefinition({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
  });
}
