import { useNavigate } from 'react-router-dom'
import { useAppStore } from '../store/useAppStore'
import { getTier, scoreColor } from '../utils/scoring'
import { calcWeeklyScore } from '../utils/scoring'
import { currentWeekDays, todayStr, displayDate } from '../utils/dateHelpers'
import WeeklyChart from '../components/WeeklyChart'
import ScoreBadge from '../components/ScoreBadge'
import DailyScoreCard from '../components/DailyScoreCard'
import clsx from 'clsx'

export default function Dashboard() {
  const navigate = useNavigate()
  const { logs, settings } = useAppStore()

  const today = todayStr()
  const todayLog = logs.find(l => l.date === today)

  // Last 7 days chart data
  const recent = [...logs].sort((a, b) => a.date.localeCompare(b.date)).slice(-7)

  // Current week
  const weekDays = currentWeekDays()
  const weekLogs = logs.filter(l => weekDays.includes(l.date))
  const weekScores = weekLogs.map(l => l.score)
  const weeklyScore = calcWeeklyScore(weekScores)
  const currentTier = getTier(weeklyScore, settings.tiers)

  // Recent entries to display
  const recentEntries = [...logs].sort((a, b) => b.date.localeCompare(a.date)).slice(0, 5)

  const todayColors = todayLog ? scoreColor(todayLog.score) : null

  return (
    <div className="p-6 max-w-4xl mx-auto">
      {/* Page header */}
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-slate-800">
          Hi! 👋 Here's {settings.sisterName}'s progress
        </h1>
        <p className="text-slate-500 text-sm mt-1">{displayDate(today)}</p>
      </div>

      {/* Top stat cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
        {/* Today's score */}
        <div className="card flex flex-col gap-2">
          <p className="text-xs font-semibold text-slate-400 uppercase tracking-wider">Today's Score</p>
          {todayLog ? (
            <div className={clsx('w-16 h-16 rounded-full flex items-center justify-center font-bold text-2xl ring-2', todayColors.bg, todayColors.text, todayColors.ring)}>
              {todayLog.score}
            </div>
          ) : (
            <div className="flex flex-col gap-2">
              <p className="text-slate-400 text-sm">Not logged yet</p>
              <button
                onClick={() => navigate('/log')}
                className="btn-primary text-sm w-fit"
              >
                Log Now
              </button>
            </div>
          )}
        </div>

        {/* This week */}
        <div className="card flex flex-col gap-2">
          <p className="text-xs font-semibold text-slate-400 uppercase tracking-wider">This Week</p>
          <div className="text-3xl font-bold text-slate-800">{weekScores.length > 0 ? weeklyScore : '—'}</div>
          {currentTier && weekScores.length > 0 ? (
            <ScoreBadge tier={currentTier} size="sm" />
          ) : (
            <p className="text-slate-400 text-sm">No logs this week</p>
          )}
          <p className="text-xs text-slate-400">{weekLogs.length}/{weekDays.length} days logged</p>
        </div>

        {/* Total logs */}
        <div className="card flex flex-col gap-2">
          <p className="text-xs font-semibold text-slate-400 uppercase tracking-wider">All Time</p>
          <div className="text-3xl font-bold text-slate-800">{logs.length}</div>
          <p className="text-sm text-slate-500">Days logged</p>
          {logs.length > 0 && (
            <p className="text-xs text-slate-400">
              Avg: {Math.round(logs.reduce((s, l) => s + l.score, 0) / logs.length)} overall
            </p>
          )}
        </div>
      </div>

      {/* 7-day chart */}
      <div className="card mb-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="font-bold text-slate-700">Last 7 Days</h2>
          <button onClick={() => navigate('/summary')} className="text-xs text-brand-600 hover:underline font-medium">
            View full summary →
          </button>
        </div>
        <WeeklyChart data={recent} height={180} />
      </div>

      {/* Quick log button */}
      {!todayLog && (
        <div className="card mb-6 flex items-center gap-4 bg-brand-50 border-brand-100">
          <div className="text-3xl">📝</div>
          <div className="flex-1">
            <p className="font-semibold text-brand-800">Today's entry is missing!</p>
            <p className="text-sm text-brand-600">Log today's performance to keep the streak going.</p>
          </div>
          <button onClick={() => navigate('/log')} className="btn-primary shrink-0">
            Log Today
          </button>
        </div>
      )}

      {/* Recent entries */}
      {recentEntries.length > 0 && (
        <div>
          <h2 className="font-bold text-slate-700 mb-3">Recent Entries</h2>
          <div className="flex flex-col gap-3">
            {recentEntries.map(log => (
              <DailyScoreCard key={log.date} log={log} />
            ))}
          </div>
        </div>
      )}

      {logs.length === 0 && (
        <div className="card text-center py-16">
          <div className="text-5xl mb-4">🎯</div>
          <h2 className="text-xl font-bold text-slate-700 mb-2">Let's get started!</h2>
          <p className="text-slate-500 mb-6 max-w-sm mx-auto">
            Log your sister's first day of performance to begin tracking her KPIs and earning rewards.
          </p>
          <button onClick={() => navigate('/log')} className="btn-primary">
            Log First Entry
          </button>
        </div>
      )}
    </div>
  )
}
