import clsx from 'clsx'

const hwOptions = [
  { value: 'yes', label: '✅ Done', color: 'bg-emerald-50 border-emerald-300 text-emerald-700' },
  { value: 'partial', label: '🔶 Partial', color: 'bg-yellow-50 border-yellow-300 text-yellow-700' },
  { value: 'no', label: '❌ Not done', color: 'bg-red-50 border-red-300 text-red-700' },
]

/**
 * A single subject row: grade input + homework selector.
 * @param {{ subject: Object, value: Object, onChange: Function }} props
 * value shape: { mark: number|'', homework: 'yes'|'partial'|'no' }
 */
export default function SubjectInput({ subject, value = {}, onChange }) {
  const mark = value.mark ?? ''
  const homework = value.homework ?? 'yes'

  const handleMark = (e) => {
    const raw = e.target.value
    const num = raw === '' ? '' : Math.min(100, Math.max(0, Number(raw)))
    onChange({ ...value, mark: num })
  }

  const handleHw = (hw) => {
    onChange({ ...value, homework: hw })
  }

  return (
    <div className="flex flex-col sm:flex-row sm:items-center gap-3 py-3 border-b border-slate-100 last:border-0">
      {/* Subject name */}
      <div className="w-28 shrink-0">
        <span className="font-semibold text-sm text-slate-700">{subject.name}</span>
      </div>

      {/* Mark input */}
      <div className="flex items-center gap-2">
        <input
          type="number"
          min={0}
          max={100}
          value={mark}
          onChange={handleMark}
          placeholder="Mark"
          className="w-20 border border-slate-200 rounded-xl px-3 py-2 text-sm text-center font-semibold focus:outline-none focus:ring-2 focus:ring-brand-400 focus:border-transparent"
        />
        <span className="text-slate-400 text-xs">/100</span>
      </div>

      {/* Homework toggle */}
      <div className="flex gap-1.5 flex-wrap">
        {hwOptions.map(opt => (
          <button
            key={opt.value}
            type="button"
            onClick={() => handleHw(opt.value)}
            className={clsx(
              'text-xs px-2.5 py-1.5 rounded-lg border font-medium transition-all',
              homework === opt.value
                ? opt.color + ' ring-2 ring-offset-1 ring-current'
                : 'bg-white border-slate-200 text-slate-500 hover:border-slate-300',
            )}
          >
            {opt.label}
          </button>
        ))}
      </div>
    </div>
  )
}
