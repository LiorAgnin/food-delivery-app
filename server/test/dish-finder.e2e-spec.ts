import type { INestApplication } from '@nestjs/common'
import type { Server } from 'http'
import request from 'supertest'
import { issueTokenForPhone } from '../src/auth/print-token'
import { resetEnvCache } from '../src/config/env'
import { createTestApp, destroyTestApp } from './setup'

type DishResult = {
  menuItem: {
    name: string
    description: string
    priceAgorot: number
    dietaryTags: string[]
    isAvailable: boolean
  }
  restaurant: { name: string; cuisine: string; isOpen: boolean }
  orderable: boolean
}

type SearchBody = {
  reply: string
  results: DishResult[]
  intent: {
    keywords: string[]
    excludeKeywords: string[]
    includeTags: string[]
    maxPriceAgorot: number | null
    openNowOnly: boolean
    sort: string
  }
  relaxed: string[]
}

const KNOWN_DISHES = [
  'Pepperoni pizza',
  'Vegan burger',
  'Spicy chicken skewer',
  'Spicy chicken schnitzel',
  'Spicy chicken platter',
  'Half spicy chicken',
  'Salmon nigiri sushi',
  'Lentil soup',
  'White truffle tagliatelle',
  'Hummus',
  'Hummus with beef',
  'Falafel in pita',
]

function user (content: string): { role: 'user'; content: string } {
  return { role: 'user', content }
}

describe('dish finder', () => {
  let app: INestApplication
  let server: Server
  let token: string

  beforeAll(async () => {
    app = await createTestApp()
    server = app.getHttpServer() as Server
    token = await issueTokenForPhone('+972500000001')
  })

  afterAll(async () => {
    await destroyTestApp()
  })

  async function search (
    messages: Array<{ role: 'user' | 'assistant'; content: string }>,
    auth = token,
  ): Promise<request.Response> {
    const call = request(server)
      .post('/api/dish-finder/search')
      .set('Content-Type', 'application/json')
      .send({ messages })
    if (auth) call.set('Authorization', `Bearer ${auth}`)
    return call
  }

  it('POST /api/dish-finder/search requires a bearer token', async () => {
    const response = await search([user('sushi')], '')
    expect(response.status).toBe(401)
    expect(response.body).toEqual({
      error: {
        code: 'UNAUTHORIZED',
        message: 'Missing bearer token',
        details: {},
      },
    })
  })

  it('rejects a conversation that does not end with the user', async () => {
    const response = await search([
      user('sushi'),
      { role: 'assistant', content: 'Found 1 sushi dish.' },
    ])
    expect(response.status).toBe(400)
    expect(response.body.error.code).toBe('VALIDATION_FAILED')
  })

  it('rejects more than 20 messages and a message over 500 characters', async () => {
    const tooMany = await search(Array.from({ length: 21 }, () => user('soup')))
    expect(tooMany.status).toBe(400)
    expect(tooMany.body.error.code).toBe('VALIDATION_FAILED')

    const tooLong = await search([user('a'.repeat(501))])
    expect(tooLong.status).toBe(400)
    expect(tooLong.body.error.code).toBe('VALIDATION_FAILED')
  })

  it('finds margherita and the other pizza from the seeded menu', async () => {
    const response = await search([user('I want a margherita pizza')])
    expect(response.status).toBe(200)
    const body = response.body as SearchBody
    const names = body.results.map((result) => result.menuItem.name)

    expect(names[0]).toMatch(/margherita/i)
    expect(names).toContain('Pepperoni pizza')
    expect(body.results.every((result) => result.orderable)).toBe(true)
    expect(body.relaxed).toEqual([])
    expect(body.intent.keywords).toEqual(['margherita', 'pizza'])
    expect(body.reply).toBe(`Found ${names.length} margherita pizza dishes.`)
    expect(replyOmitsAbsentDishes(body)).toBe(true)
  })

  it('returns spicy chicken under ₪60 from the grill, priced from the database', async () => {
    const response = await search([
      user('Something spicy with chicken under 60 ₪'),
    ])
    expect(response.status).toBe(200)
    const body = response.body as SearchBody
    const names = body.results.map((result) => result.menuItem.name)

    expect(names).toEqual(['Spicy chicken schnitzel', 'Spicy chicken skewer'])
    expect(body.results.map((result) => result.menuItem.priceAgorot)).toEqual([
      5600, 4800,
    ])
    expect(
      body.results.every(
        (result) =>
          result.menuItem.dietaryTags.includes('spicy') &&
          result.orderable &&
          result.menuItem.priceAgorot <= 6000,
      ),
    ).toBe(true)
    expect(body.intent).toMatchObject({
      keywords: ['chicken'],
      includeTags: ['spicy'],
      maxPriceAgorot: 6000,
      sort: 'relevance',
    })
    expect(body.relaxed).toEqual([])
    expect(body.reply).toBe('Found 2 spicy chicken dishes under ₪60.')
    expect(body.reply).not.toContain('48')
    expect(body.reply).not.toContain('56')
    expect(replyOmitsAbsentDishes(body)).toBe(true)
  })

  it('finds vegan dishes and leaves out burgers', async () => {
    const response = await search([user('Vegan dinner, not burgers')])
    expect(response.status).toBe(200)
    const body = response.body as SearchBody
    const names = body.results.map((result) => result.menuItem.name)

    expect(names).toHaveLength(10)
    expect(names).toContain('Lentil soup')
    expect(names).not.toContain('Vegan burger')
    expect(
      body.results.every(
        (result) =>
          result.menuItem.dietaryTags.includes('vegan') &&
          !/burger/i.test(result.menuItem.name) &&
          result.orderable,
      ),
    ).toBe(true)
    expect(body.intent.includeTags).toEqual(['vegan'])
    expect(body.intent.excludeKeywords).toEqual(['burger'])
    expect(body.reply).toBe('Found 10 vegan dishes.')
    expect(replyOmitsAbsentDishes(body)).toBe(true)
  })

  it('shows sushi only from restaurants that are open', async () => {
    const response = await search([
      user('Show me sushi from places that are open now'),
    ])
    expect(response.status).toBe(200)
    const body = response.body as SearchBody

    expect(body.results.length).toBeGreaterThan(0)
    expect(body.intent.openNowOnly).toBe(true)
    expect(body.intent.keywords).toEqual(['sushi'])
    expect(body.relaxed).toEqual([])
    for (const result of body.results) {
      expect(result.restaurant.isOpen).toBe(true)
      expect(result.orderable).toBe(true)
      expect(result.restaurant.name).not.toBe('Falafel HaShuk')
      const haystack = [
        result.menuItem.name,
        result.menuItem.description,
        result.restaurant.name,
        result.restaurant.cuisine,
      ]
        .join(' ')
        .toLowerCase()
      expect(haystack).toContain('sushi')
    }
    expect(body.reply).toBe(`Found ${body.results.length} sushi dishes.`)
    expect(replyOmitsAbsentDishes(body)).toBe(true)
  })

  it('ranks a closed restaurant after open matches and drops it for open now', async () => {
    const mixed = await search([user('hummus')])
    expect(mixed.status).toBe(200)
    const mixedBody = mixed.body as SearchBody
    expect(mixedBody.results.map((result) => result.menuItem.name)).toEqual([
      'Hummus with beef',
      'Hummus',
      'Falafel in pita',
    ])
    expect(mixedBody.results.map((result) => result.orderable)).toEqual([
      true,
      false,
      false,
    ])
    expect(mixedBody.results[1]?.restaurant.name).toBe('Falafel HaShuk')
    expect(mixedBody.results[2]?.restaurant.name).toBe('Falafel HaShuk')

    const openOnly = await search([
      user('Show me hummus from places that are open now'),
    ])
    expect(openOnly.status).toBe(200)
    const openBody = openOnly.body as SearchBody
    expect(openBody.results.map((result) => result.menuItem.name)).toEqual([
      'Hummus with beef',
    ])
    expect(openBody.results[0]?.restaurant.name).not.toBe('Falafel HaShuk')
    expect(openBody.results[0]?.orderable).toBe(true)
  })

  it('ranks an unavailable dish last', async () => {
    const response = await search([user('Show me Italian')])
    expect(response.status).toBe(200)
    const body = response.body as SearchBody
    const last = body.results[body.results.length - 1]

    expect(body.results.length).toBeGreaterThan(1)
    expect(body.results.slice(0, -1).every((result) => result.orderable)).toBe(
      true,
    )
    expect(last?.orderable).toBe(false)
    expect(last?.menuItem.isAvailable).toBe(false)
    expect(last?.menuItem.name).toBe('White truffle tagliatelle')
    expect(
      body.results.every((result) => result.restaurant.cuisine === 'Italian'),
    ).toBe(true)
  })

  it('relaxes the price ceiling and says so', async () => {
    const response = await search([user('Vegan burger under 10')])
    expect(response.status).toBe(200)
    const body = response.body as SearchBody

    expect(body.results.map((result) => result.menuItem.name)).toEqual([
      'Vegan burger',
    ])
    expect(body.results[0]?.menuItem.priceAgorot).toBe(5200)
    expect(body.relaxed).toEqual(['maxPriceAgorot'])
    expect(body.intent.maxPriceAgorot).toBe(1000)
    expect(body.reply).toBe(
      'Nothing vegan burger under ₪10, but here are vegan burger dishes slightly above that.',
    )
    expect(body.reply).not.toContain('52')
    expect(replyOmitsAbsentDishes(body)).toBe(true)
  })

  it('cheaper ones stays at or under the previous cheapest dish', async () => {
    const response = await search([
      user('Something spicy with chicken under 60 ₪'),
      { role: 'assistant', content: 'Found 2 spicy chicken dishes under ₪60.' },
      user('cheaper ones?'),
    ])
    expect(response.status).toBe(200)
    const body = response.body as SearchBody

    expect(body.results.map((result) => result.menuItem.name)).toEqual([
      'Chicken schnitzel pita',
    ])
    expect(body.results.map((result) => result.menuItem.priceAgorot)).toEqual([
      4500,
    ])
    expect(body.results[0]?.orderable).toBe(false)
    expect(body.results[0]?.menuItem.isAvailable).toBe(true)
    expect(body.results[0]?.restaurant.name).toBe('Falafel HaShuk')
    expect(body.intent).toMatchObject({
      keywords: ['chicken'],
      includeTags: ['spicy'],
      maxPriceAgorot: 4799,
      sort: 'price_asc',
    })
    expect(body.relaxed).toEqual(['includeTags'])
    expect(body.reply).toBe(
      'Nothing spicy chicken cheaper than ₪48, but here are close alternatives.',
    )
    expect(body.reply).not.toContain('47.99')
    expect(body.reply).not.toContain('Chicken schnitzel pita')
    expect(replyOmitsAbsentDishes(body)).toBe(true)
  })

  it('says nothing is cheaper when every match is already at the floor', async () => {
    const response = await search([
      user('tagliatelle'),
      { role: 'assistant', content: 'Found 1 tagliatelle dish.' },
      user('cheaper ones?'),
    ])
    expect(response.status).toBe(200)
    const body = response.body as SearchBody

    expect(body.results).toEqual([])
    expect(body.relaxed).toEqual([])
    expect(body.intent).toMatchObject({
      keywords: ['tagliatelle'],
      maxPriceAgorot: 11999,
      sort: 'price_asc',
    })
    expect(body.reply).toBe(
      'Nothing tagliatelle cheaper than ₪120. Those were the cheapest.',
    )
  })

  it('says so when nothing matches, without naming a real dish', async () => {
    const response = await search([user('durian with starfruit')])
    expect(response.status).toBe(200)
    const body = response.body as SearchBody

    expect(body.results).toEqual([])
    expect(body.reply).toBe(
      "I couldn't find anything matching 'durian with starfruit'. Try a cuisine or an ingredient.",
    )
    for (const name of KNOWN_DISHES) {
      expect(body.reply.toLowerCase().includes(name.toLowerCase())).toBe(false)
    }
  })

  it('uses the rule-based intent when the LLM responds badly', async () => {
    const originalFetch = globalThis.fetch
    let called = false
    globalThis.fetch = async () => {
      called = true
      return new Response('not-json', { status: 200 })
    }
    process.env.ANTHROPIC_API_KEY = 'sk-ant-test'
    resetEnvCache()
    try {
      const response = await search([user('I want a margherita pizza')])
      expect(response.status).toBe(200)
      const body = response.body as SearchBody
      expect(called).toBe(true)
      expect(body.results[0]?.menuItem.name).toMatch(/margherita/i)
      expect(body.results.map((result) => result.menuItem.name)).toContain(
        'Pepperoni pizza',
      )
      expect(body.intent.keywords).toEqual(['margherita', 'pizza'])
    } finally {
      globalThis.fetch = originalFetch
      delete process.env.ANTHROPIC_API_KEY
      resetEnvCache()
    }
  })
})

function replyOmitsAbsentDishes (body: SearchBody): boolean {
  const shown = new Set(
    body.results.map((result) => result.menuItem.name.toLowerCase()),
  )
  return KNOWN_DISHES.every(
    (name) =>
      shown.has(name.toLowerCase()) ||
      !body.reply.toLowerCase().includes(name.toLowerCase()),
  )
}
