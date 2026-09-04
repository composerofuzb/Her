import 'package:flutter/material.dart';

/// Developmental stages spanning ages 11 to 23+ (University & Emerging Adulthood)
/// Grounded in Piaget's Cognitive Development, Erikson's Psychosocial Stages,
/// and Deci & Ryan's Self-Determination Theory (SDT).
enum DevelopmentalStage {
  /// Ages 11–14: Transition from childhood to early adolescence.
  /// Characterized by emerging identity, sensitivity to tangible rewards,
  /// requirement for playful gamification, guided daily missions, and positive reinforcement.
  middleSchool,

  /// Ages 15–18: Mid-to-late adolescence.
  /// Characterized by metacognition, demand for autonomy and self-regulation,
  /// project and exam milestones (SAT/Finals), deep study sprints, and personal agency.
  highSchool,

  /// Ages 19–23+: Emerging adulthood & higher education.
  /// Characterized by intrinsic motivation (Autonomy, Competence, Relatedness),
  /// executive habit mastery, GPA and credit tracking, and career/internship skills.
  university,
}

extension DevelopmentalStageX on DevelopmentalStage {
  String get title {
    switch (this) {
      case DevelopmentalStage.middleSchool:
        return 'Cosmic Explorer';
      case DevelopmentalStage.highSchool:
        return 'Starlight Scholar';
      case DevelopmentalStage.university:
        return 'Cosmic Master';
    }
  }

  String get stageName {
    switch (this) {
      case DevelopmentalStage.middleSchool:
        return 'Middle School';
      case DevelopmentalStage.highSchool:
        return 'High School';
      case DevelopmentalStage.university:
        return 'University & Career';
    }
  }

  String get ageRangeDescription {
    switch (this) {
      case DevelopmentalStage.middleSchool:
        return 'Ages 11–14';
      case DevelopmentalStage.highSchool:
        return 'Ages 15–18';
      case DevelopmentalStage.university:
        return 'Ages 19–23+';
    }
  }

  String get subtitle {
    switch (this) {
      case DevelopmentalStage.middleSchool:
        return 'Playful Gamification & Tangible Rewards';
      case DevelopmentalStage.highSchool:
        return 'Autonomy, Focus & Exam Mastery';
      case DevelopmentalStage.university:
        return 'Intrinsic Mastery, Career & Life Design';
    }
  }

  String get motto {
    switch (this) {
      case DevelopmentalStage.middleSchool:
        return 'Level up your daily powers and discover what makes you shine! 🚀';
      case DevelopmentalStage.highSchool:
        return 'Master your focus and craft your own path forward. 🎯';
      case DevelopmentalStage.university:
        return 'Architect your knowledge, own your craft, and leave your mark. 🌌';
    }
  }

  String get emoji {
    switch (this) {
      case DevelopmentalStage.middleSchool:
        return '⭐';
      case DevelopmentalStage.highSchool:
        return '🪐';
      case DevelopmentalStage.university:
        return '👑';
    }
  }

  /// Psychological research underpinning this developmental stage
  String get psychologyFramework {
    switch (this) {
      case DevelopmentalStage.middleSchool:
        return 'Piaget Formal Operational Transition & Erikson Early Identity (Industry vs. Inferiority). '
            'Benefits from immediate cause-and-effect loops, celebratory visual feedback, tangible weekend privileges, and friendly avatar companionship.';
      case DevelopmentalStage.highSchool:
        return 'Self-Regulation & Cognitive Metacognition (Bandura Self-Efficacy & Vygotsky ZPD). '
            'Thrives on autonomy-supportive feedback, self-chosen study goals, project sprints, and non-judgmental tracking.';
      case DevelopmentalStage.university:
        return 'Self-Determination Theory (Deci & Ryan: Autonomy, Competence, Relatedness) & Arnett Emerging Adulthood. '
            'Replaces extrinsic tokenism with deep habit architecture, GPA mastery, career milestones, and intrinsic reflection.';
    }
  }

  /// Stage-appropriate core subjects
  List<String> get defaultSubjects {
    switch (this) {
      case DevelopmentalStage.middleSchool:
        return const ['Math', 'Science', 'English', 'History', 'PE'];
      case DevelopmentalStage.highSchool:
        return const [
          'AP Calculus',
          'Physics & Chem',
          'Literature & Essay',
          'World History',
          'Foreign Lang',
          'Exam & SAT Prep',
        ];
      case DevelopmentalStage.university:
        return const [
          'Major Core Courses',
          'Algorithms & Tech',
          'Research & Papers',
          'Career & Projects',
          'Health & Fitness',
        ];
    }
  }

  /// Extracurricular and growth activities suited to stage
  List<String> get recommendedExtras {
    switch (this) {
      case DevelopmentalStage.middleSchool:
        return const [
          'Reading 20 mins',
          'Violin Practice',
          'Duolingo Streak',
          'Art & Drawing',
          'Robotics Club',
        ];
      case DevelopmentalStage.highSchool:
        return const [
          'Debate & Model UN',
          'Coding Portfolio',
          'Gym & Athletics',
          'Volunteer Service',
          'College Applications',
        ];
      case DevelopmentalStage.university:
        return const [
          'Internship Apps',
          'Open Source / Portfolio',
          'Networking & Mentorship',
          'Research Publication',
          'Deep Work Sprint',
        ];
    }
  }

  /// Stage-tuned theme colors
  Color get primaryColor {
    switch (this) {
      case DevelopmentalStage.middleSchool:
        return const Color(0xFF6C63FF); // Vibrant Cosmic Purple
      case DevelopmentalStage.highSchool:
        return const Color(0xFF4F46E5); // Sleek Electric Indigo
      case DevelopmentalStage.university:
        return const Color(0xFF2563EB); // Refined Sapphire Blue
    }
  }

  Color get secondaryColor {
    switch (this) {
      case DevelopmentalStage.middleSchool:
        return const Color(0xFFFFC107); // Warm Star Gold
      case DevelopmentalStage.highSchool:
        return const Color(0xFF06B6D4); // Neon Cyan
      case DevelopmentalStage.university:
        return const Color(0xFFF59E0B); // Amber Bronze
    }
  }

  Color get cardColor {
    switch (this) {
      case DevelopmentalStage.middleSchool:
        return const Color(0xFF16213E);
      case DevelopmentalStage.highSchool:
        return const Color(0xFF131B30);
      case DevelopmentalStage.university:
        return const Color(0xFF0F172A);
    }
  }
}
