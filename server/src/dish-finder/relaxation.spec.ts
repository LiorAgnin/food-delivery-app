import { relaxationSteps } from './relaxation'
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

describe('relaxationSteps', () => {
  it('keeps an unconstrained search as a single exact step', () => {
    const original = intent({ keywords: ['sushi'], openNowOnly: true })
    expect(relaxationSteps(original)).toEqual([
      { intent: original, relaxed: [] },
    ])
  })

  it('drops constraints in a fixed order and records each drop', () => {
    const original = intent({
      keywords: ['pizza', 'pineapple'],
      excludeKeywords: ['burger'],
      cuisines: ['Italian'],
      includeTags: ['vegan'],
      excludeTags: ['spicy'],
      maxPriceAgorot: 3000,
      openNowOnly: true,
      sort: 'price_asc',
    })

    expect(relaxationSteps(original)).toEqual([
      { intent: original, relaxed: [] },
      {
        intent: intent({
          keywords: ['pizza', 'pineapple'],
          excludeKeywords: ['burger'],
          cuisines: ['Italian'],
          includeTags: ['vegan'],
          excludeTags: ['spicy'],
          openNowOnly: true,
          sort: 'price_asc',
        }),
        relaxed: ['maxPriceAgorot'],
      },
      {
        intent: intent({
          keywords: ['pizza', 'pineapple'],
          cuisines: ['Italian'],
          includeTags: ['vegan'],
          excludeTags: ['spicy'],
          openNowOnly: true,
          sort: 'price_asc',
        }),
        relaxed: ['maxPriceAgorot', 'excludeKeywords'],
      },
      {
        intent: intent({
          keywords: ['pizza', 'pineapple'],
          cuisines: ['Italian'],
          excludeTags: ['spicy'],
          openNowOnly: true,
          sort: 'price_asc',
        }),
        relaxed: ['maxPriceAgorot', 'excludeKeywords', 'includeTags'],
      },
      {
        intent: intent({
          keywords: ['pizza', 'pineapple'],
          excludeTags: ['spicy'],
          openNowOnly: true,
          sort: 'price_asc',
        }),
        relaxed: [
          'maxPriceAgorot',
          'excludeKeywords',
          'includeTags',
          'cuisines',
        ],
      },
      {
        intent: intent({
          keywords: ['pineapple'],
          excludeTags: ['spicy'],
          openNowOnly: true,
          sort: 'price_asc',
        }),
        relaxed: [
          'maxPriceAgorot',
          'excludeKeywords',
          'includeTags',
          'cuisines',
          'keywords',
        ],
      },
    ])
  })

  it('skips constraints the intent does not use', () => {
    const original = intent({
      keywords: ['burger'],
      includeTags: ['vegan'],
      maxPriceAgorot: 1000,
    })

    expect(relaxationSteps(original).map((step) => step.relaxed)).toEqual([
      [],
      ['maxPriceAgorot'],
      ['maxPriceAgorot', 'includeTags'],
    ])
  })

  it('narrows keywords to the longest one, keeping the earlier word on a tie', () => {
    const original = intent({ keywords: ['tofu', 'soup', 'pineapple'] })
    const steps = relaxationSteps(original)
    expect(steps[steps.length - 1]).toEqual({
      intent: intent({ keywords: ['pineapple'] }),
      relaxed: ['keywords'],
    })

    const tied = intent({ keywords: ['tofu', 'soup'] })
    expect(relaxationSteps(tied)).toEqual([
      { intent: tied, relaxed: [] },
      { intent: intent({ keywords: ['tofu'] }), relaxed: ['keywords'] },
    ])
  })

  it('does not mutate the original intent', () => {
    const original = intent({
      keywords: ['pizza', 'pineapple'],
      maxPriceAgorot: 3000,
      includeTags: ['vegan'],
    })
    relaxationSteps(original)
    expect(original.maxPriceAgorot).toBe(3000)
    expect(original.keywords).toEqual(['pizza', 'pineapple'])
    expect(original.includeTags).toEqual(['vegan'])
  })
})
