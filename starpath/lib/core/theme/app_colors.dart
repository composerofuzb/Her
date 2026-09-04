import 'package:flutter/material.dart';

/// StarPath color palette — cosmic/space dark theme
class AppColors {
  AppColors._();

  // ── Primary brand ──────────────────────────────────────────────────────────
  static const starGold = Color(0xFFFFC107);
  static const starGoldLight = Color(0xFFFFD54F);
  static const cosmicPurple = Color(0xFF6C63FF);
  static const cosmicPurpleLight = Color(0xFF9C95FF);
  static const deepSpace = Color(0xFF0D0D1A);
  static const nebulaDark = Color(0xFF1A1A2E);
  static const nebulaCard = Color(0xFF16213E);

  // ── XP / progress ──────────────────────────────────────────────────────────
  static const xpGreen = Color(0xFF00E676);
  static const xpGreenDark = Color(0xFF00B248);

  // ── Tier colors ────────────────────────────────────────────────────────────
  static const tierGold = Color(0xFFFFD700);
  static const tierSilver = Color(0xFFB0BEC5);
  static const tierBronze = Color(0xFFCD7F32);

  // ── Score gradient ─────────────────────────────────────────────────────────
  static const scoreRed = Color(0xFFEF5350);
  static const scoreOrange = Color(0xFFFF7043);
  static const scoreYellow = Color(0xFFFFCA28);
  static const scoreBlue = Color(0xFF42A5F5);
  static const scoreGreen = Color(0xFF66BB6A);

  // ── Streak flame ───────────────────────────────────────────────────────────
  static const flameYellow = Color(0xFFFFEB3B);
  static const flameOrange = Color(0xFFFF6D00);
  static const flameRed = Color(0xFFD32F2F);

  // ── Utility ────────────────────────────────────────────────────────────────
  static const white = Colors.white;
  static const transparent = Colors.transparent;

  /// Returns the score color for a given score value (0–100)
  static Color forScore(int score) {
    if (score >= 90) return scoreGreen;
    if (score >= 75) return scoreBlue;
    if (score >= 60) return scoreYellow;
    if (score >= 45) return scoreOrange;
    return scoreRed;
  }

  /// Returns the flame color based on streak days
  static Color forStreak(int days) {
    if (days >= 14) return flameRed;
    if (days >= 7) return flameOrange;
    return flameYellow;
  }

  /// Glassmorphism card border
  static Color get glassBorder => Colors.white.withOpacity(0.12);

  /// Glassmorphism card fill
  static Color get glassFill => Colors.white.withOpacity(0.05);
}
