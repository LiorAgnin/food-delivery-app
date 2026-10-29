import { type INestApplication } from '@nestjs/common'
import { JwtService } from '@nestjs/jwt'
import { randomUUID } from 'node:crypto'
import { and, eq } from 'drizzle-orm'
import request from 'supertest'
import { issueTokenForPhone } from '../src/auth/print-token'
import { DRIZZLE, type Database } from '../src/db/database.module'
import { customers, menuCategories, menuItems, orders } from '../src/db/schema'
import { createTestApp, destroyTestApp } from './setup'

type Restaurant = {
  id: string
  name: string
  isOpen: boolean
  minOrderAgorot: number
  deliveryFeeAgorot: number
}

type MenuItem = {
  id: string
  name: string
  priceAgorot: number
  isAvailable: boolean
}

type MenuCategory = { name: string; items: MenuItem[] }

type StatusEvent = {
  from: string | null
  to: string
  actor: string
  at: string
}

type OrderBody = {
  id: string
  status: string
  restaurant: { id: string; name: string }
  items: Array<{
    menuItemId: string | null
    name: string
    unitPriceAgorot: number
    quantity: number
    lineTotalAgorot: number
  }>
  subtotalAgorot: number
  deliveryFeeAgorot: number
  totalAgorot: number
  statusHistory: StatusEvent[]
  createdAt: string
  updatedAt: string
}

const jwt = new JwtService({ secret: 'test-secret' })

function customerIdOf (token: string): string {
  const payload = jwt.verify<{ sub: string }>(token)
  return payload.sub
}

function auth (token: string): { Authorization: string } {
  return { Authorization: `Bearer ${token}` }
}

function itemNamed (categories: MenuCategory[], name: string): MenuItem {
  for (const category of categories) {
    const found = category.items.find((item) => item.name === name)
    if (found) return found
  }
  throw new Error(`menu item not found: ${name}`)
}

async function loadMenu (
  app: INestApplication,
  restaurantId: string,
): Promise<MenuCategory[]> {
  const response = await request(app.getHttpServer())
    .get(`/api/restaurants/${restaurantId}/menu`)
    .expect(200)
  return response.body.categories as MenuCategory[]
}

describe('orders', () => {
  let app: INestApplication
  let db: Database
  let alei: Restaurant
  let grill: Restaurant
  let trattoria: Restaurant
  let falafel: Restaurant
  let burger: MenuItem
  let fries: MenuItem
  let soda: MenuItem
  let truffle: MenuItem

  beforeAll(async () => {
    app = await createTestApp()
    db = app.get<Database>(DRIZZLE)
    const listed = await request(app.getHttpServer())
      .get('/api/restaurants')
      .expect(200)
    const restaurants = listed.body.restaurants as Restaurant[]
    const byName = (name: string): Restaurant => {
      const found = restaurants.find((restaurant) => restaurant.name === name)
      if (!found) throw new Error(`restaurant not found: ${name}`)
      return found
    }
    alei = byName('Alei Gefen')
    grill = byName('HaTachana Grill')
    trattoria = byName('Trattoria HaYarkon')
    falafel = byName('Falafel HaShuk')

    burger = itemNamed(await loadMenu(app, alei.id), 'Vegan burger')
    fries = itemNamed(await loadMenu(app, alei.id), 'Sweet potato fries')
    soda = itemNamed(await loadMenu(app, alei.id), 'Soda water')
    truffle = itemNamed(
      await loadMenu(app, trattoria.id),
      'White truffle tagliatelle',
    )

    expect(alei.minOrderAgorot).toBe(4500)
    expect(alei.deliveryFeeAgorot).toBe(1200)
    expect(burger.priceAgorot).toBe(5200)
    expect(fries.priceAgorot).toBe(2800)
    expect(soda.priceAgorot).toBe(900)
    expect(truffle.isAvailable).toBe(false)
    expect(falafel.isOpen).toBe(false)
  }, 180000)

  afterAll(async () => {
    await destroyTestApp()
  })

  function postOrder (
    token: string,
    key: string | undefined,
    body: {
      restaurantId: string
      items: { menuItemId: string; quantity: number }[]
    },
  ) {
    const call = request(app.getHttpServer())
      .post('/api/orders')
      .set(auth(token))
      .send(body)
    if (key !== undefined) call.set('Idempotency-Key', key)
    return call
  }

  async function ordersWithKey (
    customerId: string,
    idempotencyKey: string,
  ): Promise<number> {
    const rows = await db
      .select({ id: orders.id })
      .from(orders)
      .where(
        and(
          eq(orders.customerId, customerId),
          eq(orders.idempotencyKey, idempotencyKey),
        ),
      )
    return rows.length
  }

  it('places an order and walks it to DELIVERED', async () => {
    const token = await issueTokenForPhone('+972501110010')
    const customerId = customerIdOf(token)
    const key = randomUUID()
    const body = {
      restaurantId: alei.id,
      items: [
        { menuItemId: fries.id, quantity: 1 },
        { menuItemId: burger.id, quantity: 1 },
      ],
    }

    const created = await postOrder(token, key, body).expect(201)
    const order = created.body as OrderBody
    expect(order.status).toBe('PLACED')
    expect(order.restaurant).toEqual({ id: alei.id, name: 'Alei Gefen' })
    expect(order.subtotalAgorot).toBe(8000)
    expect(order.deliveryFeeAgorot).toBe(1200)
    expect(order.totalAgorot).toBe(9200)
    expect(order.items).toEqual([
      {
        menuItemId: fries.id,
        name: 'Sweet potato fries',
        unitPriceAgorot: 2800,
        quantity: 1,
        lineTotalAgorot: 2800,
      },
      {
        menuItemId: burger.id,
        name: 'Vegan burger',
        unitPriceAgorot: 5200,
        quantity: 1,
        lineTotalAgorot: 5200,
      },
    ])
    expect(order.statusHistory).toEqual([
      expect.objectContaining({
        from: null,
        to: 'PLACED',
        actor: 'customer',
      }),
    ])
    expect(Date.parse(order.statusHistory[0]?.at ?? '')).not.toBeNaN()
    expect(Date.parse(order.createdAt)).not.toBeNaN()
    expect(Date.parse(order.updatedAt)).not.toBeNaN()

    const replayed = await postOrder(token, key, {
      restaurantId: alei.id,
      items: [
        { menuItemId: burger.id, quantity: 1 },
        { menuItemId: fries.id, quantity: 1 },
      ],
    }).expect(200)
    expect(replayed.body.id).toBe(order.id)
    expect(replayed.body.statusHistory).toHaveLength(1)
    expect(await ordersWithKey(customerId, key)).toBe(1)

    const steps: Array<[string, string]> = [
      ['ACCEPTED', 'restaurant'],
      ['PREPARING', 'restaurant'],
      ['PICKED_UP', 'courier'],
      ['DELIVERED', 'courier'],
    ]
    let current = 'PLACED'
    for (const [status, actor] of steps) {
      const advanced = await request(app.getHttpServer())
        .patch(`/api/orders/${order.id}/status`)
        .send({ status, actor })
        .expect(200)
      expect(advanced.body.status).toBe(status)
      current = status
    }

    const fetched = await request(app.getHttpServer())
      .get(`/api/orders/${order.id}`)
      .set(auth(token))
      .expect(200)
    const history = (fetched.body as OrderBody).statusHistory
    expect(fetched.body.status).toBe('DELIVERED')
    expect(history.map((event) => [event.from, event.to, event.actor])).toEqual(
      [
        [null, 'PLACED', 'customer'],
        ['PLACED', 'ACCEPTED', 'restaurant'],
        ['ACCEPTED', 'PREPARING', 'restaurant'],
        ['PREPARING', 'PICKED_UP', 'courier'],
        ['PICKED_UP', 'DELIVERED', 'courier'],
      ],
    )
    const times = history.map((event) => Date.parse(event.at))
    for (let index = 1; index < times.length; index += 1) {
      expect(times[index]).toBeGreaterThanOrEqual(times[index - 1] ?? 0)
    }
    expect(current).toBe('DELIVERED')

    const conflict = await postOrder(token, key, {
      restaurantId: alei.id,
      items: [{ menuItemId: burger.id, quantity: 2 }],
    }).expect(409)
    expect(conflict.body.error.code).toBe('IDEMPOTENCY_CONFLICT')
    expect(await ordersWithKey(customerId, key)).toBe(1)

    const still = await request(app.getHttpServer())
      .get(`/api/orders/${order.id}`)
      .set(auth(token))
      .expect(200)
    expect(still.body.status).toBe('DELIVERED')
    expect(still.body.items).toHaveLength(2)
  })

  it('returns the winner when two creates share one idempotency key', async () => {
    const token = await issueTokenForPhone('+972501110011')
    const customerId = customerIdOf(token)
    const key = randomUUID()
    const body = {
      restaurantId: alei.id,
      items: [{ menuItemId: burger.id, quantity: 1 }],
    }
    const [left, right] = await Promise.all([
      postOrder(token, key, body),
      postOrder(token, key, body),
    ])
    expect([left.status, right.status].sort()).toEqual([200, 201])
    expect(left.body.id).toBe(right.body.id)
    expect(left.body.totalAgorot).toBe(6400)
    expect(await ordersWithKey(customerId, key)).toBe(1)
  })

  it('lets another customer reuse the same idempotency key', async () => {
    const firstToken = await issueTokenForPhone('+972501110012')
    const secondToken = await issueTokenForPhone('+972501110013')
    const key = randomUUID()
    const body = {
      restaurantId: alei.id,
      items: [{ menuItemId: burger.id, quantity: 1 }],
    }
    const first = await postOrder(firstToken, key, body).expect(201)
    const second = await postOrder(secondToken, key, body).expect(201)
    expect(second.body.id).not.toBe(first.body.id)
  })

  it('rejects a closed restaurant, an unavailable item, a foreign item, and a short subtotal', async () => {
    const token = await issueTokenForPhone('+972501110020')
    const shawarma = itemNamed(
      await loadMenu(app, falafel.id),
      'Shawarma in pita',
    )

    const closed = await postOrder(token, randomUUID(), {
      restaurantId: falafel.id,
      items: [{ menuItemId: shawarma.id, quantity: 1 }],
    }).expect(422)
    expect(closed.body.error.code).toBe('RESTAURANT_CLOSED')

    const unavailable = await postOrder(token, randomUUID(), {
      restaurantId: trattoria.id,
      items: [{ menuItemId: truffle.id, quantity: 1 }],
    }).expect(422)
    expect(unavailable.body.error.code).toBe('ITEM_UNAVAILABLE')
    expect(unavailable.body.error.details.menuItemIds).toEqual([truffle.id])

    const foreign = await postOrder(token, randomUUID(), {
      restaurantId: grill.id,
      items: [{ menuItemId: burger.id, quantity: 1 }],
    }).expect(422)
    expect(foreign.body.error.code).toBe('ITEM_NOT_IN_RESTAURANT')
    expect(foreign.body.error.details.menuItemIds).toEqual([burger.id])

    const below = await postOrder(token, randomUUID(), {
      restaurantId: alei.id,
      items: [{ menuItemId: soda.id, quantity: 1 }],
    }).expect(422)
    expect(below.body.error.code).toBe('BELOW_MINIMUM')
    expect(below.body.error.details).toEqual({
      minOrderAgorot: 4500,
      subtotalAgorot: 900,
    })
  })

  it('rejects an empty list, duplicate ids, a bad quantity, and a missing idempotency key', async () => {
    const token = await issueTokenForPhone('+972501110021')
    const restaurantId = alei.id

    const empty = await postOrder(token, randomUUID(), {
      restaurantId,
      items: [],
    }).expect(400)
    expect(empty.body.error.code).toBe('VALIDATION_FAILED')

    const duplicate = await postOrder(token, randomUUID(), {
      restaurantId,
      items: [
        { menuItemId: burger.id, quantity: 1 },
        { menuItemId: burger.id, quantity: 1 },
      ],
    }).expect(400)
    expect(duplicate.body.error.code).toBe('VALIDATION_FAILED')

    const zero = await postOrder(token, randomUUID(), {
      restaurantId,
      items: [{ menuItemId: burger.id, quantity: 0 }],
    }).expect(400)
    expect(zero.body.error.code).toBe('VALIDATION_FAILED')

    const tooMany = await postOrder(token, randomUUID(), {
      restaurantId,
      items: [{ menuItemId: burger.id, quantity: 51 }],
    }).expect(400)
    expect(tooMany.body.error.code).toBe('VALIDATION_FAILED')

    const missingKey = await postOrder(token, undefined, {
      restaurantId,
      items: [{ menuItemId: burger.id, quantity: 1 }],
    }).expect(400)
    expect(missingKey.body.error.code).toBe('VALIDATION_FAILED')
  })

  it("returns 404 for another customer's order", async () => {
    const owner = await issueTokenForPhone('+972501110030')
    const other = await issueTokenForPhone('+972501110031')
    const created = await postOrder(owner, randomUUID(), {
      restaurantId: alei.id,
      items: [{ menuItemId: burger.id, quantity: 1 }],
    }).expect(201)

    const hidden = await request(app.getHttpServer())
      .get(`/api/orders/${created.body.id}`)
      .set(auth(other))
      .expect(404)
    expect(hidden.body.error.code).toBe('NOT_FOUND')

    const visible = await request(app.getHttpServer())
      .get(`/api/orders/${created.body.id}`)
      .set(auth(owner))
      .expect(200)
    expect(visible.body.id).toBe(created.body.id)
  })

  it('rejects an illegal transition and records no further event', async () => {
    const token = await issueTokenForPhone('+972501110040')
    const created = await postOrder(token, randomUUID(), {
      restaurantId: alei.id,
      items: [{ menuItemId: burger.id, quantity: 1 }],
    }).expect(201)

    const rejected = await request(app.getHttpServer())
      .patch(`/api/orders/${created.body.id}/status`)
      .send({ status: 'DELIVERED', actor: 'courier' })
      .expect(409)
    expect(rejected.body.error.code).toBe('INVALID_TRANSITION')
    expect(rejected.body.error.details).toEqual({
      from: 'PLACED',
      to: 'DELIVERED',
      actor: 'courier',
    })

    const fetched = await request(app.getHttpServer())
      .get(`/api/orders/${created.body.id}`)
      .set(auth(token))
      .expect(200)
    expect(fetched.body.status).toBe('PLACED')
    expect(fetched.body.statusHistory).toHaveLength(1)
  })

  it('lets only one of two concurrent status updates win', async () => {
    const token = await issueTokenForPhone('+972501110050')
    const created = await postOrder(token, randomUUID(), {
      restaurantId: alei.id,
      items: [{ menuItemId: burger.id, quantity: 1 }],
    }).expect(201)

    const [left, right] = await Promise.all([
      request(app.getHttpServer())
        .patch(`/api/orders/${created.body.id}/status`)
        .send({ status: 'ACCEPTED', actor: 'restaurant' }),
      request(app.getHttpServer())
        .patch(`/api/orders/${created.body.id}/status`)
        .send({ status: 'ACCEPTED', actor: 'restaurant' }),
    ])
    expect([left.status, right.status].sort()).toEqual([200, 409])
    const conflict = left.status === 409 ? left : right
    const winner = left.status === 200 ? left : right
    expect(conflict.body.error.code).toBe('CONCURRENT_UPDATE')
    expect(winner.body.status).toBe('ACCEPTED')

    const fetched = await request(app.getHttpServer())
      .get(`/api/orders/${created.body.id}`)
      .set(auth(token))
      .expect(200)
    expect(fetched.body.status).toBe('ACCEPTED')
    expect(
      fetched.body.statusHistory.map((event: StatusEvent) => event.to),
    ).toEqual(['PLACED', 'ACCEPTED'])
  })

  it('keeps the snapshotted price after the menu price changes', async () => {
    const token = await issueTokenForPhone('+972501110060')
    const created = await postOrder(token, randomUUID(), {
      restaurantId: alei.id,
      items: [{ menuItemId: fries.id, quantity: 2 }],
    }).expect(201)
    expect(created.body.subtotalAgorot).toBe(5600)
    expect(created.body.totalAgorot).toBe(6800)

    await db
      .update(menuItems)
      .set({ priceAgorot: 111, updatedAt: new Date() })
      .where(eq(menuItems.id, fries.id))
    try {
      const fetched = await request(app.getHttpServer())
        .get(`/api/orders/${created.body.id}`)
        .set(auth(token))
        .expect(200)
      expect(fetched.body.items).toEqual([
        {
          menuItemId: fries.id,
          name: 'Sweet potato fries',
          unitPriceAgorot: 2800,
          quantity: 2,
          lineTotalAgorot: 5600,
        },
      ])
    } finally {
      await db
        .update(menuItems)
        .set({ priceAgorot: 2800, updatedAt: new Date() })
        .where(eq(menuItems.id, fries.id))
    }
  })

  it('lets a customer cancel a placed order and rejects that cancel after acceptance', async () => {
    const token = await issueTokenForPhone('+972501110070')
    const placed = await postOrder(token, randomUUID(), {
      restaurantId: alei.id,
      items: [{ menuItemId: burger.id, quantity: 1 }],
    }).expect(201)

    const cancelled = await request(app.getHttpServer())
      .patch(`/api/orders/${placed.body.id}/status`)
      .send({ status: 'CANCELLED', actor: 'customer' })
      .expect(200)
    expect(cancelled.body.status).toBe('CANCELLED')

    const accepted = await postOrder(token, randomUUID(), {
      restaurantId: alei.id,
      items: [{ menuItemId: burger.id, quantity: 1 }],
    }).expect(201)
    await request(app.getHttpServer())
      .patch(`/api/orders/${accepted.body.id}/status`)
      .send({ status: 'ACCEPTED', actor: 'restaurant' })
      .expect(200)
    const rejected = await request(app.getHttpServer())
      .patch(`/api/orders/${accepted.body.id}/status`)
      .send({ status: 'CANCELLED', actor: 'customer' })
      .expect(409)
    expect(rejected.body.error.code).toBe('INVALID_TRANSITION')
    expect(rejected.body.error.details).toEqual({
      from: 'ACCEPTED',
      to: 'CANCELLED',
      actor: 'customer',
    })
  })

  it('returns 401 when a valid token belongs to a deleted customer', async () => {
    const token = await issueTokenForPhone('+972501110080')
    const customerId = customerIdOf(token)
    await db.delete(customers).where(eq(customers.id, customerId))

    const response = await postOrder(token, randomUUID(), {
      restaurantId: alei.id,
      items: [{ menuItemId: burger.id, quantity: 1 }],
    }).expect(401)
    expect(response.body.error.code).toBe('UNAUTHORIZED')
  })

  it('accepts an uppercase menu item id for an item that is on the menu', async () => {
    const token = await issueTokenForPhone('+972501110090')
    const [category] = await db
      .select({ id: menuCategories.id })
      .from(menuCategories)
      .where(eq(menuCategories.restaurantId, alei.id))
      .limit(1)
    if (!category) throw new Error('Alei Gefen has no menu category')
    const menuItemId = 'abcdefab-cdef-4abc-8def-abcdefabcdef'
    await db.insert(menuItems).values({
      id: menuItemId,
      restaurantId: alei.id,
      categoryId: category.id,
      name: 'Hex plate',
      priceAgorot: 4500,
      dietaryTags: [],
    })

    const created = await postOrder(token, randomUUID(), {
      restaurantId: alei.id,
      items: [{ menuItemId: menuItemId.toUpperCase(), quantity: 1 }],
    }).expect(201)
    expect(created.body.items).toEqual([
      {
        menuItemId,
        name: 'Hex plate',
        unitPriceAgorot: 4500,
        quantity: 1,
        lineTotalAgorot: 4500,
      },
    ])
    expect(created.body.subtotalAgorot).toBe(4500)
    expect(created.body.totalAgorot).toBe(5700)
  })
})
