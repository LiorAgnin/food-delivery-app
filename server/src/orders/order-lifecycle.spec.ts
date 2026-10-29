import { DomainError } from '../common/domain-error'
import {
  ORDER_STATUSES,
  type Actor,
  type OrderStatus,
  assertTransition,
} from './order-lifecycle'

const ALLOWED: ReadonlyArray<readonly [OrderStatus, OrderStatus, Actor]> = [
  ['PLACED', 'ACCEPTED', 'restaurant'],
  ['PLACED', 'CANCELLED', 'customer'],
  ['PLACED', 'CANCELLED', 'restaurant'],
  ['ACCEPTED', 'PREPARING', 'restaurant'],
  ['ACCEPTED', 'CANCELLED', 'restaurant'],
  ['PREPARING', 'PICKED_UP', 'courier'],
  ['PICKED_UP', 'DELIVERED', 'courier'],
]

const ILLEGAL: ReadonlyArray<readonly [OrderStatus, OrderStatus, Actor]> = [
  ['PLACED', 'PREPARING', 'restaurant'],
  ['PLACED', 'PICKED_UP', 'courier'],
  ['PLACED', 'DELIVERED', 'courier'],
  ['ACCEPTED', 'PICKED_UP', 'courier'],
  ['ACCEPTED', 'DELIVERED', 'courier'],
  ['ACCEPTED', 'PLACED', 'restaurant'],
  ['PREPARING', 'DELIVERED', 'courier'],
  ['PREPARING', 'CANCELLED', 'restaurant'],
  ['PREPARING', 'ACCEPTED', 'restaurant'],
  ['PICKED_UP', 'CANCELLED', 'courier'],
]

const WRONG_ACTOR: ReadonlyArray<readonly [OrderStatus, OrderStatus, Actor]> = [
  ['PLACED', 'ACCEPTED', 'customer'],
  ['PLACED', 'ACCEPTED', 'courier'],
  ['PLACED', 'ACCEPTED', 'system'],
  ['PLACED', 'CANCELLED', 'courier'],
  ['PREPARING', 'PICKED_UP', 'restaurant'],
  ['PICKED_UP', 'DELIVERED', 'restaurant'],
]

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
  it.each(ALLOWED)('allows %s → %s by %s', (from, to, actor) => {
    expect(() => {
      assertTransition(from, to, actor)
    }).not.toThrow()
  })

  it.each(ILLEGAL)('rejects %s → %s by %s', (from, to, actor) => {
    const error = rejection(from, to, actor)
    expect(error.code).toBe('INVALID_TRANSITION')
    expect(error.details).toEqual({ from, to, actor })
  })

  it.each(WRONG_ACTOR)(
    'rejects %s → %s from the wrong actor %s',
    (from, to, actor) => {
      const error = rejection(from, to, actor)
      expect(error.code).toBe('INVALID_TRANSITION')
      expect(error.details).toEqual({ from, to, actor })
    },
  )

  it.each(['DELIVERED', 'CANCELLED'] as const)(
    'rejects every move out of terminal %s',
    (from) => {
      for (const to of ORDER_STATUSES) {
        const error = rejection(from, to, 'courier')
        expect(error.code).toBe('INVALID_TRANSITION')
        expect(error.details).toEqual({ from, to, actor: 'courier' })
      }
    },
  )
})
