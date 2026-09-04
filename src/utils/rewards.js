/**
 * Reward formatting utilities.
 */

/**
 * Format minutes into a human-readable string.
 * @param {number} minutes
 * @returns {string}
 */
export function formatMinutes(minutes) {
  if (minutes === 0) return 'No change'
  const sign = minutes > 0 ? '+' : '-'
  const abs = Math.abs(minutes)
  if (abs < 60) return `${sign}${abs} min`
  const h = Math.floor(abs / 60)
  const m = abs % 60
  return m > 0 ? `${sign}${h} hr ${m} min` : `${sign}${h} hr`
}

/**
 * Get reward details for a tier.
 * @param {Object} tier
 * @param {string} currencySymbol
 * @returns {{ phoneMinutes: number, money: number, phoneLabel: string, moneyLabel: string }}
 */
export function getReward(tier, currencySymbol = '$') {
  if (!tier) return { phoneMinutes: 0, money: 0, phoneLabel: 'No change', moneyLabel: 'No change' }
  return {
    phoneMinutes: tier.phoneMinutes ?? 0,
    money: tier.money ?? 0,
    phoneLabel: formatMinutes(tier.phoneMinutes ?? 0),
    moneyLabel:
      tier.money > 0
        ? `+${currencySymbol}${tier.money}`
        : tier.money < 0
        ? `-${currencySymbol}${Math.abs(tier.money)}`
        : 'No change',
  }
}

/**
 * Generate the Family Link instruction text.
 * @param {Object} tier
 * @param {number} phoneMinutes
 * @param {string} sistName
 * @returns {string}
 */
export function familyLinkInstruction(tier, phoneMinutes, sisterName = 'your sister') {
  if (!tier || phoneMinutes === 0) {
    return `No screen time adjustment needed this week. ${sisterName}'s base limits stay the same.`
  }

  const action = phoneMinutes > 0 ? 'increase' : 'decrease'
  const abs = Math.abs(phoneMinutes)
  const h = Math.floor(abs / 60)
  const m = abs % 60
  const timeStr = m > 0 ? `${h > 0 ? `${h} hour${h > 1 ? 's' : ''} and ` : ''}${m} minute${m > 1 ? 's' : ''}` : `${h} hour${h > 1 ? 's' : ''}`

  return `📱 Google Family Link Instruction
────────────────────────────────
1. Open Family Link on your phone
2. Tap on ${sisterName}'s profile
3. Go to "Screen time" → "Set limits"
4. ${phoneMinutes > 0 ? 'Add' : 'Remove'} ${timeStr} to the weekend daily limit
   (Current base: 4 hrs → New weekend: ${formatTotal(240, phoneMinutes)})
5. Tap "Save"

Tier achieved: ${tier.emoji} ${tier.name}
Reason: Weekly score earned this reward.`
}

function formatTotal(baseMinutes, delta) {
  const total = baseMinutes + delta
  const h = Math.floor(total / 60)
  const m = total % 60
  return m > 0 ? `${h} hr ${m} min` : `${h} hrs`
}
