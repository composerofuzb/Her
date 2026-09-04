import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Cell, ReferenceLine,
} from 'recharts'
import { format, parseISO, isValid } from 'date-fns'
import { scoreColor } from '../utils/scoring'

const CustomTooltip = ({ active, payload, label }) => {
  if (active && payload && payload.length) {
    const score = payload[0].value
    const colors = scoreColor(score)
    return (
      <div className="bg-white border border-slate-200 rounded-xl shadow-lg px-3 py-2 text-sm">
        <p className="font-semibold text-slate-700">{label}</p>
        <p className={`font-bold mt-0.5 ${colors.text}`}>Score: {score}</p>
      </div>
    )
  }
  return null
}

function barColor(score) {
  if (score >= 90) return '#10b981'
  if (score >= 75) return '#3b82f6'
  if (score >= 60) return '#f59e0b'
  if (score >= 45) return '#f97316'
  return '#ef4444'
}

/**
 * Bar chart showing daily scores over the last N days.
 * @param {{ data: Array<{date: string, score: number}>, height?: number }} props
 */
export default function WeeklyChart({ data = [], height = 200 }) {
  const chartData = data.map(d => ({
    label: (() => {
      const parsed = parseISO(d.date)
      return isValid(parsed) ? format(parsed, 'EEE') : d.date
    })(),
    score: d.score,
    date: d.date,
  }))

  if (chartData.length === 0) {
    return (
      <div className="flex items-center justify-center h-32 text-slate-400 text-sm">
        No data yet — log some days to see the chart!
      </div>
    )
  }

  return (
    <ResponsiveContainer width="100%" height={height}>
      <BarChart data={chartData} margin={{ top: 5, right: 10, left: -20, bottom: 0 }}>
        <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" vertical={false} />
        <XAxis
          dataKey="label"
          tick={{ fontSize: 12, fill: '#94a3b8' }}
          axisLine={false}
          tickLine={false}
        />
        <YAxis
          domain={[0, 100]}
          tick={{ fontSize: 11, fill: '#94a3b8' }}
          axisLine={false}
          tickLine={false}
          ticks={[0, 25, 50, 75, 100]}
        />
        <Tooltip content={<CustomTooltip />} cursor={{ fill: '#f8fafc', radius: 6 }} />
        <ReferenceLine y={75} stroke="#3b82f6" strokeDasharray="4 4" strokeOpacity={0.4} />
        <Bar dataKey="score" radius={[6, 6, 0, 0]} maxBarSize={40}>
          {chartData.map((entry, index) => (
            <Cell key={index} fill={barColor(entry.score)} />
          ))}
        </Bar>
      </BarChart>
    </ResponsiveContainer>
  )
}
