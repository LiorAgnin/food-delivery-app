export type OpenNowRestaurant = {
  isAcceptingOrders: boolean
  timezone: string
}

export type OpeningHourWindow = {
  dayOfWeek: number
  opensAt: string
  closesAt: string
}

const WEEKDAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']

// A window is [opens, closes). closesAt < opensAt runs through midnight and
// ends the next day. closesAt === opensAt is empty, not a 24h window.
export function isOpenNow (
  restaurant: OpenNowRestaurant,
  hours: OpeningHourWindow[],
  now: Date,
): boolean {
  if (!restaurant.isAcceptingOrders) return false

  const local = localClock(now, restaurant.timezone)
  const yesterday = (local.dayOfWeek + 6) % 7

  for (const row of hours) {
    const opens = parseTimeOfDay(row.opensAt)
    const closes = parseTimeOfDay(row.closesAt)
    if (closes === opens) continue

    if (closes > opens) {
      if (
        row.dayOfWeek === local.dayOfWeek &&
        local.minutes >= opens &&
        local.minutes < closes
      ) {
        return true
      }
      continue
    }

    if (row.dayOfWeek === local.dayOfWeek && local.minutes >= opens) return true
    if (row.dayOfWeek === yesterday && local.minutes < closes) return true
  }

  return false
}

export function parseTimeOfDay (value: string): number {
  const match = /^(\d{2}):(\d{2})(?::(\d{2})(?:\.\d+)?)?$/.exec(value.trim())
  if (!match) throw new Error(`Invalid time of day: ${value}`)
  const hour = Number(match[1])
  const minute = Number(match[2])
  if (hour > 23 || minute > 59) throw new Error(`Invalid time of day: ${value}`)
  return hour * 60 + minute
}

export function formatTimeOfDay (value: string): string {
  const minutes = parseTimeOfDay(value)
  const hour = Math.floor(minutes / 60)
  const minute = minutes % 60
  return `${String(hour).padStart(2, '0')}:${String(minute).padStart(2, '0')}`
}

function localClock (
  now: Date,
  timeZone: string,
): { dayOfWeek: number; minutes: number } {
  const parts = new Intl.DateTimeFormat('en-US', {
    timeZone,
    weekday: 'short',
    hour: '2-digit',
    minute: '2-digit',
    hourCycle: 'h23',
  }).formatToParts(now)

  const weekday = part(parts, 'weekday')
  const dayOfWeek = WEEKDAYS.indexOf(weekday)
  if (dayOfWeek < 0) throw new Error(`Unexpected weekday from Intl: ${weekday}`)

  let hour = Number(part(parts, 'hour'))
  const minute = Number(part(parts, 'minute'))
  if (hour === 24) hour = 0

  return { dayOfWeek, minutes: hour * 60 + minute }
}

function part (
  parts: Intl.DateTimeFormatPart[],
  type: Intl.DateTimeFormatPartTypes,
): string {
  const found = parts.find((item) => item.type === type)
  if (!found) throw new Error(`Missing Intl part ${type}`)
  return found.value
}
