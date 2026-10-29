import { DomainError } from '../common/domain-error'
import {
  type CatalogItem,
  type PriceableRestaurant,
  priceOrder,
} from './price-order'

const alei: PriceableRestaurant = {
  id: 'rest-alei',
  name: 'Alei Gefen',
  minOrderAgorot: 4500,
  deliveryFeeAgorot: 1200,
  isOpen: true,
}

function catalogItem (
  overrides: Partial<CatalogItem> & Pick<CatalogItem, 'id' | 'priceAgorot'>,
): CatalogItem {
  return {
    restaurantId: alei.id,
    name: overrides.id,
    isAvailable: true,
    ...overrides,
  }
}

function place (
  items: { menuItemId: string; quantity: number }[],
  restaurant: PriceableRestaurant | null = alei,
  catalog: CatalogItem[] = [],
) {
  return priceOrder({ items }, restaurant, catalog)
}

function failure (
  items: { menuItemId: string; quantity: number }[],
  restaurant: PriceableRestaurant | null = alei,
  catalog: CatalogItem[] = [],
): DomainError {
  try {
    place(items, restaurant, catalog)
  } catch (error) {
    if (error instanceof DomainError) return error
    throw error
  }
  throw new Error('expected priceOrder to throw')
}

describe('priceOrder', () => {
  it('prices lines from the catalog and adds the delivery fee', () => {
    const priced = place(
      [
        { menuItemId: 'burger', quantity: 2 },
        { menuItemId: 'juice', quantity: 1 },
      ],
      alei,
      [
        catalogItem({
          id: 'juice',
          name: 'Fresh orange juice',
          priceAgorot: 1600,
        }),
        catalogItem({
          id: 'burger',
          name: 'Vegan burger',
          priceAgorot: 5200,
        }),
      ],
    )

    expect(priced).toEqual({
      restaurantId: 'rest-alei',
      restaurantName: 'Alei Gefen',
      subtotalAgorot: 12000,
      deliveryFeeAgorot: 1200,
      totalAgorot: 13200,
      items: [
        {
          menuItemId: 'burger',
          name: 'Vegan burger',
          unitPriceAgorot: 5200,
          quantity: 2,
          lineTotalAgorot: 10400,
        },
        {
          menuItemId: 'juice',
          name: 'Fresh orange juice',
          unitPriceAgorot: 1600,
          quantity: 1,
          lineTotalAgorot: 1600,
        },
      ],
    })
  })

  it('accepts a subtotal that equals the minimum', () => {
    const priced = place(
      [{ menuItemId: 'stew', quantity: 1 }],
      alei,
      [catalogItem({ id: 'stew', name: 'Stew', priceAgorot: 4500 })],
    )

    expect(priced.subtotalAgorot).toBe(4500)
    expect(priced.totalAgorot).toBe(5700)
  })

  it('accepts a quantity of 50', () => {
    const priced = place(
      [{ menuItemId: 'side', quantity: 50 }],
      alei,
      [catalogItem({ id: 'side', name: 'Side', priceAgorot: 100 })],
    )

    expect(priced.items[0]).toEqual({
      menuItemId: 'side',
      name: 'Side',
      unitPriceAgorot: 100,
      quantity: 50,
      lineTotalAgorot: 5000,
    })
    expect(priced.subtotalAgorot).toBe(5000)
    expect(priced.totalAgorot).toBe(6200)
  })

  it('rejects an empty item list before it looks at the restaurant', () => {
    const error = failure([], null)
    expect(error.code).toBe('VALIDATION_FAILED')
  })

  it('rejects more than 50 items', () => {
    const items = Array.from({ length: 51 }, (_, index) => ({
      menuItemId: `item-${index}`,
      quantity: 1,
    }))
    expect(failure(items, null).code).toBe('VALIDATION_FAILED')
  })

  it('rejects a quantity of 0', () => {
    expect(
      failure([{ menuItemId: 'burger', quantity: 0 }], null).code,
    ).toBe('VALIDATION_FAILED')
  })

  it('rejects a quantity of 51', () => {
    expect(
      failure([{ menuItemId: 'burger', quantity: 51 }], null).code,
    ).toBe('VALIDATION_FAILED')
  })

  it('rejects a fractional quantity', () => {
    expect(
      failure([{ menuItemId: 'burger', quantity: 1.5 }], null).code,
    ).toBe('VALIDATION_FAILED')
  })

  it('rejects duplicate menu item ids', () => {
    expect(
      failure(
        [
          { menuItemId: 'burger', quantity: 1 },
          { menuItemId: 'burger', quantity: 2 },
        ],
        null,
      ).code,
    ).toBe('VALIDATION_FAILED')
  })

  it('reports a missing restaurant', () => {
    expect(
      failure([{ menuItemId: 'burger', quantity: 1 }], null).code,
    ).toBe('NOT_FOUND')
  })

  it('reports a closed restaurant before it checks the items', () => {
    const error = failure(
      [{ menuItemId: 'elsewhere', quantity: 1 }],
      { ...alei, isOpen: false },
      [],
    )
    expect(error.code).toBe('RESTAURANT_CLOSED')
  })

  it('reports every item that is not on this restaurant menu', () => {
    const error = failure(
      [
        { menuItemId: 'burger', quantity: 1 },
        { menuItemId: 'foreign', quantity: 1 },
        { menuItemId: 'missing', quantity: 1 },
      ],
      alei,
      [
        catalogItem({ id: 'burger', priceAgorot: 5200, isAvailable: false }),
        catalogItem({
          id: 'foreign',
          restaurantId: 'rest-other',
          priceAgorot: 1000,
          isAvailable: false,
        }),
      ],
    )

    expect(error.code).toBe('ITEM_NOT_IN_RESTAURANT')
    expect(error.details).toEqual({ menuItemIds: ['foreign', 'missing'] })
  })

  it('reports unavailable items before the minimum', () => {
    const error = failure(
      [
        { menuItemId: 'soup', quantity: 1 },
        { menuItemId: 'fries', quantity: 1 },
      ],
      alei,
      [
        catalogItem({
          id: 'soup',
          name: 'Lentil soup',
          priceAgorot: 900,
          isAvailable: false,
        }),
        catalogItem({
          id: 'fries',
          name: 'Sweet potato fries',
          priceAgorot: 900,
          isAvailable: false,
        }),
      ],
    )

    expect(error.code).toBe('ITEM_UNAVAILABLE')
    expect(error.details).toEqual({ menuItemIds: ['soup', 'fries'] })
  })

  it('reports a subtotal under the minimum', () => {
    const error = failure(
      [{ menuItemId: 'soda', quantity: 4 }],
      alei,
      [catalogItem({ id: 'soda', name: 'Soda water', priceAgorot: 900 })],
    )

    expect(error.code).toBe('BELOW_MINIMUM')
    expect(error.details).toEqual({
      minOrderAgorot: 4500,
      subtotalAgorot: 3600,
    })
  })
})
