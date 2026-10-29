import type { DietaryTag } from '../db/schema'

export type SearchIntent = {
  keywords: string[]
  excludeKeywords: string[]
  cuisines: string[]
  includeTags: DietaryTag[]
  excludeTags: DietaryTag[]
  maxPriceAgorot: number | null
  openNowOnly: boolean
  sort: 'relevance' | 'price_asc'
}

export type ChatMessage = {
  role: 'user' | 'assistant'
  content: string
}

export type ExtractContext = {
  previousCheapestAgorot?: number | null
}

export const EMPTY_INTENT: SearchIntent = {
  keywords: [],
  excludeKeywords: [],
  cuisines: [],
  includeTags: [],
  excludeTags: [],
  maxPriceAgorot: null,
  openNowOnly: false,
  sort: 'relevance',
}

export interface IntentExtractor {
  extract (
    messages: readonly ChatMessage[],
    context?: ExtractContext,
  ): SearchIntent | Promise<SearchIntent>
}
