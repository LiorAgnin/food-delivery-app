import { DomainError } from '../common/domain-error'

export const ORDER_STATUSES = [
  'PLACED',
  'ACCEPTED',
  'PREPARING',
  'PICKED_UP',
  'DELIVERED',
  'CANCELLED',
] as const

export type OrderStatus = (typeof ORDER_STATUSES)[number]

export const ACTORS = ['customer', 'restaurant', 'courier', 'system'] as const

export type Actor = (typeof ACTORS)[number]

const TRANSITIONS: Record<
  OrderStatus,
  Partial<Record<OrderStatus, readonly Actor[]>>
> = {
  PLACED: {
    ACCEPTED: ['restaurant'],
    CANCELLED: ['customer', 'restaurant'],
  },
  ACCEPTED: {
    PREPARING: ['restaurant'],
    CANCELLED: ['restaurant'],
  },
  PREPARING: {
    PICKED_UP: ['courier'],
  },
  PICKED_UP: {
    DELIVERED: ['courier'],
  },
  DELIVERED: {},
  CANCELLED: {},
}

export function assertTransition (
  from: OrderStatus,
  to: OrderStatus,
  actor: Actor,
): void {
  const allowed = TRANSITIONS[from][to]
  if (!allowed?.includes(actor)) {
    throw new DomainError(
      'INVALID_TRANSITION',
      'That status transition is not allowed',
      { from, to, actor },
    )
  }
}
