import { DomainError } from '../common/domain-error'
import { assertTransition } from './order-lifecycle'

const STATUSES = [
  'PLACED',
  'ACCEPTED',
  'PREPARING',
  'PICKED_UP',
  'DELIVERED',
  'CANCELLED',
] as const

const ACTORS = ['customer', 'restaurant', 'courier', 'system'] as const

type OrderStatus = (typeof STATUSES)[number]
type Actor = (typeof ACTORS)[number]

// Copied from CONTRACT.md's transition table. Not derived from TRANSITIONS.
const ALLOWED = new Set<string>([
  'PLACED|ACCEPTED|restaurant',
  'PLACED|CANCELLED|customer',
  'PLACED|CANCELLED|restaurant',
  'ACCEPTED|PREPARING|restaurant',
  'ACCEPTED|CANCELLED|restaurant',
  'PREPARING|PICKED_UP|courier',
  'PICKED_UP|DELIVERED|courier',
])

const CASES: Array<readonly [OrderStatus, OrderStatus, Actor]> =
  STATUSES.flatMap((from) =>
    STATUSES.flatMap((to) => ACTORS.map((actor) => [from, to, actor] as const)),
  )

function rejection (
  from: OrderStatus,
  to: OrderStatus,
  actor: Actor,
): DomainError {
  try {
    assertTransition(from, to, actor)
  } catch (error) {
    if (error instanceof DomainError) return error
    throw error
  }
  throw new Error(`expected ${from} → ${to} by ${actor} to throw`)
}

describe('assertTransition', () => {
  it('covers every from, to, and actor triple', () => {
    expect(STATUSES).toHaveLength(6)
    expect(ACTORS).toHaveLength(4)
    expect(CASES).toHaveLength(144)
    expect(ALLOWED.size).toBe(7)
  })

  it.each(CASES)('%s → %s by %s follows the contract', (from, to, actor) => {
    const key = `${from}|${to}|${actor}`
    if (ALLOWED.has(key)) {
      expect(() => {
        assertTransition(from, to, actor)
      }).not.toThrow()
      return
    }
    const error = rejection(from, to, actor)
    expect(error.code).toBe('INVALID_TRANSITION')
    expect(error.details).toEqual({ from, to, actor })
  })
})
