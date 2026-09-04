import { create } from 'zustand'
import { persist, createJSONStorage } from 'zustand/middleware'
import { calcDailyScore } from '../utils/scoring'
import { todayStr } from '../utils/dateHelpers'

// ─── Default configuration ─────────────────────────────────────────────────

const DEFAULT_SUBJECTS = [
  { id: 'math', name: 'Math' },
  { id: 'science', name: 'Science' },
  { id: 'english', name: 'English' },
  { id: 'history', name: 'History' },
  { id: 'pe', name: 'PE' },
]

const DEFAULT_EXTRAS = [
  'Read a book (30+ min)',
  'Helped with house chores',
  'Exercised / sport',
  'Practiced an instrument or creative skill',
  'Studied extra beyond homework',
]

const DEFAULT_TIERS = [
  { id: 'excellent', name: 'Excellent', emoji: '🥇', minScore: 90, phoneMinutes: 120, money: 10, color: 'emerald' },
  { id: 'great',     name: 'Great',     emoji: '🥈', minScore: 75, phoneMinutes: 60,  money: 5,  color: 'blue'    },
  { id: 'good',      name: 'Good',      emoji: '🥉', minScore: 60, phoneMinutes: 30,  money: 2,  color: 'yellow'  },
  { id: 'okay',      name: 'Okay',      emoji: '😐', minScore: 45, phoneMinutes: 0,   money: 0,  color: 'orange'  },
  { id: 'needswork', name: 'Needs Work',emoji: '⚠️', minScore: 0,  phoneMinutes: -30, money: 0,  color: 'red'     },
]

const DEFAULT_WEIGHTS = {
  academics: 0.50,
  homework:  0.20,
  behavior:  0.15,
  extras:    0.15,
}

const DEFAULT_SETTINGS = {
  sisterName: 'My Sister',
  currencySymbol: '$',
  baseWeekdayMinutes: 240, // 4 hrs
  baseAppMinutes: 30,
  weights: DEFAULT_WEIGHTS,
  tiers: DEFAULT_TIERS,
  subjects: DEFAULT_SUBJECTS,
  extras: DEFAULT_EXTRAS,
}

// ─── Store ─────────────────────────────────────────────────────────────────

export const useAppStore = create(
  persist(
    (set, get) => ({
      // ── State ──────────────────────────────────────────────────────────────
      settings: DEFAULT_SETTINGS,
      logs: [], // array of daily log entries

      // ── Settings actions ───────────────────────────────────────────────────
      updateSettings: (patch) =>
        set(state => ({ settings: { ...state.settings, ...patch } })),

      updateWeights: (weights) =>
        set(state => ({ settings: { ...state.settings, weights } })),

      addSubject: (subject) =>
        set(state => ({
          settings: {
            ...state.settings,
            subjects: [...state.settings.subjects, subject],
          },
        })),

      removeSubject: (id) =>
        set(state => ({
          settings: {
            ...state.settings,
            subjects: state.settings.subjects.filter(s => s.id !== id),
          },
        })),

      updateTier: (id, patch) =>
        set(state => ({
          settings: {
            ...state.settings,
            tiers: state.settings.tiers.map(t => t.id === id ? { ...t, ...patch } : t),
          },
        })),

      addExtra: (label) =>
        set(state => ({
          settings: {
            ...state.settings,
            extras: [...state.settings.extras, label],
          },
        })),

      removeExtra: (idx) =>
        set(state => ({
          settings: {
            ...state.settings,
            extras: state.settings.extras.filter((_, i) => i !== idx),
          },
        })),

      resetSettings: () => set({ settings: DEFAULT_SETTINGS }),

      // ── Log actions ────────────────────────────────────────────────────────

      /**
       * Upsert a log entry for a given date.
       * `entry` shape:
       * {
       *   date: 'YYYY-MM-DD',
       *   subjects: { [subjectId]: { mark: number, homework: 'yes'|'partial'|'no' } },
       *   behavior: 'excellent'|'good'|'neutral'|'poor'|'bad',
       *   extras: string[],
       *   notes: string,
       * }
       */
      saveLog: (entry) => {
        const { settings, logs } = get()
        const score = calcDailyScore(entry, settings.weights)
        const fullEntry = { ...entry, score }
        const exists = logs.findIndex(l => l.date === entry.date)
        if (exists >= 0) {
          set({ logs: logs.map((l, i) => (i === exists ? fullEntry : l)) })
        } else {
          set({ logs: [...logs, fullEntry].sort((a, b) => a.date.localeCompare(b.date)) })
        }
      },

      deleteLog: (date) =>
        set(state => ({ logs: state.logs.filter(l => l.date !== date) })),

      getLogByDate: (date) => get().logs.find(l => l.date === date) || null,

      // ── Derived getters ────────────────────────────────────────────────────

      /** All logs as a sorted array (newest first for display) */
      sortedLogs: () => [...get().logs].sort((a, b) => b.date.localeCompare(a.date)),

      /** Score for today */
      todayScore: () => {
        const log = get().logs.find(l => l.date === todayStr())
        return log ? log.score : null
      },

      /** Scores for the last N days */
      recentScores: (n = 7) => {
        const logs = get().logs
        return logs.slice(-n).map(l => ({ date: l.date, score: l.score }))
      },

      // ── Export ─────────────────────────────────────────────────────────────

      exportJSON: () => {
        const state = get()
        const data = { settings: state.settings, logs: state.logs }
        const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' })
        const url = URL.createObjectURL(blob)
        const a = document.createElement('a')
        a.href = url
        a.download = `kpi-export-${todayStr()}.json`
        a.click()
        URL.revokeObjectURL(url)
      },

      exportCSV: () => {
        const { logs, settings } = get()
        const subjectIds = settings.subjects.map(s => s.id)
        const header = ['date', 'score', 'behavior', 'extras', ...subjectIds.map(id => `${id}_mark`), ...subjectIds.map(id => `${id}_hw`), 'notes']
        const rows = logs.map(l => [
          l.date,
          l.score,
          l.behavior || '',
          (l.extras || []).join('; '),
          ...subjectIds.map(id => l.subjects?.[id]?.mark ?? ''),
          ...subjectIds.map(id => l.subjects?.[id]?.homework ?? ''),
          (l.notes || '').replace(/,/g, ';'),
        ])
        const csv = [header, ...rows].map(r => r.join(',')).join('\n')
        const blob = new Blob([csv], { type: 'text/csv' })
        const url = URL.createObjectURL(blob)
        const a = document.createElement('a')
        a.href = url
        a.download = `kpi-export-${todayStr()}.csv`
        a.click()
        URL.revokeObjectURL(url)
      },

      importJSON: (jsonData) => {
        try {
          const data = typeof jsonData === 'string' ? JSON.parse(jsonData) : jsonData
          set({ settings: data.settings || DEFAULT_SETTINGS, logs: data.logs || [] })
          return true
        } catch {
          return false
        }
      },
    }),
    {
      name: 'sister-kpi-storage',
      storage: createJSONStorage(() => localStorage),
    }
  )
)
