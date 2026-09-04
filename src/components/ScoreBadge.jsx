import clsx from 'clsx'

const tierStyles = {
  emerald: { bg: 'bg-emerald-100', text: 'text-emerald-700', border: 'border-emerald-200' },
  blue:    { bg: 'bg-blue-100',    text: 'text-blue-700',    border: 'border-blue-200'    },
  yellow:  { bg: 'bg-yellow-100',  text: 'text-yellow-700',  border: 'border-yellow-200'  },
  orange:  { bg: 'bg-orange-100',  text: 'text-orange-700',  border: 'border-orange-200'  },
  red:     { bg: 'bg-red-100',     text: 'text-red-700',     border: 'border-red-200'     },
}

/**
 * Displays a reward tier badge.
 * @param {{ tier: Object, size?: 'sm'|'md'|'lg', showScore?: boolean, score?: number }} props
 */
export default function ScoreBadge({ tier, size = 'md', showScore = false, score }) {
  if (!tier) return null
  const style = tierStyles[tier.color] || tierStyles.blue

  return (
    <span
      className={clsx(
        'inline-flex items-center gap-1.5 font-semibold rounded-full border',
        style.bg, style.text, style.border,
        size === 'sm'  && 'text-xs px-2.5 py-0.5',
        size === 'md'  && 'text-sm px-3 py-1',
        size === 'lg'  && 'text-base px-4 py-1.5',
      )}
    >
      <span>{tier.emoji}</span>
      <span>{tier.name}</span>
      {showScore && score != null && (
        <span className="opacity-70 font-normal">({score})</span>
      )}
    </span>
  )
}
