import '../models/developmental_stage.dart';
import '../models/user.dart';

/// Engine that resolves developmental stage from age/birthdate, adapts UI tone,
/// dynamically generates age-appropriate missions, and builds psychological guidance prompts.
class DevelopmentalStageEngine {
  DevelopmentalStageEngine._();

  /// Default birthdate for Maya: January 12, 2014 (Turning 12 on Jan 12, 2026)
  static final DateTime defaultBirthDate = DateTime(2014, 1, 12);

  /// Calculate exact age given a birthdate
  static int calculateAge(DateTime birthDate, [DateTime? currentDate]) {
    final now = currentDate ?? DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Resolves the active developmental stage for a user
  static DevelopmentalStage resolveStage({
    required User sister,
    DateTime? currentDate,
  }) {
    if (sister.simulatedAge != null) {
      return stageFromAge(sister.simulatedAge!);
    }

    final birthDate = DateTime.tryParse(sister.birthDate) ?? defaultBirthDate;
    final age = calculateAge(birthDate, currentDate);
    return stageFromAge(age);
  }

  /// Maps age integer to developmental stage
  static DevelopmentalStage stageFromAge(int age) {
    if (age < 15) {
      return DevelopmentalStage.middleSchool; // Ages 11–14
    } else if (age <= 18) {
      return DevelopmentalStage.highSchool; // Ages 15–18
    } else {
      return DevelopmentalStage.university; // Ages 19–23+
    }
  }

  /// Days remaining until the next birthday (e.g. January 12).
  /// Accurately truncates calendar dates and supports leap-year birthdays.
  static int daysUntilBirthday(DateTime birthDate, [DateTime? currentDate]) {
    final now = currentDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime makeBirthdayDate(int year) {
      if (birthDate.month == 2 && birthDate.day == 29) {
        final isLeap = (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0));
        if (!isLeap) {
          return DateTime(year, 2, 28);
        }
      }
      return DateTime(year, birthDate.month, birthDate.day);
    }

    DateTime nextBirthday = makeBirthdayDate(today.year);
    if (nextBirthday.isBefore(today)) {
      nextBirthday = makeBirthdayDate(today.year + 1);
    }
    return nextBirthday.difference(today).inDays;
  }

  /// Generates stage-specific daily missions aligned with developmental psychology
  static List<String> getStageMissionTitles(DevelopmentalStage stage) {
    switch (stage) {
      case DevelopmentalStage.middleSchool:
        return const [
          'Complete all homework before 7 PM 🎒',
          'Score 85%+ across school subjects ⭐',
          'Read a book or novel for 20 mins 📖',
          'Practice extracurricular passion (Violin / Coding) 🎻',
        ];
      case DevelopmentalStage.highSchool:
        return const [
          'Complete two 45-min Deep Focus study sessions ⏱️',
          'Review exam / AP concepts and flashcards 📝',
          'Track weekly academic project milestones 🎯',
          'Physical wellness & exercise habit (30 mins) 🏃‍♀️',
        ];
      case DevelopmentalStage.university:
        return const [
          'Master 90-min uninterrupted deep study block 🧠',
          'Advance semester research or course project 🔬',
          'Career & portfolio craft (Git, writing, or apps) 💼',
          'Mindful reflection & executive wellness 🧘‍♀️',
        ];
    }
  }

  /// Generates the psychological system prompt for AI coaching models
  static String buildSystemPrompt({
    required DevelopmentalStage stage,
    required String sisterName,
    int? currentAge,
  }) {
    final ageStr = currentAge != null ? ' (age $currentAge)' : '';
    switch (stage) {
      case DevelopmentalStage.middleSchool:
        return '''
You are the StarPath AI Companion for $sisterName$ageStr, currently in Middle School.
Psychological grounding: Early adolescence (Erikson: Industry vs. Inferiority, Piaget Formal Operations).
Tone: Warm, enthusiastic, encouraging, playful, celebratory, like a trusted wise big sibling.
Focus:
- Celebrate daily effort and consistency over innate ability (Carol Dweck Growth Mindset).
- Use vibrant cosmic space metaphors (stars, constellations, supernovas, rocket power).
- Connect good habits with tangible rewards (weekend screen time, fun family outings).
- Keep coaching advice concise (2-3 sentences), highly actionable, and energizing!
''';

      case DevelopmentalStage.highSchool:
        return '''
You are the StarPath AI Mentor for $sisterName$ageStr, currently in High School.
Psychological grounding: Identity, self-regulation & autonomy (Bandura Self-Efficacy, Metacognition).
Tone: Respectful, intelligent, cool, empowering, supporting autonomy rather than micromanaging.
Focus:
- Frame study challenges as strategic puzzles to solve.
- Promote self-directed time management (Pomodoro, deep work, spacing effect).
- Support balance between academic pressure (exams/SATs/AP) and mental wellness.
- Keep guidance grounded, clear, and focused on her personal agency and long-term aspirations.
''';

      case DevelopmentalStage.university:
        return '''
You are the StarPath Executive AI Advisor for $sisterName$ageStr, in University / Emerging Adulthood.
Psychological grounding: Self-Determination Theory (Deci & Ryan: Autonomy, Competence, Relatedness).
Tone: Sophisticated, insightful, professional yet deeply empathetic and motivating.
Focus:
- Inspire intrinsic mastery of complex subjects, GPA excellence, and intellectual curiosity.
- Connect academic achievements to real-world career trajectory, internships, and creative projects.
- Encourage deep work routines, stress resilience, and long-term life architecture.
- Keep reflections polished, thought-provoking, and deeply encouraging.
''';
    }
  }
}
