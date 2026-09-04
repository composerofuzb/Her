import { useState, useMemo } from 'react'
import { useNavigate } from 'react-router-dom'
import { format } from 'date-fns'
import { useAppStore } from '../store/useAppStore'
import { getTier, calcWeeklyScore } from '../utils/scoring'
import { groupByWeek, groupByMonth, weekLabel, monthDays } from '../utils/dateHelpers'
import HeatmapCalendar from '../components/HeatmapCalendar'
import RewardPanel from '../components/RewardPanel'
import WeeklyChart from '../components/WeeklyChart'
import ScoreBadge from '../components/ScoreBadge'
import clsx from 'clsx'

export default function Summary() {
  const { logs, settings } = useAppStore()
  const navigate = useNavigate()

  const now = new Date()
  const [viewYear, setViewYear] = useState(now.getFullYear())
  const [viewMonth, setViewMonth] = useState(now.getMonth())
  const [selectedWeek, setSelectedWeek] = useState(null)

  // ── Heatmap data ───────────────────────────────────────────────────────────
  const scoreMap = useMemo(() => {
    const map = {}
    logs.forEach(l => { map[l.date] = l.score })
    return map
  }, [logs])

  // ── Weekly breakdown ───────────────────────────────────────────────────────
  const weekGroups = useMemo(() => groupByWeek(logs), [logs])
  const weekKeys = Object.keys(weekGroups).sort((a, b) => b.localeCompare(a))

  const selectedWeekKey = selectedWeek || weekKeys[0]
  const selectedWeekLogs = selectedWeekKey ? weekGroups[selectedWeekKey] || [] : []
  const selectedWeekScores = selectedWeekLogs.map(l => l.score)
  const selectedWeeklyScore = calcWeeklyScore(selectedWeekScores)
  const selectedTier = getTier(selectedWeeklyScore, settings.tiers)

  // ── Month navigation ───────────────────────────────────────────────────────
  const monthLabel = format(new Date(viewYear, viewMonth, 1), 'MMMM yyyy')

  const prevMonth = () => {
    if (viewMonth === 0) { setViewMonth(11); setViewYear(y => y - 1) }
    else setViewMonth(m => m - 1)
  }
  const nextMonth = () => {
    const futureY = viewMonth === 11 ? viewYear + 1 : viewYear
    const futureM = viewMonth === 11 ? 0 : viewMonth + 1
    if (futureY > now.getFullYear() || (futureY === now.getFullYear() && futureM > now.getMonth())) return
    if (viewMonth === 11) { setViewMonth(0); setViewYear(y => y + 1) }
    else setViewMonth(m => m + 1)
  }

  // ── Month chart data ───────────────────────────────────────────────────────
  const monthChartData = useMemo(() => {
    const days = monthDays(viewYear, viewMonth)
    return days
      .map(d => ({ date: d, score: scoreMap[d] ?? null }))
      .filter(d => d.score !== null)
  }, [viewYear, viewMonth, scoreMap])

  return (
    <div className="p-6 max-w-4xl mx-auto">
      <h1 className="section-title">Summary & Rewards</h1>
      <p className="section-sub">View performance trends and calculate weekly rewards</p>

      {logs.length === 0 ? (
        <div className="card text-center py-16">
          <div className="text-5xl mb-4">📊</div>
          <h2 className="text-xl font-bold text-slate-700 mb-2">No data yet</h2>
          <p className="text-slate-500 mb-6">Start logging daily performance to see summaries here.</p>
          <button onClick={() => navigate('/log')} className="btn-primary">Log First Entry</button>
        </div>
      ) : (
        <div className="flex flex-col gap-6">

          {/* ── Heatmap calendar ─────────────────────────────────────────── */}
          <div className="card">
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-bold text-slate-700">{monthLabel}</h2>
              <div className="flex gap-2">
                <button onClick={prevMonth} className="btn-secondary !px-3 !py-1.5 text-sm">←</button>
                <button onClick={nextMonth} className="btn-secondary !px-3 !py-1.5 text-sm">→</button>
              </div>
            </div>
            <HeatmapCalendar year={viewYear} month={viewMonth} scoreMap={scoreMap} />
          </div>

          {/* ── Month chart ───────────────────────────────────────────────── */}
          {monthChartData.length > 0 && (
            <div className="card">
              <h2 className="font-bold text-slate-700 mb-4">Daily scores — {monthLabel}</h2>
              <WeeklyChart data={monthChartData} height={200} />
            </div>
          )}

          {/* ── Weekly reward breakdown ───────────────────────────────────── */}
          <div className="card">
            <h2 className="font-bold text-slate-700 mb-4">📅 Select a Week</h2>
            {weekKeys.length === 0 ? (
              <p className="text-slate-400 text-sm">No weeks logged yet.</p>
            ) : (
              <div className="flex flex-wrap gap-2 mb-5">
                {weekKeys.map(key => {
                  const wLogs = weekGroups[key]
                  const wScore = calcWeeklyScore(wLogs.map(l => l.score))
                  const wTier = getTier(wScore, settings.tiers)
                  const isSelected = key === selectedWeekKey
                  return (
                    <button
                      key={key}
                      onClick={() => setSelectedWeek(key)}
                      className={clsx(
                        'flex items-center gap-2 px-4 py-2 rounded-xl border text-sm font-medium transition-all',
                        isSelected
                          ? 'border-brand-400 bg-brand-50 text-brand-700 ring-2 ring-brand-200'
                          : 'border-slate-200 bg-white text-slate-600 hover:border-slate-300',
                      )}
                    >
                      <span>{weekLabel(key)}</span>
                      {wTier && <span>{wTier.emoji}</span>}
                      <span className="text-xs opacity-60">({wScore})</span>
                    </button>
                  )
                })}
              </div>
            )}

            {selectedWeekLogs.length > 0 && (
              <>
                {/* Week day scores */}
                <div className="flex flex-wrap gap-2 mb-5">
                  {selectedWeekLogs
                    .sort((a, b) => a.date.localeCompare(b.date))
                    .map(log => (
                      <button
                        key={log.date}
                        onClick={() => navigate(`/log?date=${log.date}`)}
                        className="flex flex-col items-center gap-1 px-3 py-2 rounded-xl border border-slate-200 bg-white hover:border-slate-300 transition-all"
                        title={`Edit ${log.date}`}
                      >
                        <span className="text-xs text-slate-400">{format(new Date(log.date + 'T00:00:00'), 'EEE')}</span>
                        <span className="font-bold text-slate-700">{log.score}</span>
                      </button>
                    ))}
                </div>

                {/* Reward panel */}
                <RewardPanel
                  tier={selectedTier}
                  weeklyScore={selectedWeeklyScore}
                  weekLabel={weekLabel(selectedWeekKey)}
                />
              </>
            )}
          </div>

          {/* ── All-time stats ─────────────────────────────────────────────── */}
          <div className="card">
            <h2 className="font-bold text-slate-700 mb-4">📈 All-Time Stats</h2>
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
              {[
                { label: 'Days logged', value: logs.length },
                {
                  label: 'Average score',
                  value: Math.round(logs.reduce((s, l) => s + l.score, 0) / logs.length),
                },
                {
                  label: 'Best score',
                  value: Math.max(...logs.map(l => l.score)),
                },
                {
                  label: 'Weeks tracked',
                  value: weekKeys.length,
                },
              ].map(stat => (
                <div key={stat.label} className="text-center p-3 bg-slate-50 rounded-xl">
                  <p className="text-2xl font-bold text-slate-800">{stat.value}</p>
                  <p className="text-xs text-slate-400 mt-0.5">{stat.label}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
