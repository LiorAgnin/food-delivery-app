import { Inject, Injectable, Logger, type OnModuleInit } from '@nestjs/common'
import { DRIZZLE, type Database } from '../db/database.module'
import { restaurants } from '../db/schema'
import { getEnv } from '../config/env'
import {
  chooseLlmProvider,
  LlmIntentExtractor,
  type LlmProvider,
} from './llm-intent-extractor'
import { composeReply } from './reply-composer'
import { relaxationSteps } from './relaxation'
import {
  RuleBasedIntentExtractor,
  userMessageAsksForCheaper,
} from './rule-based-intent-extractor'
import type { DishResult } from './dish-search.repository'
import { DishSearchRepository } from './dish-search.repository'
import {
  type ChatMessage,
  type ExtractContext,
  type IntentExtractor,
  type SearchIntent,
} from './search-intent'

export const DISH_FINDER_FETCH = Symbol('DISH_FINDER_FETCH')

export type DishFinderResponse = {
  reply: string
  results: DishResult[]
  intent: SearchIntent
  relaxed: string[]
}

@Injectable()
export class DishFinderService implements OnModuleInit {
  private cuisines: string[] | undefined
  private readonly logger = new Logger(LlmIntentExtractor.name)

  constructor (
    @Inject(DRIZZLE) private readonly db: Database,
    @Inject(DISH_FINDER_FETCH) private readonly fetchImpl: typeof fetch,
    private readonly searchRepo: DishSearchRepository,
  ) {}

  async onModuleInit (): Promise<void> {
    this.cuisines = await this.loadCuisines()
  }

  async search (
    messages: readonly ChatMessage[],
    now = new Date(),
  ): Promise<DishFinderResponse> {
    const cuisines = this.cuisines ?? (await this.loadCuisines())
    const rules = new RuleBasedIntentExtractor(cuisines)
    const extractor = this.extractorFor(rules, cuisines)
    const context = await this.cheaperContext(messages, rules, now)
    const extracted = await extractor.extract(messages, context)
    const original = withCheaperCeiling(extracted, messages, context)
    const outcome = await this.firstHit(original, now)
    return {
      reply: composeReply({
        original,
        results: outcome.results,
        relaxed: outcome.relaxed,
        lastUserText: lastUserText(messages),
      }),
      results: outcome.results,
      intent: original,
      relaxed: outcome.relaxed,
    }
  }

  private extractorFor (
    rules: RuleBasedIntentExtractor,
    cuisines: readonly string[],
  ): IntentExtractor {
    const env = getEnv()
    const provider = chooseLlmProvider({
      anthropicApiKey: env.ANTHROPIC_API_KEY,
      openaiApiKey: env.OPENAI_API_KEY,
    })
    if (!provider) return rules
    const apiKey = keyFor(provider, env.ANTHROPIC_API_KEY, env.OPENAI_API_KEY)
    if (!apiKey) return rules
    return new LlmIntentExtractor({
      fetch: this.fetchImpl,
      provider,
      apiKey,
      cuisines,
      rules,
      timeoutMs: 5000,
      logger: this.logger,
    })
  }

  private async cheaperContext (
    messages: readonly ChatMessage[],
    rules: RuleBasedIntentExtractor,
    now: Date,
  ): Promise<ExtractContext> {
    const last = lastUserMessage(messages)
    if (!last || !userMessageAsksForCheaper(last.content)) return {}
    const priorIntent = rules.extract(dropLastUser(messages))
    const previous = await this.searchRepo.search(priorIntent, now)
    if (previous.length === 0) return { previousCheapestAgorot: null }
    const cheapest = Math.min(
      ...previous.map((result) => result.menuItem.priceAgorot),
    )
    return { previousCheapestAgorot: cheapest }
  }

  private async firstHit (
    original: SearchIntent,
    now: Date,
  ): Promise<{ results: DishResult[]; relaxed: string[] }> {
    let last: { results: DishResult[]; relaxed: string[] } = {
      results: [],
      relaxed: [],
    }
    for (const step of relaxationSteps(original)) {
      const results = await this.searchRepo.search(step.intent, now)
      last = { results, relaxed: step.relaxed }
      if (results.length > 0) return last
    }
    return last
  }

  private async loadCuisines (): Promise<string[]> {
    const rows = await this.db
      .select({ cuisine: restaurants.cuisine })
      .from(restaurants)
      .groupBy(restaurants.cuisine)
    const cuisines = rows.map((row) => row.cuisine)
    cuisines.sort((left, right) => left.localeCompare(right, 'en'))
    this.cuisines = cuisines
    return cuisines
  }
}

function keyFor (
  provider: LlmProvider,
  anthropicApiKey: string | undefined,
  openaiApiKey: string | undefined,
): string | undefined {
  return provider === 'anthropic' ? anthropicApiKey : openaiApiKey
}

function withCheaperCeiling (
  intent: SearchIntent,
  messages: readonly ChatMessage[],
  context: ExtractContext,
): SearchIntent {
  const last = lastUserMessage(messages)
  if (!last || !userMessageAsksForCheaper(last.content)) return intent
  if (context.previousCheapestAgorot == null) {
    return { ...intent, sort: 'price_asc' }
  }
  return {
    ...intent,
    sort: 'price_asc',
    maxPriceAgorot: Math.max(0, context.previousCheapestAgorot - 1),
  }
}

function lastUserMessage (
  messages: readonly ChatMessage[],
): ChatMessage | undefined {
  for (let index = messages.length - 1; index >= 0; index -= 1) {
    const message = messages[index]
    if (message?.role === 'user') return message
  }
  return undefined
}

function lastUserText (messages: readonly ChatMessage[]): string {
  return lastUserMessage(messages)?.content ?? ''
}

function dropLastUser (messages: readonly ChatMessage[]): ChatMessage[] {
  const copy = [...messages]
  for (let index = copy.length - 1; index >= 0; index -= 1) {
    if (copy[index]?.role === 'user') {
      copy.splice(index, 1)
      return copy
    }
  }
  return copy
}
