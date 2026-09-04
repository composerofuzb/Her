import 'developmental_stage.dart';

/// Mission types available in StarPath
enum MissionType {
  logAllSubjects,
  averageMarkAbove80,
  allHomeworkComplete,
  twoBonusActivities,
  logBefore8pm,
}

extension MissionTypeX on MissionType {
  String get title {
    switch (this) {
      case MissionType.logAllSubjects:
        return 'Log all subjects today';
      case MissionType.averageMarkAbove80:
        return 'Average mark ≥ 80';
      case MissionType.allHomeworkComplete:
        return 'Complete all homework';
      case MissionType.twoBonusActivities:
        return 'Do 2+ bonus activities';
      case MissionType.logBefore8pm:
        return 'Log before 8 PM';
    }
  }

  int get xpReward {
    switch (this) {
      case MissionType.logAllSubjects:
        return 20;
      case MissionType.averageMarkAbove80:
        return 30;
      case MissionType.allHomeworkComplete:
        return 25;
      case MissionType.twoBonusActivities:
        return 20;
      case MissionType.logBefore8pm:
        return 10;
    }
  }

  String get emoji {
    switch (this) {
      case MissionType.logAllSubjects:
        return '📚';
      case MissionType.averageMarkAbove80:
        return '⭐';
      case MissionType.allHomeworkComplete:
        return '✏️';
      case MissionType.twoBonusActivities:
        return '🎯';
      case MissionType.logBefore8pm:
        return '⏰';
    }
  }
}

/// Domain model for a daily mission
class Mission {
  final String id;
  final String title;
  final int xpReward;
  final bool completed;
  final MissionType type;
  final String emoji;

  const Mission({
    required this.id,
    required this.title,
    required this.xpReward,
    required this.completed,
    required this.type,
    required this.emoji,
  });

  Mission copyWith({
    String? id,
    String? title,
    int? xpReward,
    bool? completed,
    MissionType? type,
    String? emoji,
  }) {
    return Mission(
      id: id ?? this.id,
      title: title ?? this.title,
      xpReward: xpReward ?? this.xpReward,
      completed: completed ?? this.completed,
      type: type ?? this.type,
      emoji: emoji ?? this.emoji,
    );
  }

  /// Factory to create default missions for a day
  static List<Mission> defaultMissions() {
    return MissionType.values
        .map((type) => Mission(
              id: type.name,
              title: type.title,
              xpReward: type.xpReward,
              completed: false,
              type: type,
              emoji: type.emoji,
            ))
        .toList();
  }

  /// Factory to create developmental stage-adapted daily missions
  static List<Mission> stageMissions(DevelopmentalStage stage) {
    switch (stage) {
      case DevelopmentalStage.middleSchool:
        return const [
          Mission(
            id: 'logAllSubjects',
            title: 'Log all daily school subjects 📚',
            xpReward: 20,
            completed: false,
            type: MissionType.logAllSubjects,
            emoji: '📚',
          ),
          Mission(
            id: 'averageMarkAbove80',
            title: 'Average mark ≥ 80% ⭐',
            xpReward: 30,
            completed: false,
            type: MissionType.averageMarkAbove80,
            emoji: '⭐',
          ),
          Mission(
            id: 'allHomeworkComplete',
            title: 'Complete all homework before 7 PM 🎒',
            xpReward: 25,
            completed: false,
            type: MissionType.allHomeworkComplete,
            emoji: '🎒',
          ),
          Mission(
            id: 'twoBonusActivities',
            title: 'Do 2+ bonus activities (Reading / Music) 🎨',
            xpReward: 20,
            completed: false,
            type: MissionType.twoBonusActivities,
            emoji: '🎯',
          ),
          Mission(
            id: 'logBefore8pm',
            title: 'Log daily performance before 8 PM ⏰',
            xpReward: 10,
            completed: false,
            type: MissionType.logBefore8pm,
            emoji: '⏰',
          ),
        ];

      case DevelopmentalStage.highSchool:
        return const [
          Mission(
            id: 'logAllSubjects',
            title: 'Log all coursework & AP subjects 📚',
            xpReward: 20,
            completed: false,
            type: MissionType.logAllSubjects,
            emoji: '📚',
          ),
          Mission(
            id: 'averageMarkAbove80',
            title: 'Academic sprint mastery ≥ 80% 🎯',
            xpReward: 30,
            completed: false,
            type: MissionType.averageMarkAbove80,
            emoji: '🎯',
          ),
          Mission(
            id: 'allHomeworkComplete',
            title: 'Complete two 45-min Deep Focus sessions ⏱️',
            xpReward: 25,
            completed: false,
            type: MissionType.allHomeworkComplete,
            emoji: '📝',
          ),
          Mission(
            id: 'twoBonusActivities',
            title: '2+ self-directed growth sessions (Code / Debate) ⚡',
            xpReward: 20,
            completed: false,
            type: MissionType.twoBonusActivities,
            emoji: '⚡',
          ),
          Mission(
            id: 'logBefore8pm',
            title: 'Log focus review before 8 PM ⏱️',
            xpReward: 10,
            completed: false,
            type: MissionType.logBefore8pm,
            emoji: '⏱️',
          ),
        ];

      case DevelopmentalStage.university:
        return const [
          Mission(
            id: 'logAllSubjects',
            title: 'Log course credits & research modules 🔬',
            xpReward: 20,
            completed: false,
            type: MissionType.logAllSubjects,
            emoji: '🔬',
          ),
          Mission(
            id: 'averageMarkAbove80',
            title: 'GPA & exam excellence ≥ 80% 🎓',
            xpReward: 30,
            completed: false,
            type: MissionType.averageMarkAbove80,
            emoji: '🎓',
          ),
          Mission(
            id: 'allHomeworkComplete',
            title: 'Master 90-min uninterrupted deep study block 🧠',
            xpReward: 25,
            completed: false,
            type: MissionType.allHomeworkComplete,
            emoji: '💼',
          ),
          Mission(
            id: 'twoBonusActivities',
            title: '2+ executive habits (Portfolio / Research Sprint) 💼',
            xpReward: 20,
            completed: false,
            type: MissionType.twoBonusActivities,
            emoji: '🧠',
          ),
          Mission(
            id: 'logBefore8pm',
            title: 'Log mindful executive review before 8 PM 🌌',
            xpReward: 10,
            completed: false,
            type: MissionType.logBefore8pm,
            emoji: '🌌',
          ),
        ];
    }
  }
}
