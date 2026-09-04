import { useState, useEffect } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { useAppStore } from '../store/useAppStore'
import { todayStr } from '../utils/dateHelpers'
import { calcDailyScore, scoreColor } from '../utils/scoring'
import SubjectInput from '../components/SubjectInput'
import clsx from 'clsx'

const BEHAVIOR_OPTIONS = [
  { value: 'excellent', label: '😄 Excellent', desc: 'Outstanding attitude all day' },
  { value: 'good',      label: '🙂 Good',      desc: 'Generally positive' },
  { value: 'neutral',   label: '😐 Neutral',   desc: 'Nothing notable' },
  { value: 'poor',      label: '😟 Poor',      desc: 'Some issues today' },
  { value: 'bad',       label: '😠 Bad',       desc: 'Significant behavioral problems' },
]

export default function DailyLog() {
  const [searchParams] = useSearchParams()
  const navigate = useNavigate()
  const { settings, saveLog, getLogByDate, deleteLog } = useAppStore()

  const urlDate = searchParams.get('date') || todayStr()
  const [date, setDate] = useState(urlDate)
  const [subjects, setSubjects] = useState({})
  const [behavior, setBehavior] = useState('good')
  const [extras, setExtras] = useState([])
  const [notes, setNotes] = useState('')
  const [saved, setSaved] = useState(false)
  const [previewScore, setPreviewScore] = useState(null)
  const [isEditing, setIsEditing] = useState(false)

  // Load existing entry for the date
  useEffect(() => {
    const existing = getLogByDate(date)
    if (existing) {
      setSubjects(existing.subjects || {})
      setBehavior(existing.behavior || 'good')
      setExtras(existing.extras || [])
      setNotes(existing.notes || '')
      setIsEditing(true)
    } else {
      // Reset for fresh date
      const defaultSubjects = {}
      settings.subjects.forEach(s => { defaultSubjects[s.id] = { mark: '', homework: 'yes' } })
      setSubjects(defaultSubjects)
      setBehavior('good')
      setExtras([])
      setNotes('')
      setIsEditing(false)
    }
    setSaved(false)
  }, [date])

  // Live score preview
  useEffect(() => {
    const entry = { subjects, behavior, extras, notes, date }
    const score = calcDailyScore(entry, settings.weights)
    setPreviewScore(score)
  }, [subjects, behavior, extras, notes, settings.weights])

  const handleSubjectChange = (id, val) => {
    setSubjects(prev => ({ ...prev, [id]: val }))
  }

  const toggleExtra = (extra) => {
    setExtras(prev =>
      prev.includes(extra) ? prev.filter(e => e !== extra) : [...prev, extra]
    )
  }

  const handleSubmit = (e) => {
    e.preventDefault()
    saveLog({ date, subjects, behavior, extras, notes })
    setSaved(true)
    setTimeout(() => navigate('/'), 1200)
  }

  const handleDelete = () => {
    if (window.confirm(`Delete the log entry for ${date}?`)) {
      deleteLog(date)
      navigate('/')
    }
  }

  const colors = scoreColor(previewScore)

  return (
    <div className="p-6 max-w-2xl mx-auto">
      {/* Header */}
      <div className="flex items-center gap-3 mb-6">
        <button onClick={() => navigate(-1)} className="text-slate-400 hover:text-slate-600">
          <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
          </svg>
        </button>
        <div>
          <h1 className="section-title mb-0">{isEditing ? 'Edit Entry' : 'Log Performance'}</h1>
          <p className="text-sm text-slate-400">Fill in all the details for the day</p>
        </div>
      </div>

      {/* Live score preview */}
      {previewScore !== null && (
        <div className={clsx('card flex items-center gap-4 mb-6 border-2', colors.ring.replace('ring', 'border'))}>
          <div className={clsx('w-16 h-16 rounded-full flex items-center justify-center font-bold text-2xl shrink-0', colors.bg, colors.text)}>
            {previewScore}
          </div>
          <div>
            <p className="font-semibold text-slate-700">Live Score Preview</p>
            <p className="text-sm text-slate-400">Updates as you fill in the form</p>
          </div>
        </div>
      )}

      <form onSubmit={handleSubmit} className="flex flex-col gap-5">
        {/* Date picker */}
        <div className="card">
          <label className="label">Date</label>
          <input
            type="date"
            value={date}
            max={todayStr()}
            onChange={e => setDate(e.target.value)}
            className="input"
          />
        </div>

        {/* Subjects */}
        <div className="card">
          <h2 className="font-bold text-slate-700 mb-1">📚 Subjects</h2>
          <p className="text-xs text-slate-400 mb-3">Enter the mark (0–100) and whether homework was done</p>
          {settings.subjects.map(subject => (
            <SubjectInput
              key={subject.id}
              subject={subject}
              value={subjects[subject.id] || {}}
              onChange={val => handleSubjectChange(subject.id, val)}
            />
          ))}
        </div>

        {/* Behavior */}
        <div className="card">
          <h2 className="font-bold text-slate-700 mb-1">😊 Behavior</h2>
          <p className="text-xs text-slate-400 mb-3">How was she today overall?</p>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
            {BEHAVIOR_OPTIONS.map(opt => (
              <button
                key={opt.value}
                type="button"
                onClick={() => setBehavior(opt.value)}
                className={clsx(
                  'flex items-start gap-2 p-3 rounded-xl border text-left transition-all',
                  behavior === opt.value
                    ? 'border-brand-400 bg-brand-50 ring-2 ring-brand-300'
                    : 'border-slate-200 bg-white hover:border-slate-300',
                )}
              >
                <span className="text-lg leading-none mt-0.5">{opt.label.split(' ')[0]}</span>
                <div>
                  <p className="font-semibold text-sm text-slate-700">{opt.label.split(' ').slice(1).join(' ')}</p>
                  <p className="text-xs text-slate-400">{opt.desc}</p>
                </div>
              </button>
            ))}
          </div>
        </div>

        {/* Extras / Bonuses */}
        <div className="card">
          <h2 className="font-bold text-slate-700 mb-1">⭐ Extras & Bonuses</h2>
          <p className="text-xs text-slate-400 mb-3">Select anything she did above and beyond today</p>
          <div className="flex flex-col gap-2">
            {settings.extras.map(extra => (
              <label
                key={extra}
                className={clsx(
                  'flex items-center gap-3 p-3 rounded-xl border cursor-pointer transition-all',
                  extras.includes(extra)
                    ? 'border-emerald-300 bg-emerald-50'
                    : 'border-slate-200 bg-white hover:border-slate-300',
                )}
              >
                <input
                  type="checkbox"
                  checked={extras.includes(extra)}
                  onChange={() => toggleExtra(extra)}
                  className="w-4 h-4 accent-emerald-500 rounded"
                />
                <span className="text-sm text-slate-700">{extra}</span>
              </label>
            ))}
          </div>
        </div>

        {/* Notes */}
        <div className="card">
          <label className="label">📝 Notes (optional)</label>
          <textarea
            value={notes}
            onChange={e => setNotes(e.target.value)}
            placeholder="Any observations, context, or things to remember about today..."
            rows={3}
            className="input resize-none"
          />
        </div>

        {/* Actions */}
        <div className="flex gap-3">
          <button
            type="submit"
            disabled={saved}
            className={clsx('btn-primary flex-1', saved && 'bg-emerald-600 hover:bg-emerald-600')}
          >
            {saved ? '✓ Saved! Redirecting...' : isEditing ? 'Update Entry' : 'Save Entry'}
          </button>
          {isEditing && (
            <button type="button" onClick={handleDelete} className="btn-danger">
              Delete
            </button>
          )}
        </div>
      </form>
    </div>
  )
}
