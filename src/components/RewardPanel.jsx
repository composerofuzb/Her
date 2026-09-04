import { useState } from 'react'
import clsx from 'clsx'
import ScoreBadge from './ScoreBadge'
import { getReward, familyLinkInstruction } from '../utils/rewards'
import { useAppStore } from '../store/useAppStore'

/**
 * Reward summary panel for a given week.
 * @param {{ tier: Object, weeklyScore: number, weekLabel: string }} props
 */
export default function RewardPanel({ tier, weeklyScore, weekLabel }) {
  const [copied, setCopied] = useState(false)
  const { settings } = useAppStore()
  const reward = getReward(tier, settings.currencySymbol)
  const instruction = familyLinkInstruction(tier, reward.phoneMinutes, settings.sisterName)

  const handleCopy = () => {
    navigator.clipboard.writeText(instruction).then(() => {
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    })
  }

  if (!tier) return null

  const tierColors = {
    emerald: { border: 'border-emerald-200', bg: 'bg-emerald-50', accent: 'text-emerald-600' },
    blue:    { border: 'border-blue-200',    bg: 'bg-blue-50',    accent: 'text-blue-600'    },
    yellow:  { border: 'border-yellow-200',  bg: 'bg-yellow-50',  accent: 'text-yellow-600'  },
    orange:  { border: 'border-orange-200',  bg: 'bg-orange-50',  accent: 'text-orange-600'  },
    red:     { border: 'border-red-200',     bg: 'bg-red-50',     accent: 'text-red-600'     },
  }
  const tc = tierColors[tier.color] || tierColors.blue

  return (
    <div className={clsx('rounded-2xl border-2 p-6', tc.border, tc.bg)}>
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-3 mb-5">
        <div>
          <p className="text-sm text-slate-500 font-medium mb-1">{weekLabel}</p>
          <h3 className="text-2xl font-bold text-slate-800">Reward Summary</h3>
        </div>
        <ScoreBadge tier={tier} size="lg" showScore score={weeklyScore} />
      </div>

      {/* Reward grid */}
      <div className="grid grid-cols-2 gap-4 mb-5">
        {/* Phone time */}
        <div className="bg-white rounded-xl p-4 border border-slate-100">
          <div className="flex items-center gap-2 mb-2">
            <span className="text-xl">📱</span>
            <span className="text-sm font-medium text-slate-500">Weekend Screen Time</span>
          </div>
          <p className={clsx('text-2xl font-bold', tc.accent)}>{reward.phoneLabel}</p>
          <p className="text-xs text-slate-400 mt-1">Applied to weekend limits in Family Link</p>
        </div>

        {/* Pocket money */}
        <div className="bg-white rounded-xl p-4 border border-slate-100">
          <div className="flex items-center gap-2 mb-2">
            <span className="text-xl">💰</span>
            <span className="text-sm font-medium text-slate-500">Pocket Money Bonus</span>
          </div>
          <p className={clsx('text-2xl font-bold', tc.accent)}>{reward.moneyLabel}</p>
          <p className="text-xs text-slate-400 mt-1">Cash / allowance to hand over</p>
        </div>
      </div>

      {/* Family Link instruction */}
      <div className="bg-white rounded-xl border border-slate-100 p-4">
        <div className="flex items-center justify-between mb-3">
          <span className="text-sm font-semibold text-slate-700">📋 Google Family Link Instructions</span>
          <button
            onClick={handleCopy}
            className={clsx(
              'text-xs px-3 py-1.5 rounded-lg font-semibold transition-all',
              copied
                ? 'bg-emerald-100 text-emerald-700'
                : 'bg-brand-100 text-brand-700 hover:bg-brand-200',
            )}
          >
            {copied ? '✓ Copied!' : 'Copy'}
          </button>
        </div>
        <pre className="text-xs text-slate-600 whitespace-pre-wrap leading-relaxed font-mono bg-slate-50 rounded-lg p-3">
          {instruction}
        </pre>
      </div>
    </div>
  )
}
