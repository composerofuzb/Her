import {
  format,
  startOfWeek,
  endOfWeek,
  startOfMonth,
  endOfMonth,
  eachDayOfInterval,
  eachWeekOfInterval,
  getISOWeek,
  getYear,
  parseISO,
  isValid,
} from 'date-fns'

/**
 * Format a date string (YYYY-MM-DD) to display string.
 */
export function displayDate(dateStr) {
  const d = parseISO(dateStr)
  return isValid(d) ? format(d, 'EEE, MMM d yyyy') : dateStr
}

/**
 * Today as YYYY-MM-DD string.
 */
export function todayStr() {
  return format(new Date(), 'yyyy-MM-dd')
}

/**
 * Get all days in the current week (Mon–Sun) as YYYY-MM-DD strings.
 */
export function currentWeekDays() {
  const now = new Date()
  const start = startOfWeek(now, { weekStartsOn: 1 })
  const end = endOfWeek(now, { weekStartsOn: 1 })
  return eachDayOfInterval({ start, end }).map(d => format(d, 'yyyy-MM-dd'))
}

/**
 * Get all days in a given month as YYYY-MM-DD strings.
 * @param {number} year
 * @param {number} month  0-indexed
 */
export function monthDays(year, month) {
  const start = startOfMonth(new Date(year, month, 1))
  const end = endOfMonth(start)
  return eachDayOfInterval({ start, end }).map(d => format(d, 'yyyy-MM-dd'))
}

/**
 * Group an array of log entries by ISO week key "YYYY-Www".
 * @param {Object[]} logs
 * @returns {Object} { 'YYYY-W01': [...logs] }
 */
export function groupByWeek(logs) {
  const groups = {}
  for (const log of logs) {
    const d = parseISO(log.date)
    if (!isValid(d)) continue
    const key = `${getYear(d)}-W${String(getISOWeek(d)).padStart(2, '0')}`
    if (!groups[key]) groups[key] = []
    groups[key].push(log)
  }
  return groups
}

/**
 * Group an array of log entries by month key "YYYY-MM".
 * @param {Object[]} logs
 * @returns {Object}
 */
export function groupByMonth(logs) {
  const groups = {}
  for (const log of logs) {
    const key = log.date.slice(0, 7)
    if (!groups[key]) groups[key] = []
    groups[key].push(log)
  }
  return groups
}

/**
 * Get an array of week start dates (Mon) for a given month.
 * @param {number} year
 * @param {number} month 0-indexed
 */
export function weeksInMonth(year, month) {
  const start = startOfMonth(new Date(year, month, 1))
  const end = endOfMonth(start)
  return eachWeekOfInterval({ start, end }, { weekStartsOn: 1 })
}

/**
 * Short label for a week key, e.g. "W12 (Mar 18–24)"
 */
export function weekLabel(weekKey) {
  const [year, wStr] = weekKey.split('-W')
  return `Week ${wStr}, ${year}`
}
