import type { INestApplication } from '@nestjs/common'
import request from 'supertest'
import { createTestApp, destroyTestApp } from './setup'

type OpeningHour = { dayOfWeek: number; opensAt: string; closesAt: string }

type Restaurant = {
  id: string
  name: string
  cuisine: string
  address: string
  isOpen: boolean
  openingHours: OpeningHour[]
  minOrderAgorot: number
  deliveryFeeAgorot: number
}

type MenuItem = {
  id: string
  name: string
  isAvailable: boolean
  priceAgorot: number
  dietaryTags: string[]
}

type MenuCategory = { id: string; name: string; items: MenuItem[] }

async function menuOf (app: INestApplication, id: string | undefined): Promise<MenuCategory[]> {
  const response = await request(app.getHttpServer())
    .get(`/api/restaurants/${id}/menu`)
    .expect(200)
  return response.body.categories as MenuCategory[]
}

function itemsNamed (categories: MenuCategory[], categoryName: string): MenuItem[] {
  return categories.find((category) => category.name === categoryName)?.items ?? []
}

describe('catalog', () => {
  let app: INestApplication

  beforeAll(async () => {
    app = await createTestApp()
  })

  afterAll(async () => {
    await destroyTestApp()
  })

  it('GET /api/health returns ok', async () => {
    const response = await request(app.getHttpServer())
      .get('/api/health')
      .expect(200)
    expect(response.body).toEqual({ status: 'ok' })
  })

  it('lists open restaurants first, with the manual switch as the only closed one', async () => {
    const response = await request(app.getHttpServer())
      .get('/api/restaurants')
      .expect(200)
    const restaurants = response.body.restaurants as Restaurant[]

    expect(restaurants.map((restaurant) => ({
      name: restaurant.name,
      isOpen: restaurant.isOpen,
    }))).toEqual([
      { name: 'Alei Gefen', isOpen: true },
      { name: 'HaTachana Grill', isOpen: true },
      { name: 'Sushi Yama', isOpen: true },
      { name: 'Trattoria HaYarkon', isOpen: true },
      { name: 'Falafel HaShuk', isOpen: false },
    ])
    const alei = restaurants.find((restaurant) => restaurant.name === 'Alei Gefen')
    const grill = restaurants.find(
      (restaurant) => restaurant.name === 'HaTachana Grill',
    )
    const falafel = restaurants.find(
      (restaurant) => restaurant.name === 'Falafel HaShuk',
    )
    expect(falafel?.openingHours).toEqual(grill?.openingHours)
    expect(alei?.openingHours.filter((hour) => hour.dayOfWeek === 0)).toEqual([
      { dayOfWeek: 0, opensAt: '00:00', closesAt: '18:00' },
      { dayOfWeek: 0, opensAt: '18:00', closesAt: '00:00' },
    ])
    expect(alei?.openingHours.filter((hour) => hour.dayOfWeek === 1)).toEqual([
      { dayOfWeek: 1, opensAt: '00:00', closesAt: '12:00' },
      { dayOfWeek: 1, opensAt: '12:00', closesAt: '00:00' },
    ])

    for (const restaurant of restaurants) {
      expect(restaurant.minOrderAgorot).toEqual(expect.any(Number))
      expect(restaurant.deliveryFeeAgorot).toEqual(expect.any(Number))
      expect(restaurant.openingHours).toHaveLength(14)
    }
  })

  it('returns categories in sort order and keeps unavailable items', async () => {
    const list = await request(app.getHttpServer())
      .get('/api/restaurants')
      .expect(200)
    const trattoria = (list.body.restaurants as Restaurant[]).find(
      (restaurant) => restaurant.name === 'Trattoria HaYarkon',
    )
    expect(trattoria).toBeDefined()

    const response = await request(app.getHttpServer())
      .get(`/api/restaurants/${trattoria?.id}/menu`)
      .expect(200)

    const categories = response.body.categories as MenuCategory[]
    expect(categories.map((category) => category.name)).toEqual([
      'Starters',
      'Mains',
      'Drinks',
    ])
    expect(categories.map((category) => category.items.map((item) => item.name))).toEqual([
      ['Caprese', 'Focaccia', 'Minestrone'],
      [
        'Margherita',
        'Mushroom risotto',
        'Pepperoni pizza',
        'White truffle tagliatelle',
      ],
      ['Espresso', 'House red', 'Sparkling water'],
    ])

    const margherita = categories
      .flatMap((category) => category.items)
      .find((item) => item.name === 'Margherita')
    expect(margherita?.priceAgorot).toBe(5400)

    const unavailable = categories
      .flatMap((category) => category.items)
      .find((item) => item.name === 'White truffle tagliatelle')
    expect(unavailable?.isAvailable).toBe(false)
    expect(response.body.restaurant.id).toBe(trattoria?.id)
  })

  it('serves the dishes later search depends on', async () => {
    const list = await request(app.getHttpServer()).get('/api/restaurants').expect(200)
    const restaurants = list.body.restaurants as Restaurant[]
    const byName = new Map(restaurants.map((restaurant) => [restaurant.name, restaurant]))

    const sushi = byName.get('Sushi Yama')
    expect(sushi?.cuisine).toBe('Japanese')

    const veganMenu = await menuOf(app, byName.get('Alei Gefen')?.id)
    const veganMains = itemsNamed(veganMenu, 'Mains')
    expect(veganMains.find((item) => item.name === 'Vegan burger')).toMatchObject({
      priceAgorot: 5200,
      dietaryTags: ['vegan'],
      isAvailable: true,
    })
    expect(veganMains.find((item) => item.name === 'Lentil and mushroom stew')).toMatchObject({
      priceAgorot: 4800,
      dietaryTags: ['vegan'],
    })

    const grillMains = itemsNamed(
      await menuOf(app, byName.get('HaTachana Grill')?.id),
      'Mains',
    )
    expect(grillMains.map((item) => ({
      name: item.name,
      priceAgorot: item.priceAgorot,
      dietaryTags: item.dietaryTags,
    }))).toEqual([
      {
        name: 'Half spicy chicken',
        priceAgorot: 9200,
        dietaryTags: ['spicy'],
      },
      {
        name: 'Spicy chicken platter',
        priceAgorot: 7600,
        dietaryTags: ['spicy'],
      },
      {
        name: 'Spicy chicken schnitzel',
        priceAgorot: 5600,
        dietaryTags: ['spicy'],
      },
      {
        name: 'Spicy chicken skewer',
        priceAgorot: 4800,
        dietaryTags: ['spicy'],
      },
    ])
  })

  it('returns the NOT_FOUND envelope for an unknown restaurant', async () => {
    const response = await request(app.getHttpServer())
      .get('/api/restaurants/00000000-0000-4000-8000-000000000099/menu')
      .expect(404)

    expect(response.body).toEqual({
      error: {
        code: 'NOT_FOUND',
        message: 'Restaurant not found',
        details: {},
      },
    })
  })

  it('returns the VALIDATION_FAILED envelope for an invalid id', async () => {
    const response = await request(app.getHttpServer())
      .get('/api/restaurants/not-a-uuid/menu')
      .expect(400)

    expect(response.body.error.code).toBe('VALIDATION_FAILED')
    expect(response.body.error.details.fields.id).toEqual(['must be a UUID v4'])
  })
})
