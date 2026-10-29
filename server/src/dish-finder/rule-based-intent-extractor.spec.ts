import type { DietaryTag } from '../db/schema'
import { RuleBasedIntentExtractor } from './rule-based-intent-extractor'
import {
  type ChatMessage,
  type ExtractContext,
  type SearchIntent,
} from './search-intent'

const CATALOG_CUISINES = ['Grill', 'Israeli', 'Italian', 'Japanese', 'Vegan']

const EMPTY: SearchIntent = {
  keywords: [],
  excludeKeywords: [],
  cuisines: [],
  includeTags: [],
  excludeTags: [],
  maxPriceAgorot: null,
  openNowOnly: false,
  sort: 'relevance',
}

function intent (partial: Partial<SearchIntent>): SearchIntent {
  return { ...EMPTY, ...partial }
}

function user (content: string): ChatMessage {
  return { role: 'user', content }
}

function assistant (content: string): ChatMessage {
  return { role: 'assistant', content }
}

type Example = {
  name: string
  messages: ChatMessage[]
  context?: ExtractContext
  expected: SearchIntent
}

const examples: Example[] = [
  {
    name: 'margherita pizza',
    messages: [user('I want a margherita pizza')],
    expected: intent({ keywords: ['margherita', 'pizza'] }),
  },
  {
    name: 'spicy chicken under 60 shekels',
    messages: [user('Something spicy with chicken under 60 ₪')],
    expected: intent({
      keywords: ['chicken'],
      includeTags: ['spicy'],
      maxPriceAgorot: 6000,
    }),
  },
  {
    name: 'below ₪60',
    messages: [user('below ₪60')],
    expected: intent({ maxPriceAgorot: 6000 }),
  },
  {
    name: 'up to 60 shekels',
    messages: [user('up to 60 shekels')],
    expected: intent({ maxPriceAgorot: 6000 }),
  },
  {
    name: 'less-than 60',
    messages: [user('<60')],
    expected: intent({ maxPriceAgorot: 6000 }),
  },
  {
    name: 'vegan dinner, not burgers',
    messages: [user('Vegan dinner, not burgers')],
    expected: intent({
      includeTags: ['vegan'],
      excludeKeywords: ['burger'],
    }),
  },
  {
    name: 'no burger',
    messages: [user('no burger')],
    expected: intent({ excludeKeywords: ['burger'] }),
  },
  {
    name: 'without nuts',
    messages: [user('without nuts')],
    expected: intent({ excludeTags: ['contains_nuts'] }),
  },
  {
    name: 'gluten free and dairy-free',
    messages: [user('gluten free and dairy-free wrap')],
    expected: intent({
      keywords: ['wrap'],
      includeTags: ['gluten_free', 'dairy_free'],
    }),
  },
  {
    name: 'veggie and hot',
    messages: [user('veggie and hot soup')],
    expected: intent({
      keywords: ['soup'],
      includeTags: ['vegetarian', 'spicy'],
    }),
  },
  {
    name: 'not spicy',
    messages: [user('not spicy')],
    expected: intent({ excludeTags: ['spicy'] }),
  },
  {
    name: 'sushi from places that are open now',
    messages: [user('Show me sushi from places that are open now')],
    expected: intent({
      keywords: ['sushi'],
      openNowOnly: true,
    }),
  },
  {
    name: 'places that are open, without the word now',
    messages: [user('places that are open')],
    expected: intent({ openNowOnly: true }),
  },
  {
    name: 'italian pasta uses the cuisine list, not a hardcoded table',
    messages: [user('Italian pasta please')],
    expected: intent({
      keywords: ['pasta'],
      cuisines: ['Italian'],
    }),
  },
  {
    name: 'vegan is a dietary tag even though Vegan is also a cuisine',
    messages: [user('Vegan dinner, not burgers')],
    expected: intent({
      includeTags: ['vegan'],
      excludeKeywords: ['burger'],
    }),
  },
  {
    name: 'cheaper follow-up keeps the prior filters and caps just below the cheapest result',
    messages: [
      user('Something spicy with chicken under 60 ₪'),
      assistant('Found 2 spicy chicken dishes under ₪60.'),
      user('cheaper ones?'),
    ],
    context: { previousCheapestAgorot: 4800 },
    expected: intent({
      keywords: ['chicken'],
      includeTags: ['spicy'],
      maxPriceAgorot: 4799,
      sort: 'price_asc',
    }),
  },
  {
    name: 'cheaper with no previous results only changes the sort',
    messages: [
      user('Something spicy with chicken under 60 ₪'),
      user('cheaper ones?'),
    ],
    context: { previousCheapestAgorot: null },
    expected: intent({
      keywords: ['chicken'],
      includeTags: ['spicy'],
      maxPriceAgorot: 6000,
      sort: 'price_asc',
    }),
  },
  {
    name: 'less expensive is the same follow-up',
    messages: [user('chicken'), user('less expensive')],
    context: { previousCheapestAgorot: 2200 },
    expected: intent({
      keywords: ['chicken'],
      maxPriceAgorot: 2199,
      sort: 'price_asc',
    }),
  },
  {
    name: 'actually resets every earlier constraint',
    messages: [
      user('Something spicy with chicken under 60 ₪'),
      user('actually, I want sushi'),
    ],
    expected: intent({ keywords: ['sushi'] }),
  },
  {
    name: 'a later turn refines instead of resetting',
    messages: [user('I want sushi'), user('with salmon')],
    expected: intent({ keywords: ['sushi', 'salmon'] }),
  },
  {
    name: 'open now survives a cheaper follow-up',
    messages: [
      user('Show me sushi from places that are open now'),
      user('cheaper ones?'),
    ],
    context: { previousCheapestAgorot: 1800 },
    expected: intent({
      keywords: ['sushi'],
      openNowOnly: true,
      maxPriceAgorot: 1799,
      sort: 'price_asc',
    }),
  },
]

describe('RuleBasedIntentExtractor', () => {
  const extractor = new RuleBasedIntentExtractor(CATALOG_CUISINES)

  it.each(examples)('$name', ({ messages, context, expected }) => {
    expect(extractor.extract(messages, context)).toEqual(expected)
  })

  it('ignores assistant text when folding', () => {
    expect(
      extractor.extract([
        user('I want sushi'),
        assistant('Margherita is vegan and under 60'),
        user('with salmon'),
      ]),
    ).toEqual(intent({ keywords: ['sushi', 'salmon'] }))
  })

  it('singularizes a trailing s and leaves sushi alone', () => {
    expect(extractor.extract([user('burgers and sushi')])).toEqual(
      intent({ keywords: ['burger', 'sushi'] }),
    )
  })

  it('does not treat an unknown cuisine word as a cuisine', () => {
    const narrow = new RuleBasedIntentExtractor(['Italian'])
    expect(narrow.extract([user('Japanese ramen')])).toEqual(
      intent({ keywords: ['japanese', 'ramen'] }),
    )
  })

  it('keeps include and exclude tags disjoint', () => {
    const tags: DietaryTag[] = ['spicy']
    expect(extractor.extract([user('spicy but not spicy chicken')])).toEqual(
      intent({
        keywords: ['chicken'],
        excludeTags: tags,
      }),
    )
  })
})
