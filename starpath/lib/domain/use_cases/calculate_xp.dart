/// XP calculation use case — converts daily scores to XP awards.
class CalculateXp {
  CalculateXp._();

  /// Convert a daily score (0–100) to XP awarded.
  ///
  /// Matches the plan's XP table:
  ///   90–100 → 100 XP
  ///   75–89  → 75 XP
  ///   60–74  → 50 XP
  ///   45–59  → 25 XP
  ///   < 45   → 10 XP (always reward effort)
  static int fromScore(int score) {
    if (score >= 90) return 100;
    if (score >= 75) return 75;
    if (score >= 60) return 50;
    if (score >= 45) return 25;
    return 10;
  }
}
