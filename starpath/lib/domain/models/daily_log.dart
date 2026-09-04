/// Subject performance data for a single subject in a daily log
class SubjectData {
  final double mark; // 0–100
  final String homework; // 'yes' | 'partial' | 'no'

  const SubjectData({
    required this.mark,
    required this.homework,
  });

  SubjectData copyWith({double? mark, String? homework}) {
    return SubjectData(
      mark: mark ?? this.mark,
      homework: homework ?? this.homework,
    );
  }

  Map<String, dynamic> toMap() => {
        'mark': mark,
        'homework': homework,
      };

  factory SubjectData.fromMap(Map<String, dynamic> map) => SubjectData(
        mark: (map['mark'] as num?)?.toDouble() ?? 0,
        homework: map['homework'] as String? ?? 'no',
      );
}

/// Domain model for a single daily log entry
class DailyLog {
  final String id;
  final String date; // YYYY-MM-DD
  final Map<String, SubjectData> subjects;
  final String behavior; // 'excellent' | 'good' | 'neutral' | 'poor' | 'bad'
  final List<String> extras;
  final String? notes;
  final int score; // 0–100
  final int xpAwarded;
  final List<String> missionsCompleted;
  final String sisterUid;
  final String guardianUid;

  const DailyLog({
    required this.id,
    required this.date,
    required this.subjects,
    required this.behavior,
    required this.extras,
    this.notes,
    required this.score,
    required this.xpAwarded,
    required this.missionsCompleted,
    required this.sisterUid,
    required this.guardianUid,
  });

  DailyLog copyWith({
    String? id,
    String? date,
    Map<String, SubjectData>? subjects,
    String? behavior,
    List<String>? extras,
    String? notes,
    int? score,
    int? xpAwarded,
    List<String>? missionsCompleted,
    String? sisterUid,
    String? guardianUid,
  }) {
    return DailyLog(
      id: id ?? this.id,
      date: date ?? this.date,
      subjects: subjects ?? this.subjects,
      behavior: behavior ?? this.behavior,
      extras: extras ?? this.extras,
      notes: notes ?? this.notes,
      score: score ?? this.score,
      xpAwarded: xpAwarded ?? this.xpAwarded,
      missionsCompleted: missionsCompleted ?? this.missionsCompleted,
      sisterUid: sisterUid ?? this.sisterUid,
      guardianUid: guardianUid ?? this.guardianUid,
    );
  }
}
