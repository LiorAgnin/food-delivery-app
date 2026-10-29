import type { SearchIntent } from './search-intent'

export type RelaxationStep = {
  intent: SearchIntent
  relaxed: string[]
}

type Drop = {
  key: string
  active: (intent: SearchIntent) => boolean
  apply: (intent: SearchIntent) => SearchIntent
}

const DROPS: readonly Drop[] = [
  {
    key: 'maxPriceAgorot',
    active: (intent) => intent.maxPriceAgorot != null,
    apply: (intent) => ({ ...intent, maxPriceAgorot: null }),
  },
  {
    key: 'excludeKeywords',
    active: (intent) => intent.excludeKeywords.length > 0,
    apply: (intent) => ({ ...intent, excludeKeywords: [] }),
  },
  {
    key: 'includeTags',
    active: (intent) => intent.includeTags.length > 0,
    apply: (intent) => ({ ...intent, includeTags: [] }),
  },
  {
    key: 'cuisines',
    active: (intent) => intent.cuisines.length > 0,
    apply: (intent) => ({ ...intent, cuisines: [] }),
  },
  {
    key: 'keywords',
    active: (intent) => intent.keywords.length > 1,
    apply: (intent) => ({
      ...intent,
      keywords: [bestKeyword(intent.keywords)],
    }),
  },
]

export function relaxationSteps (intent: SearchIntent): RelaxationStep[] {
  const steps: RelaxationStep[] = [{ intent: cloneIntent(intent), relaxed: [] }]
  let current = cloneIntent(intent)
  let relaxed: string[] = []

  for (const drop of DROPS) {
    if (!drop.active(current)) continue
    current = drop.apply(cloneIntent(current))
    relaxed = [...relaxed, drop.key]
    steps.push({ intent: current, relaxed })
  }

  return steps
}

function bestKeyword (keywords: readonly string[]): string {
  let best = keywords[0] ?? ''
  for (const word of keywords) {
    if (word.length > best.length) best = word
  }
  return best
}

function cloneIntent (intent: SearchIntent): SearchIntent {
  return {
    ...intent,
    keywords: [...intent.keywords],
    excludeKeywords: [...intent.excludeKeywords],
    cuisines: [...intent.cuisines],
    includeTags: [...intent.includeTags],
    excludeTags: [...intent.excludeTags],
  }
}
