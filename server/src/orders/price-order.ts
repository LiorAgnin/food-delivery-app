import { DomainError } from '../common/domain-error'

export type OrderItemRequest = {
  menuItemId: string
  quantity: number
}

export type CatalogItem = {
  id: string
  restaurantId: string
  name: string
  priceAgorot: number
  isAvailable: boolean
}

export type PriceableRestaurant = {
  id: string
  name: string
  minOrderAgorot: number
  deliveryFeeAgorot: number
  isOpen: boolean
}

export type PricedLine = {
  menuItemId: string
  name: string
  unitPriceAgorot: number
  quantity: number
  lineTotalAgorot: number
}

export type PricedOrder = {
  restaurantId: string
  restaurantName: string
  subtotalAgorot: number
  deliveryFeeAgorot: number
  totalAgorot: number
  items: PricedLine[]
}

const MIN_ITEMS = 1
const MAX_ITEMS = 50
const MIN_QUANTITY = 1
const MAX_QUANTITY = 50

export function priceOrder (
  request: { items: OrderItemRequest[] },
  restaurant: PriceableRestaurant | null,
  catalog: CatalogItem[],
): PricedOrder {
  if (
    request.items.length < MIN_ITEMS ||
    request.items.length > MAX_ITEMS
  ) {
    throw new DomainError('VALIDATION_FAILED', 'Validation failed', {
      fields: { items: ['must contain 1 to 50 items'] },
    })
  }

  const seen = new Set<string>()
  for (const [index, item] of request.items.entries()) {
    if (
      !Number.isInteger(item.quantity) ||
      item.quantity < MIN_QUANTITY ||
      item.quantity > MAX_QUANTITY
    ) {
      throw new DomainError('VALIDATION_FAILED', 'Validation failed', {
        fields: {
          [`items.${index}.quantity`]: ['must be an integer from 1 to 50'],
        },
      })
    }
    if (seen.has(item.menuItemId)) {
      throw new DomainError('VALIDATION_FAILED', 'Validation failed', {
        fields: { items: ['menuItemId must be unique'] },
      })
    }
    seen.add(item.menuItemId)
  }

  if (!restaurant) {
    throw new DomainError('NOT_FOUND', 'Restaurant not found')
  }
  if (!restaurant.isOpen) {
    throw new DomainError('RESTAURANT_CLOSED', 'Restaurant is closed')
  }

  const byId = new Map(catalog.map((item) => [item.id, item]))
  const foreign = request.items
    .filter((item) => {
      const row = byId.get(item.menuItemId)
      return !row || row.restaurantId !== restaurant.id
    })
    .map((item) => item.menuItemId)
  if (foreign.length > 0) {
    throw new DomainError(
      'ITEM_NOT_IN_RESTAURANT',
      'One or more items are not on this restaurant menu',
      { menuItemIds: foreign },
    )
  }

  const unavailable = request.items
    .filter((item) => byId.get(item.menuItemId)?.isAvailable !== true)
    .map((item) => item.menuItemId)
  if (unavailable.length > 0) {
    throw new DomainError(
      'ITEM_UNAVAILABLE',
      'One or more items are unavailable',
      { menuItemIds: unavailable },
    )
  }

  const items: PricedLine[] = request.items.map((item) => {
    const row = byId.get(item.menuItemId)
    if (!row) {
      throw new DomainError('INTERNAL', 'Catalog item disappeared after checks')
    }
    return {
      menuItemId: row.id,
      name: row.name,
      unitPriceAgorot: row.priceAgorot,
      quantity: item.quantity,
      lineTotalAgorot: row.priceAgorot * item.quantity,
    }
  })

  let subtotalAgorot = 0
  for (const item of items) subtotalAgorot += item.lineTotalAgorot

  if (subtotalAgorot < restaurant.minOrderAgorot) {
    throw new DomainError(
      'BELOW_MINIMUM',
      'Order subtotal is below the restaurant minimum',
      {
        minOrderAgorot: restaurant.minOrderAgorot,
        subtotalAgorot,
      },
    )
  }

  return {
    restaurantId: restaurant.id,
    restaurantName: restaurant.name,
    subtotalAgorot,
    deliveryFeeAgorot: restaurant.deliveryFeeAgorot,
    totalAgorot: subtotalAgorot + restaurant.deliveryFeeAgorot,
    items,
  }
}
