import { DomainError } from '../common/domain-error'
import type {
  OrderItemRow,
  OrderRow,
  OrderStatusEventRow,
} from '../db/schema'
import { ACTORS, type Actor, type OrderStatus } from './order-lifecycle'

export type OrderItemResponse = {
  menuItemId: string | null
  name: string
  unitPriceAgorot: number
  quantity: number
  lineTotalAgorot: number
}

export type OrderHistoryEntry = {
  from: OrderStatus | null
  to: OrderStatus
  actor: Actor
  at: string
}

export type OrderResponse = {
  id: string
  status: OrderStatus
  restaurant: { id: string; name: string }
  items: OrderItemResponse[]
  subtotalAgorot: number
  deliveryFeeAgorot: number
  totalAgorot: number
  statusHistory: OrderHistoryEntry[]
  createdAt: string
  updatedAt: string
}

const ACTOR_SET: ReadonlySet<string> = new Set(ACTORS)

function actorOf (value: string): Actor {
  if (!ACTOR_SET.has(value)) {
    throw new DomainError('INTERNAL', 'Order event has an unknown actor')
  }
  return value as Actor
}

export function toOrderResponse (
  order: OrderRow,
  items: OrderItemRow[],
  events: OrderStatusEventRow[],
): OrderResponse {
  return {
    id: order.id,
    status: order.status,
    restaurant: { id: order.restaurantId, name: order.restaurantName },
    items: items.map((item) => ({
      menuItemId: item.menuItemId,
      name: item.name,
      unitPriceAgorot: item.unitPriceAgorot,
      quantity: item.quantity,
      lineTotalAgorot: item.lineTotalAgorot,
    })),
    subtotalAgorot: order.subtotalAgorot,
    deliveryFeeAgorot: order.deliveryFeeAgorot,
    totalAgorot: order.totalAgorot,
    statusHistory: events.map((event) => ({
      from: event.fromStatus,
      to: event.toStatus,
      actor: actorOf(event.actor),
      at: event.createdAt.toISOString(),
    })),
    createdAt: order.createdAt.toISOString(),
    updatedAt: order.updatedAt.toISOString(),
  }
}
