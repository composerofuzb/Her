import clsx from 'clsx'
import { format, parseISO, isValid, startOfWeek, eachDayOfInterval, endOfWeek } from 'date-fns'
import { heatmapClass } from '../utils/scoring'

/**
 * Calendar heatmap for a given month.
 * @param {{ year: number, month: number, scoreMap: Object<string, number> }} props
 * month is 0-indexed
 */
export default function HeatmapCalendar({ year, month, scoreMap = {} }) {
  // Build grid: all days of the month padded to start on Monday
  const firstDay = new Date(year, month, 1)
  const lastDay = new Date(year, month + 1, 0)
  const gridStart = startOfWeek(firstDay, { weekStartsOn: 1 })
  const gridEnd = endOfWeek(lastDay, { weekStartsOn: 1 })
  const allDays = eachDayOfInterval({ start: gridStart, end: gridEnd })

  const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']

  return (
    <div>
      {/* Day-of-week headers */}
      <div className="grid grid-cols-7 mb-1">
        {dayLabels.map(d => (
          <div key={d} className="text-center text-xs text-slate-400 font-medium py-1">
            {d}
          </div>
        ))}
      </div>

      {/* Days grid */}
      <div className="grid grid-cols-7 gap-1">
        {allDays.map(day => {
          const dateStr = format(day, 'yyyy-MM-dd')
          const isCurrentMonth = day.getMonth() === month
          const score = scoreMap[dateStr]
          const hasScore = score != null && isCurrentMonth

          return (
            <div
              key={dateStr}
              title={hasScore ? `${format(day, 'MMM d')}: ${score}` : format(day, 'MMM d')}
              className={clsx(
                'aspect-square rounded-md flex items-center justify-center text-xs font-semibold transition-all cursor-default',
                !isCurrentMonth && 'opacity-0 pointer-events-none',
                isCurrentMonth && hasScore && heatmapClass(score) + ' text-white',
                isCurrentMonth && !hasScore && 'bg-slate-100 text-slate-400',
              )}
            >
              {isCurrentMonth ? day.getDate() : ''}
            </div>
          )
        })}
      </div>

      {/* Legend */}
      <div className="flex items-center gap-3 mt-3 flex-wrap">
        <span className="text-xs text-slate-400">Score:</span>
        {[
          { label: '90+', cls: 'bg-emerald-500' },
          { label: '75+', cls: 'bg-emerald-300' },
          { label: '60+', cls: 'bg-yellow-300' },
          { label: '45+', cls: 'bg-orange-300' },
          { label: '<45', cls: 'bg-red-400' },
          { label: 'No log', cls: 'bg-slate-100' },
        ].map(({ label, cls }) => (
          <div key={label} className="flex items-center gap-1">
            <div className={`w-3 h-3 rounded ${cls}`} />
            <span className="text-xs text-slate-500">{label}</span>
          </div>
        ))}
      </div>
    </div>
  )
}
