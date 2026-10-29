import type { DietaryTag } from '../db/schema'
import {
  EMPTY_INTENT,
  type ChatMessage,
  type ExtractContext,
  type SearchIntent,
} from './search-intent'

const STOPWORDS = new Set([
  'a',
  'actually',
  'am',
  'an',
  'and',
  'any',
  'are',
  'as',
  'at',
  'below',
  'breakfast',
  'brunch',
  'but',
  'can',
  'cheap',
  'cheaper',
  'could',
  'dinner',
  'dish',
  'dishes',
  'do',
  'does',
  'expensive',
  'find',
  'food',
  'for',
  'from',
  'get',
  'give',
  'have',
  'here',
  'i',
  'in',
  'instead',
  'is',
  'it',
  'item',
  'items',
  'just',
  'less',
  'like',
  'looking',
  'lunch',
  'me',
  'menu',
  'my',
  'nis',
  'now',
  'of',
  'on',
  'one',
  'ones',
  'only',
  'open',
  'or',
  'out',
  'place',
  'places',
  'please',
  'really',
  'restaurant',
  'restaurants',
  'shekel',
  'shekels',
  'show',
  'some',
  'something',
  'than',
  'that',
  'the',
  'then',
  'there',
  'these',
  'those',
  'to',
  'too',
  'under',
  'up',
  'us',
  'very',
  'want',
  'wanted',
  'we',
  'what',
  'which',
  'with',
  'would',
  'you',
])

const PRICE =
  /(?:\b(?:under|below|up\s*to)\b)\s*₪?\s*(\d+(?:\.\d{1,2})?)\s*(?:₪|shekels?|nis)?|<\s*₪?\s*(\d+(?:\.\d{1,2})?)/gi

const CHEAPER = /\bcheaper\b|\bless expensive\b/i

const OPEN_NOW = /\bopen now\b|\bplaces that are open\b/i

const RESET =
  /\b(?:actually|instead|nevermind)\b|\bnever mind\b|\bstart over\b|\bforget that\b/i

const TAG =
  /\b(?:(not|no|without)\s+)?(gluten[-\s]?free|dairy[-\s]?free|vegetarian|vegan|veggie|spicy|hot|nuts)\b/gi

const NEGATION = /^(?:not|no|without)$/

// A user turn that says "actually", "instead", "never mind", "start over",
// or "forget that" drops the intent folded so far. Other turns only refine
// it. "Vegan" is both a cuisine and a dietary tag; the tag wins so the
// request is not locked to the Vegan-cuisine restaurant.
export class RuleBasedIntentExtractor {
  constructor (private readonly cuisines: readonly string[]) {}

  extract (
    messages: readonly ChatMessage[],
    context: ExtractContext = {},
  ): SearchIntent {
    let intent = emptyIntent()
    for (const message of messages) {
      if (message.role !== 'user') continue
      if (RESET.test(message.content)) intent = emptyIntent()
      intent = applyMessage(intent, message.content, context, this.cuisines)
    }
    intent.includeTags = intent.includeTags.filter(
      (tag) => !intent.excludeTags.includes(tag),
    )
    return intent
  }
}

export function userMessageAsksForCheaper (content: string): boolean {
  return CHEAPER.test(content)
}

function applyMessage (
  intent: SearchIntent,
  message: string,
  context: ExtractContext,
  cuisines: readonly string[],
): SearchIntent {
  const next = cloneIntent(intent)
  const price = readPriceAgorot(message)
  if (price != null) next.maxPriceAgorot = price
  if (CHEAPER.test(message)) {
    next.sort = 'price_asc'
    if (context.previousCheapestAgorot != null) {
      next.maxPriceAgorot = Math.max(0, context.previousCheapestAgorot - 1)
    }
  }
  if (OPEN_NOW.test(message)) next.openNowOnly = true

  let remaining = message
  remaining = remaining.replace(new RegExp(PRICE.source, 'gi'), ' ')
  remaining = remaining.replace(new RegExp(CHEAPER.source, 'gi'), ' ')
  remaining = remaining.replace(new RegExp(OPEN_NOW.source, 'gi'), ' ')
  remaining = remaining.toLowerCase()
  remaining = applyTags(remaining, next)
  remaining = applyCuisines(remaining, next, cuisines)

  const tokens = remaining
    .replace(/[^a-z0-9\s]/g, ' ')
    .split(/\s+/)
    .filter((token) => token.length > 0)

  let negate = false
  for (const token of tokens) {
    if (NEGATION.test(token)) {
      negate = true
      continue
    }
    if (STOPWORDS.has(token) || /^\d+$/.test(token)) {
      negate = false
      continue
    }
    const word = singularize(token)
    if (negate) pushUnique(next.excludeKeywords, word)
    else pushUnique(next.keywords, word)
    negate = false
  }

  return next
}

function readPriceAgorot (message: string): number | null {
  let found: number | null = null
  for (const match of message.matchAll(new RegExp(PRICE.source, 'gi'))) {
    const raw = match[1] ?? match[2]
    if (!raw) continue
    found = Math.round(Number(raw) * 100)
  }
  return found
}

function applyTags (text: string, intent: SearchIntent): string {
  for (const match of text.matchAll(new RegExp(TAG.source, 'gi'))) {
    const label = match[2]
    if (!label) continue
    const tag = tagOf(label)
    if (match[1]) pushUnique(intent.excludeTags, tag)
    else pushUnique(intent.includeTags, tag)
  }
  return text.replace(new RegExp(TAG.source, 'gi'), ' ')
}

function tagOf (label: string): DietaryTag {
  const normalized = label.toLowerCase().replace(/[-\s]+/g, '')
  switch (normalized) {
    case 'glutenfree':
      return 'gluten_free'
    case 'dairyfree':
      return 'dairy_free'
    case 'vegetarian':
    case 'veggie':
      return 'vegetarian'
    case 'vegan':
      return 'vegan'
    case 'spicy':
    case 'hot':
      return 'spicy'
    case 'nuts':
      return 'contains_nuts'
    default:
      throw new Error(`Unhandled dietary phrase: ${label}`)
  }
}

function applyCuisines (
  text: string,
  intent: SearchIntent,
  cuisines: readonly string[],
): string {
  let remaining = text
  const ordered = [...cuisines].sort((left, right) => right.length - left.length)
  for (const cuisine of ordered) {
    const body = cuisine.toLowerCase().replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
    const pattern = new RegExp(`(?<![a-z0-9])${body}(?![a-z0-9])`, 'gi')
    if (!pattern.test(remaining)) continue
    pushUnique(intent.cuisines, cuisine)
    pattern.lastIndex = 0
    remaining = remaining.replace(pattern, ' ')
  }
  return remaining
}

function singularize (word: string): string {
  if (word.length <= 3 || word.endsWith('ss')) return word
  if (word.endsWith('ies') && word.length > 4) return `${word.slice(0, -3)}y`
  if (word.endsWith('s') && !word.endsWith('us') && !word.endsWith('is')) {
    return word.slice(0, -1)
  }
  return word
}

function pushUnique<T> (values: T[], value: T): void {
  if (!values.includes(value)) values.push(value)
}

function emptyIntent (): SearchIntent {
  return {
    ...EMPTY_INTENT,
    keywords: [],
    excludeKeywords: [],
    cuisines: [],
    includeTags: [],
    excludeTags: [],
  }
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
