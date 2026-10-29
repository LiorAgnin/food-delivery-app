import type { DietaryTag } from '../db/schema'
import type { SearchIntent } from './search-intent'

export type ReplyResult = {
  menuItem: { name: string; isAvailable: boolean; priceAgorot: number }
  orderable: boolean
}

const TAG_LABEL: Record<DietaryTag, string> = {
  vegetarian: 'vegetarian',
  vegan: 'vegan',
  spicy: 'spicy',
  gluten_free: 'gluten-free',
  dairy_free: 'dairy-free',
  contains_nuts: 'nut',
}

export function composeReply (input: {
  original: SearchIntent
  results: readonly ReplyResult[]
  relaxed: readonly string[]
  lastUserText: string
}): string {
  const { original, results, relaxed, lastUserText } = input
  if (results.length === 0) {
    const quoted = lastUserText.replaceAll("'", '')
    return `I couldn't find anything matching '${quoted}'. Try a cuisine or an ingredient.`
  }

  const stock = stockSentence(results)
  if (relaxed.length === 1 && relaxed[0] === 'maxPriceAgorot') {
    const filters = describeFilters(original)
    const ceiling =
      original.maxPriceAgorot == null
        ? ''
        : ` under ${formatShekels(original.maxPriceAgorot)}`
    const asked = filters.length > 0 ? `${filters}${ceiling}` : `that${ceiling}`
    const remaining = filters.length > 0 ? `${filters} dishes` : 'dishes'
    return `Nothing ${asked}, but here are ${remaining} slightly above that.${stock}`
  }

  if (relaxed.length > 0) {
    const filters = describeFilters(original)
    const asked = filters.length > 0 ? filters : 'that'
    return `Nothing ${asked}, but here are close alternatives.${stock}`
  }

  const filters = describeFilters(original)
  const noun = filters.length > 0 ? `${filters} ` : ''
  const dishWord = results.length === 1 ? 'dish' : 'dishes'
  const ceiling =
    original.maxPriceAgorot == null
      ? ''
      : ` under ${formatShekels(original.maxPriceAgorot)}`
  return `Found ${results.length} ${noun}${dishWord}${ceiling}.${stock}`
}

function describeFilters (intent: SearchIntent): string {
  return [...intent.includeTags.map((tag) => TAG_LABEL[tag]), ...intent.keywords]
    .join(' ')
}

function formatShekels (agorot: number): string {
  const shekels = agorot / 100
  const text = Number.isInteger(shekels) ? String(shekels) : shekels.toFixed(2)
  return `₪${text}`
}

function stockSentence (results: readonly ReplyResult[]): string {
  const unavailable = results.filter(
    (result) => !result.menuItem.isAvailable,
  ).length
  if (unavailable === 0) return ''
  if (unavailable === 1) return ' 1 is out of stock.'
  return ` ${unavailable} are out of stock.`
}
