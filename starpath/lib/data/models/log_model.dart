import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore document model for a daily log entry
class LogModel {
  final String id;
  final String sisterUid;
  final String guardianUid;
  final String date; // YYYY-MM-DD
  final Map<String, SubjectDataModel> subjects;
  final String behavior;
  final List<String> extras;
  final String? notes;
  final int score;
  final int xpAwarded;
  final List<String> missionsCompleted;
  final DateTime? createdAt;

  const LogModel({
    required this.id,
    required this.sisterUid,
    required this.guardianUid,
    required this.date,
    required this.subjects,
    required this.behavior,
    required this.extras,
    this.notes,
    required this.score,
    required this.xpAwarded,
    required this.missionsCompleted,
    this.createdAt,
  });

  factory LogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final subjectsRaw = data['subjects'] as Map<String, dynamic>? ?? {};

    return LogModel(
      id: doc.id,
      sisterUid: data['sisterUid'] as String? ?? '',
      guardianUid: data['guardianUid'] as String? ?? '',
      date: data['date'] as String? ?? '',
      subjects: subjectsRaw.map(
        (key, value) => MapEntry(
          key,
          SubjectDataModel.fromMap(value as Map<String, dynamic>),
        ),
      ),
      behavior: data['behavior'] as String? ?? 'neutral',
      extras: (data['extras'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      notes: data['notes'] as String?,
      score: (data['score'] as num?)?.toInt() ?? 0,
      xpAwarded: (data['xpAwarded'] as num?)?.toInt() ?? 0,
      missionsCompleted: (data['missionsCompleted'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'sisterUid': sisterUid,
        'guardianUid': guardianUid,
        'date': date,
        'subjects': subjects.map((k, v) => MapEntry(k, v.toMap())),
        'behavior': behavior,
        'extras': extras,
        'notes': notes,
        'score': score,
        'xpAwarded': xpAwarded,
        'missionsCompleted': missionsCompleted,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

class SubjectDataModel {
  final double mark;
  final String homework; // 'yes' | 'partial' | 'no'

  const SubjectDataModel({
    required this.mark,
    required this.homework,
  });

  factory SubjectDataModel.fromMap(Map<String, dynamic> map) =>
      SubjectDataModel(
        mark: (map['mark'] as num?)?.toDouble() ?? 0,
        homework: map['homework'] as String? ?? 'no',
      );

  Map<String, dynamic> toMap() => {
        'mark': mark,
        'homework': homework,
      };
}
