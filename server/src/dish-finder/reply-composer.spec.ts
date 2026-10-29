import { composeReply, type ReplyResult } from './reply-composer'
import type { SearchIntent } from './search-intent'

function intent (partial: Partial<SearchIntent> = {}): SearchIntent {
  return {
    keywords: [],
    excludeKeywords: [],
    cuisines: [],
    includeTags: [],
    excludeTags: [],
    maxPriceAgorot: null,
    openNowOnly: false,
    sort: 'relevance',
    ...partial,
  }
}

function dish (
  name: string,
  options: { available?: boolean; priceAgorot?: number } = {},
): ReplyResult {
  return {
    menuItem: {
      name,
      isAvailable: options.available ?? true,
      priceAgorot: options.priceAgorot ?? 4800,
    },
    orderable: options.available ?? true,
  }
}

const CATALOG = [
  'Margherita',
  'Pepperoni pizza',
  'Vegan burger',
  'Salmon nigiri',
  'Spicy chicken skewer',
  'Spicy chicken schnitzel',
  'Half spicy chicken',
  'White truffle tagliatelle',
]

describe('composeReply', () => {
  it('counts matches, names the filters, and marks unavailable dishes', () => {
    const reply = composeReply({
      original: intent({
        keywords: ['chicken'],
        includeTags: ['spicy'],
        maxPriceAgorot: 6000,
      }),
      results: [
        dish('Spicy chicken skewer', { priceAgorot: 4800 }),
        dish('Spicy chicken schnitzel', { priceAgorot: 5600 }),
        dish('Half spicy chicken', { available: false, priceAgorot: 9200 }),
      ],
      relaxed: [],
      lastUserText: 'Something spicy with chicken under 60 ₪',
    })

    expect(reply).toBe(
      'Found 3 spicy chicken dishes under ₪60. 1 is out of stock.',
    )
  })

  it('uses the singular when one dish is out of stock is not the only case of one result', () => {
    const reply = composeReply({
      original: intent({ keywords: ['sushi'], openNowOnly: true }),
      results: [dish('Salmon nigiri', { priceAgorot: 5200 })],
      relaxed: [],
      lastUserText: 'Show me sushi from places that are open now',
    })

    expect(reply).toBe('Found 1 sushi dish.')
  })

  it('says how many are out of stock', () => {
    const reply = composeReply({
      original: intent({ keywords: ['pizza'] }),
      results: [
        dish('Margherita', { available: false }),
        dish('Pepperoni pizza', { available: false }),
      ],
      relaxed: [],
      lastUserText: 'pizza',
    })

    expect(reply).toBe('Found 2 pizza dishes. 2 are out of stock.')
  })

  it('does not state the result cap as the total when more dishes matched', () => {
    const candidates = [
      'Quinoa tabbouleh',
      'Sweet potato fries',
      'Lentil soup',
      'Lentil and mushroom stew',
      'Tofu sabich plate',
      'Roasted cauliflower steak',
      'Fresh orange juice',
      'Oat cappuccino',
      'Soda water',
      'Edamame',
      'Wakame salad',
    ].map((name) => dish(name))

    const reply = composeReply({
      original: intent({ includeTags: ['vegan'] }),
      results: candidates,
      relaxed: [],
      lastUserText: 'Vegan dinner, not burgers',
    })

    expect(candidates).toHaveLength(11)
    expect(reply).toBe('Here are 10 vegan dishes.')
    expect(reply).not.toContain('11')
    expect(reply).not.toContain('Found')
    for (const candidate of candidates) {
      expect(
        reply.toLowerCase().includes(candidate.menuItem.name.toLowerCase()),
      ).toBe(false)
    }
  })

  it('explains a price relaxation without quoting a dish price', () => {
    const reply = composeReply({
      original: intent({
        includeTags: ['vegan'],
        maxPriceAgorot: 3000,
      }),
      results: [dish('Lentil soup', { priceAgorot: 2600 })],
      relaxed: ['maxPriceAgorot'],
      lastUserText: 'vegan under 30',
    })

    expect(reply).toBe(
      'Nothing vegan under ₪30, but here are vegan dishes slightly above that.',
    )
    expect(reply).not.toContain('26')
    expect(reply).not.toContain('2600')
  })

  it('admits an empty search without inventing a dish', () => {
    const reply = composeReply({
      original: intent({ keywords: ['pizza', 'pineapple'] }),
      results: [],
      relaxed: ['keywords'],
      lastUserText: 'pizza with pineapple',
    })

    expect(reply).toBe(
      "I couldn't find anything matching 'pizza with pineapple'. Try a cuisine or an ingredient.",
    )
  })

  it('phrases a cheaper ceiling as cheaper than the previous price', () => {
    const reply = composeReply({
      original: intent({
        keywords: ['chicken'],
        includeTags: ['spicy'],
        maxPriceAgorot: 4799,
        sort: 'price_asc',
      }),
      results: [dish('Chicken schnitzel pita', { priceAgorot: 4500 })],
      relaxed: ['includeTags'],
      lastUserText: 'cheaper ones?',
      cheaperThanPrevious: true,
    })

    expect(reply).toBe(
      'No spicy chicken dishes cheaper than ₪48, but here are close alternatives.',
    )
    expect(reply).not.toContain('47.99')
    expect(reply).not.toContain('45')
  })

  it('says there is nothing cheaper when a cheaper turn matches nothing', () => {
    const reply = composeReply({
      original: intent({
        keywords: ['chicken'],
        includeTags: ['spicy'],
        maxPriceAgorot: 4799,
        sort: 'price_asc',
      }),
      results: [],
      relaxed: [],
      lastUserText: 'cheaper ones?',
      cheaperThanPrevious: true,
    })

    expect(reply).toBe(
      'No spicy chicken dishes cheaper than ₪48. Those were the cheapest.',
    )
    expect(reply).not.toContain('47.99')
  })

  it('counts an exact cheaper match without saying under', () => {
    const reply = composeReply({
      original: intent({
        keywords: ['soup'],
        maxPriceAgorot: 2599,
        sort: 'price_asc',
      }),
      results: [dish('Lentil soup', { priceAgorot: 2200 })],
      relaxed: [],
      lastUserText: 'cheaper ones?',
      cheaperThanPrevious: true,
    })

    expect(reply).toBe('Found 1 soup dish cheaper than ₪26.')
    expect(reply).not.toContain('25.99')
    expect(reply).not.toContain('22')
  })

  it('offers close alternatives when a non-price constraint was dropped', () => {
    const reply = composeReply({
      original: intent({
        keywords: ['burger'],
        includeTags: ['vegan'],
        excludeKeywords: ['soup'],
      }),
      results: [dish('Vegan burger')],
      relaxed: ['excludeKeywords'],
      lastUserText: 'vegan burger, not soup',
    })

    expect(reply).toBe('Nothing vegan burger, but here are close alternatives.')
  })

  it('never mentions a catalog dish that is not in the results', () => {
    const cases: Array<{ reply: string; results: ReplyResult[] }> = [
      {
        results: [
          dish('Spicy chicken skewer'),
          dish('Spicy chicken schnitzel'),
        ],
        reply: composeReply({
          original: intent({
            keywords: ['chicken'],
            includeTags: ['spicy'],
            maxPriceAgorot: 6000,
          }),
          results: [
            dish('Spicy chicken skewer'),
            dish('Spicy chicken schnitzel'),
          ],
          relaxed: [],
          lastUserText: 'Something spicy with chicken under 60 ₪',
        }),
      },
      {
        results: [dish('Lentil soup')],
        reply: composeReply({
          original: intent({ includeTags: ['vegan'], maxPriceAgorot: 3000 }),
          results: [dish('Lentil soup')],
          relaxed: ['maxPriceAgorot'],
          lastUserText: 'vegan under 30',
        }),
      },
      {
        results: [],
        reply: composeReply({
          original: intent({ keywords: ['pizza', 'pineapple'] }),
          results: [],
          relaxed: [],
          lastUserText: 'pizza with pineapple',
        }),
      },
      {
        results: [dish('Vegan burger')],
        reply: composeReply({
          original: intent({
            keywords: ['burger'],
            includeTags: ['vegan'],
          }),
          results: [dish('Vegan burger')],
          relaxed: ['excludeKeywords'],
          lastUserText: 'vegan burger, not soup',
        }),
      },
    ]

    for (const sample of cases) {
      const shown = new Set(
        sample.results.map((result) => result.menuItem.name.toLowerCase()),
      )
      for (const name of CATALOG) {
        if (shown.has(name.toLowerCase())) continue
        expect(sample.reply.toLowerCase().includes(name.toLowerCase())).toBe(
          false,
        )
      }
    }
  })
})
