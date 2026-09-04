import { useState, useRef } from 'react'
import { useAppStore } from '../store/useAppStore'
import clsx from 'clsx'

function Section({ title, children }) {
  return (
    <div className="card flex flex-col gap-4">
      <h2 className="font-bold text-slate-700 text-base border-b border-slate-100 pb-3">{title}</h2>
      {children}
    </div>
  )
}

export default function Settings() {
  const {
    settings,
    updateSettings,
    updateWeights,
    addSubject,
    removeSubject,
    updateTier,
    addExtra,
    removeExtra,
    resetSettings,
    exportJSON,
    exportCSV,
    importJSON,
  } = useAppStore()

  const [newSubject, setNewSubject] = useState('')
  const [newExtra, setNewExtra] = useState('')
  const [saved, setSaved] = useState(false)
  const fileRef = useRef()

  const flashSaved = () => {
    setSaved(true)
    setTimeout(() => setSaved(false), 1500)
  }

  const handleGeneralChange = (key, val) => {
    updateSettings({ [key]: val })
    flashSaved()
  }

  const handleWeightChange = (key, val) => {
    const num = Math.max(0, Math.min(1, parseFloat(val) || 0))
    const newWeights = { ...settings.weights, [key]: num }
    updateWeights(newWeights)
    flashSaved()
  }

  const weightTotal = Object.values(settings.weights).reduce((s, v) => s + v, 0)

  const handleAddSubject = () => {
    const name = newSubject.trim()
    if (!name) return
    const id = name.toLowerCase().replace(/\s+/g, '_')
    if (settings.subjects.find(s => s.id === id)) return
    addSubject({ id, name })
    setNewSubject('')
  }

  const handleAddExtra = () => {
    const label = newExtra.trim()
    if (!label) return
    addExtra(label)
    setNewExtra('')
  }

  const handleImport = (e) => {
    const file = e.target.files?.[0]
    if (!file) return
    const reader = new FileReader()
    reader.onload = (ev) => {
      const ok = importJSON(ev.target.result)
      alert(ok ? '✅ Import successful!' : '❌ Import failed — invalid file.')
    }
    reader.readAsText(file)
  }

  const handleReset = () => {
    if (window.confirm('Reset ALL settings to defaults? This does NOT delete your logs.')) {
      resetSettings()
    }
  }

  return (
    <div className="p-6 max-w-2xl mx-auto">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="section-title mb-0">Settings</h1>
          <p className="text-sm text-slate-400">Configure subjects, weights, and rewards</p>
        </div>
        {saved && (
          <span className="text-xs bg-emerald-100 text-emerald-700 px-3 py-1.5 rounded-full font-semibold">
            ✓ Saved
          </span>
        )}
      </div>

      <div className="flex flex-col gap-5">

        {/* ── General ──────────────────────────────────────────────────────── */}
        <Section title="👤 General">
          <div>
            <label className="label">Sister's name</label>
            <input
              className="input"
              value={settings.sisterName}
              onChange={e => handleGeneralChange('sisterName', e.target.value)}
            />
          </div>
          <div>
            <label className="label">Currency symbol</label>
            <input
              className="input w-24"
              value={settings.currencySymbol}
              maxLength={3}
              onChange={e => handleGeneralChange('currencySymbol', e.target.value)}
            />
          </div>
        </Section>

        {/* ── Phone time rules ─────────────────────────────────────────────── */}
        <Section title="📱 Base Phone Limits">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Weekday daily limit (min)</label>
              <input
                type="number"
                min={0}
                max={1440}
                className="input"
                value={settings.baseWeekdayMinutes}
                onChange={e => handleGeneralChange('baseWeekdayMinutes', Number(e.target.value))}
              />
              <p className="text-xs text-slate-400 mt-1">
                = {Math.floor(settings.baseWeekdayMinutes / 60)} hr {settings.baseWeekdayMinutes % 60} min
              </p>
            </div>
            <div>
              <label className="label">Per-app limit (min)</label>
              <input
                type="number"
                min={0}
                max={1440}
                className="input"
                value={settings.baseAppMinutes}
                onChange={e => handleGeneralChange('baseAppMinutes', Number(e.target.value))}
              />
            </div>
          </div>
        </Section>

        {/* ── Subjects ─────────────────────────────────────────────────────── */}
        <Section title="📚 Subjects">
          <div className="flex flex-col gap-2">
            {settings.subjects.map(s => (
              <div key={s.id} className="flex items-center justify-between bg-slate-50 rounded-xl px-4 py-2.5">
                <span className="font-medium text-sm text-slate-700">{s.name}</span>
                <button
                  onClick={() => removeSubject(s.id)}
                  className="text-red-400 hover:text-red-600 text-sm font-medium transition-colors"
                >
                  Remove
                </button>
              </div>
            ))}
          </div>
          <div className="flex gap-2">
            <input
              className="input"
              placeholder="New subject name…"
              value={newSubject}
              onChange={e => setNewSubject(e.target.value)}
              onKeyDown={e => e.key === 'Enter' && (e.preventDefault(), handleAddSubject())}
            />
            <button onClick={handleAddSubject} className="btn-primary shrink-0">Add</button>
          </div>
        </Section>

        {/* ── KPI Weights ───────────────────────────────────────────────────── */}
        <Section title="⚖️ KPI Weights">
          <p className="text-xs text-slate-400 -mt-2">
            Weights must add up to 1.0. Current total:{' '}
            <span className={clsx('font-bold', Math.abs(weightTotal - 1) < 0.01 ? 'text-emerald-600' : 'text-red-500')}>
              {weightTotal.toFixed(2)}
            </span>
          </p>
          {Object.entries(settings.weights).map(([key, val]) => (
            <div key={key}>
              <label className="label capitalize">{key} ({Math.round(val * 100)}%)</label>
              <input
                type="range"
                min="0"
                max="1"
                step="0.05"
                value={val}
                onChange={e => handleWeightChange(key, e.target.value)}
                className="w-full accent-brand-500"
              />
            </div>
          ))}
        </Section>

        {/* ── Reward Tiers ──────────────────────────────────────────────────── */}
        <Section title="🏆 Reward Tiers">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="text-left text-xs text-slate-400 border-b border-slate-100">
                  <th className="pb-2 font-medium">Tier</th>
                  <th className="pb-2 font-medium">Min Score</th>
                  <th className="pb-2 font-medium">Phone (min)</th>
                  <th className="pb-2 font-medium">Money</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-50">
                {[...settings.tiers].sort((a, b) => b.minScore - a.minScore).map(tier => (
                  <tr key={tier.id}>
                    <td className="py-2 pr-2 font-medium text-slate-700">
                      {tier.emoji} {tier.name}
                    </td>
                    <td className="py-2 pr-2">
                      <input
                        type="number"
                        min={0}
                        max={100}
                        value={tier.minScore}
                        onChange={e => updateTier(tier.id, { minScore: Number(e.target.value) })}
                        className="w-16 border border-slate-200 rounded-lg px-2 py-1 text-sm text-center focus:outline-none focus:ring-2 focus:ring-brand-400"
                      />
                    </td>
                    <td className="py-2 pr-2">
                      <input
                        type="number"
                        value={tier.phoneMinutes}
                        onChange={e => updateTier(tier.id, { phoneMinutes: Number(e.target.value) })}
                        className="w-20 border border-slate-200 rounded-lg px-2 py-1 text-sm text-center focus:outline-none focus:ring-2 focus:ring-brand-400"
                      />
                    </td>
                    <td className="py-2">
                      <input
                        type="number"
                        value={tier.money}
                        onChange={e => updateTier(tier.id, { money: Number(e.target.value) })}
                        className="w-20 border border-slate-200 rounded-lg px-2 py-1 text-sm text-center focus:outline-none focus:ring-2 focus:ring-brand-400"
                      />
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <p className="text-xs text-slate-400">Phone minutes: positive = bonus time, negative = deduction. Changes are saved instantly.</p>
        </Section>

        {/* ── Bonus extras ─────────────────────────────────────────────────── */}
        <Section title="⭐ Bonus Activities">
          <div className="flex flex-col gap-2">
            {settings.extras.map((e, i) => (
              <div key={i} className="flex items-center justify-between bg-slate-50 rounded-xl px-4 py-2.5">
                <span className="text-sm text-slate-700">{e}</span>
                <button
                  onClick={() => removeExtra(i)}
                  className="text-red-400 hover:text-red-600 text-sm font-medium transition-colors"
                >
                  Remove
                </button>
              </div>
            ))}
          </div>
          <div className="flex gap-2">
            <input
              className="input"
              placeholder="New bonus activity…"
              value={newExtra}
              onChange={e => setNewExtra(e.target.value)}
              onKeyDown={e => e.key === 'Enter' && (e.preventDefault(), handleAddExtra())}
            />
            <button onClick={handleAddExtra} className="btn-primary shrink-0">Add</button>
          </div>
        </Section>

        {/* ── Data management ───────────────────────────────────────────────── */}
        <Section title="💾 Data Management">
          <div className="flex flex-wrap gap-3">
            <button onClick={exportJSON} className="btn-secondary text-sm">Export JSON</button>
            <button onClick={exportCSV} className="btn-secondary text-sm">Export CSV</button>
            <button onClick={() => fileRef.current?.click()} className="btn-secondary text-sm">
              Import JSON
            </button>
            <input ref={fileRef} type="file" accept=".json" onChange={handleImport} className="hidden" />
          </div>
          <div className="border-t border-slate-100 pt-3">
            <button onClick={handleReset} className="btn-danger text-sm">
              Reset Settings to Defaults
            </button>
            <p className="text-xs text-slate-400 mt-1">This only resets settings — your log data is preserved.</p>
          </div>
        </Section>
      </div>
    </div>
  )
}
