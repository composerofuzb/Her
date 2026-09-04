/**
 * Pure scoring utilities.
 * All functions are side-effect free — safe to unit test.
 */

/**
 * Calculate a daily performance score (0–100) from a log entry.
 *
 * @param {Object} entry  - A daily log entry from the store
 * @param {Object} weights - { academics, homework, behavior, extras } (must sum to 1)
 * @returns {number} score 0–100
 */
export function calcDailyScore(entry, weights) {
  const w = weights || { academics: 0.50, homework: 0.20, behavior: 0.15, extras: 0.15 }

  // ── Academics ──────────────────────────────────────────────────────────────
  // Average of all subject marks (0–100 scale)
  const subjectScores = Object.values(entry.subjects || {})
  const academicScore =
    subjectScores.length > 0
      ? subjectScores.reduce((sum, s) => sum + (s.mark ?? 0), 0) / subjectScores.length
      : 0

  // ── Homework ───────────────────────────────────────────────────────────────
  // yes=1, partial=0.5, no=0 — averaged across subjects
  const hwValues = { yes: 1, partial: 0.5, no: 0 }
  const hwScores = Object.values(entry.subjects || {}).map(s => hwValues[s.homework] ?? 0)
  const hwScore =
    hwScores.length > 0
      ? (hwScores.reduce((sum, v) => sum + v, 0) / hwScores.length) * 100
      : 0

  // ── Behavior ───────────────────────────────────────────────────────────────
  const behaviorMap = { excellent: 100, good: 80, neutral: 60, poor: 30, bad: 0 }
  const behaviorScore = behaviorMap[entry.behavior] ?? 60

  // ── Extras (bonus, capped at 100 for this component) ──────────────────────
  const extrasChecked = (entry.extras || []).length
  const extrasScore = Math.min(extrasChecked * 25, 100)

  const raw =
    academicScore * w.academics +
    hwScore * w.homework +
    behaviorScore * w.behavior +
    extrasScore * w.extras

  return Math.round(Math.min(100, Math.max(0, raw)))
}

/**
 * Calculate the average score for a given array of daily scores.
 * @param {number[]} scores
 * @returns {number}
 */
export function calcWeeklyScore(scores) {
  if (!scores || scores.length === 0) return 0
  return Math.round(scores.reduce((sum, s) => sum + s, 0) / scores.length)
}

/**
 * Determine the reward tier for a given score.
 * @param {number} score 0–100
 * @param {Array}  tiers - from settings store
 * @returns {Object} tier object
 */
export function getTier(score, tiers) {
  if (!tiers || tiers.length === 0) return null
  // tiers are sorted by minScore desc
  return (
    [...tiers].sort((a, b) => b.minScore - a.minScore).find(t => score >= t.minScore) || tiers[tiers.length - 1]
  )
}

/**
 * Score label with color class (Tailwind).
 */
export function scoreColor(score) {
  if (score >= 90) return { bg: 'bg-emerald-100', text: 'text-emerald-700', ring: 'ring-emerald-300' }
  if (score >= 75) return { bg: 'bg-blue-100', text: 'text-blue-700', ring: 'ring-blue-300' }
  if (score >= 60) return { bg: 'bg-yellow-100', text: 'text-yellow-700', ring: 'ring-yellow-300' }
  if (score >= 45) return { bg: 'bg-orange-100', text: 'text-orange-700', ring: 'ring-orange-300' }
  return { bg: 'bg-red-100', text: 'text-red-700', ring: 'ring-red-300' }
}

/**
 * Heatmap intensity class based on score.
 */
export function heatmapClass(score) {
  if (score == null) return 'bg-slate-100'
  if (score >= 90) return 'bg-emerald-500'
  if (score >= 75) return 'bg-emerald-300'
  if (score >= 60) return 'bg-yellow-300'
  if (score >= 45) return 'bg-orange-300'
  return 'bg-red-400'
}
