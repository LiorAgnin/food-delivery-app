import { createHash } from 'node:crypto'
import type { OrderItemRequest } from './price-order'

export function idempotencyBodyHash (body: {
  restaurantId: string
  items: readonly OrderItemRequest[]
}): string {
  const items = body.items
    .map((item) => ({
      menuItemId: item.menuItemId.toLowerCase(),
      quantity: item.quantity,
    }))
    .sort((left, right) =>
      left.menuItemId < right.menuItemId
        ? -1
        : left.menuItemId > right.menuItemId
          ? 1
          : 0,
    )
  const canonical = JSON.stringify({
    restaurantId: body.restaurantId.toLowerCase(),
    items,
  })
  return createHash('sha256').update(canonical).digest('hex')
}
