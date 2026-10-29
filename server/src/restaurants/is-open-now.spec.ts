import { isOpenNow, type OpeningHourWindow } from './is-open-now'

const accepting = { isAcceptingOrders: true, timezone: 'UTC' }

function everyDay (window: {
  opensAt: string
  closesAt: string
}): OpeningHourWindow[] {
  return [0, 1, 2, 3, 4, 5, 6].map((dayOfWeek) => ({ dayOfWeek, ...window }))
}

describe('isOpenNow', () => {
  it('stays closed when the manual switch is off, even inside hours', () => {
    const open = isOpenNow(
      { isAcceptingOrders: false, timezone: 'UTC' },
      everyDay({ opensAt: '00:00', closesAt: '23:59' }),
      new Date('2026-06-15T12:00:00.000Z'),
    )
    expect(open).toBe(false)
  })

  it('is open inside a same-day window and closed outside it', () => {
    const hours = everyDay({ opensAt: '09:00', closesAt: '17:00' })
    expect(
      isOpenNow(accepting, hours, new Date('2026-06-15T12:00:00.000Z')),
    ).toBe(true)
    expect(
      isOpenNow(accepting, hours, new Date('2026-06-15T09:00:00.000Z')),
    ).toBe(true)
    expect(
      isOpenNow(accepting, hours, new Date('2026-06-15T08:59:00.000Z')),
    ).toBe(false)
    expect(
      isOpenNow(accepting, hours, new Date('2026-06-15T17:00:00.000Z')),
    ).toBe(false)
  })

  it('covers both sides of a window that crosses midnight', () => {
    const hours = everyDay({ opensAt: '22:00', closesAt: '02:00' })
    expect(
      isOpenNow(accepting, hours, new Date('2026-06-15T22:30:00.000Z')),
    ).toBe(true)
    expect(
      isOpenNow(accepting, hours, new Date('2026-06-15T22:00:00.000Z')),
    ).toBe(true)
    expect(
      isOpenNow(accepting, hours, new Date('2026-06-15T01:30:00.000Z')),
    ).toBe(true)
    expect(
      isOpenNow(accepting, hours, new Date('2026-06-15T02:00:00.000Z')),
    ).toBe(false)
    expect(
      isOpenNow(accepting, hours, new Date('2026-06-15T21:00:00.000Z')),
    ).toBe(false)
  })

  it('uses the restaurant timezone, not UTC', () => {
    const hours = everyDay({ opensAt: '22:00', closesAt: '23:00' })
    const now = new Date('2026-01-15T22:30:00.000Z')
    expect(isOpenNow({ ...accepting, timezone: 'UTC' }, hours, now)).toBe(true)
    expect(
      isOpenNow({ ...accepting, timezone: 'Asia/Jerusalem' }, hours, now),
    ).toBe(false)
  })

  it('keeps a Saturday overnight window open on Sunday morning only', () => {
    const hours: OpeningHourWindow[] = [
      { dayOfWeek: 6, opensAt: '22:00', closesAt: '02:00' },
    ]
    expect(
      isOpenNow(accepting, hours, new Date('2026-06-14T01:00:00.000Z')),
    ).toBe(true)
    expect(
      isOpenNow(accepting, hours, new Date('2026-06-13T01:00:00.000Z')),
    ).toBe(false)
    expect(
      isOpenNow(accepting, hours, new Date('2026-06-14T23:00:00.000Z')),
    ).toBe(false)
  })

  it('keeps a Sunday-only window closed on Monday', () => {
    const hours: OpeningHourWindow[] = [
      { dayOfWeek: 0, opensAt: '09:00', closesAt: '17:00' },
    ]
    expect(
      isOpenNow(accepting, hours, new Date('2026-06-14T12:00:00.000Z')),
    ).toBe(true)
    expect(
      isOpenNow(accepting, hours, new Date('2026-06-15T12:00:00.000Z')),
    ).toBe(false)
  })
})
