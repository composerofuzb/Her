import clsx from 'clsx'
import { scoreColor } from '../utils/scoring'
import { displayDate } from '../utils/dateHelpers'
import { useNavigate } from 'react-router-dom'

/**
 * A card showing a single day's score summary.
 */
export default function DailyScoreCard({ log, onClick }) {
  const navigate = useNavigate()
  const color = scoreColor(log.score)

  return (
    <div
      className="card flex items-center gap-4 cursor-pointer hover:shadow-md transition-shadow"
      onClick={onClick || (() => navigate(`/log?date=${log.date}`))}
    >
      {/* Score circle */}
      <div
        className={clsx(
          'w-14 h-14 rounded-full flex items-center justify-center font-bold text-xl ring-2 shrink-0',
          color.bg, color.text, color.ring,
        )}
      >
        {log.score}
      </div>

      {/* Details */}
      <div className="flex-1 min-w-0">
        <p className="font-semibold text-slate-800 text-sm">{displayDate(log.date)}</p>
        <div className="flex flex-wrap gap-x-3 gap-y-0.5 mt-0.5 text-xs text-slate-500">
          <span>Behavior: <span className="capitalize text-slate-700 font-medium">{log.behavior || '—'}</span></span>
          {log.extras?.length > 0 && (
            <span>Extras: <span className="text-slate-700 font-medium">{log.extras.length}</span></span>
          )}
        </div>
        {/* Subject marks */}
        {log.subjects && (
          <div className="flex flex-wrap gap-1.5 mt-1.5">
            {Object.entries(log.subjects).map(([id, val]) => (
              <span key={id} className="text-xs bg-slate-100 text-slate-600 rounded-lg px-2 py-0.5 capitalize">
                {id}: {val.mark ?? '—'}
              </span>
            ))}
          </div>
        )}
      </div>

      <svg className="w-4 h-4 text-slate-300 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
      </svg>
    </div>
  )
}
