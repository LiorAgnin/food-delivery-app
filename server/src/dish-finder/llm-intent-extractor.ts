import { z } from 'zod'
import { DIETARY_TAGS } from '../db/schema'
import { type RuleBasedIntentExtractor } from './rule-based-intent-extractor'
import {
  type ChatMessage,
  type ExtractContext,
  type SearchIntent,
} from './search-intent'

export type LlmProvider = 'anthropic' | 'openai'

const ANTHROPIC_URL = 'https://api.anthropic.com/v1/messages'
const OPENAI_URL = 'https://api.openai.com/v1/chat/completions'
const ANTHROPIC_MODEL = 'claude-sonnet-4-5'
const OPENAI_MODEL = 'gpt-4o-mini'

const dietaryTagSchema = z.enum(DIETARY_TAGS)

const searchIntentSchema = z.object({
  keywords: z.array(z.string()),
  excludeKeywords: z.array(z.string()),
  cuisines: z.array(z.string()),
  includeTags: z.array(dietaryTagSchema),
  excludeTags: z.array(dietaryTagSchema),
  maxPriceAgorot: z.number().int().nonnegative().nullable(),
  openNowOnly: z.boolean(),
  sort: z.enum(['relevance', 'price_asc']),
})

const SEARCH_INTENT_JSON_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  properties: {
    keywords: { type: 'array', items: { type: 'string' } },
    excludeKeywords: { type: 'array', items: { type: 'string' } },
    cuisines: { type: 'array', items: { type: 'string' } },
    includeTags: {
      type: 'array',
      items: { type: 'string', enum: [...DIETARY_TAGS] },
    },
    excludeTags: {
      type: 'array',
      items: { type: 'string', enum: [...DIETARY_TAGS] },
    },
    maxPriceAgorot: { type: ['integer', 'null'] },
    openNowOnly: { type: 'boolean' },
    sort: { type: 'string', enum: ['relevance', 'price_asc'] },
  },
  required: [
    'keywords',
    'excludeKeywords',
    'cuisines',
    'includeTags',
    'excludeTags',
    'maxPriceAgorot',
    'openNowOnly',
    'sort',
  ],
} as const

export type IntentLogger = {
  warn (message: string): void
}

export function chooseLlmProvider (keys: {
  anthropicApiKey?: string
  openaiApiKey?: string
}): LlmProvider | null {
  if (keys.anthropicApiKey) return 'anthropic'
  if (keys.openaiApiKey) return 'openai'
  return null
}

export class LlmIntentExtractor {
  private readonly timeoutMs: number
  private readonly logger: IntentLogger | undefined

  constructor (
    private readonly options: {
      fetch: typeof fetch
      provider: LlmProvider
      apiKey: string
      cuisines: readonly string[]
      rules: RuleBasedIntentExtractor
      timeoutMs?: number
      logger?: IntentLogger
    },
  ) {
    this.timeoutMs = options.timeoutMs ?? 5000
    this.logger = options.logger
  }

  async extract (
    messages: readonly ChatMessage[],
    context: ExtractContext = {},
  ): Promise<SearchIntent> {
    const controller = new AbortController()
    const timer = setTimeout(() => controller.abort(), this.timeoutMs)
    try {
      const payload = this.requestBody(messages)
      const response = await this.options.fetch(this.url(), {
        method: 'POST',
        headers: this.headers(),
        body: JSON.stringify(payload),
        signal: controller.signal,
      })
      if (!response.ok) {
        return this.fallback(messages, context, `HTTP ${response.status}`)
      }
      const text = await response.text()
      let parsedBody: unknown
      try {
        parsedBody = JSON.parse(text) as unknown
      } catch {
        return this.fallback(messages, context, 'invalid JSON')
      }
      const toolInput = readToolInput(this.options.provider, parsedBody)
      if (toolInput === undefined) {
        return this.fallback(messages, context, 'missing tool call')
      }
      const validated = searchIntentSchema.safeParse(toolInput)
      if (!validated.success) {
        return this.fallback(messages, context, 'schema mismatch')
      }
      return normalizeIntent(validated.data, this.options.cuisines)
    } catch (error: unknown) {
      const reason = error instanceof Error ? error.name : 'request failed'
      return this.fallback(messages, context, reason)
    } finally {
      clearTimeout(timer)
    }
  }

  private fallback (
    messages: readonly ChatMessage[],
    context: ExtractContext,
    reason: string,
  ): SearchIntent {
    this.logger?.warn(
      `LLM intent extraction failed (${reason}); using the rule-based intent`,
    )
    return this.options.rules.extract(messages, context)
  }

  private url (): string {
    return this.options.provider === 'anthropic' ? ANTHROPIC_URL : OPENAI_URL
  }

  private headers (): Record<string, string> {
    if (this.options.provider === 'anthropic') {
      return {
        'content-type': 'application/json',
        'x-api-key': this.options.apiKey,
        'anthropic-version': '2023-06-01',
      }
    }
    return {
      'content-type': 'application/json',
      authorization: `Bearer ${this.options.apiKey}`,
    }
  }

  private requestBody (messages: readonly ChatMessage[]): unknown {
    const system = systemPrompt(this.options.cuisines)
    const conversation = messages.map((message) => ({
      role: message.role,
      content: message.content,
    }))
    if (this.options.provider === 'anthropic') {
      return {
        model: ANTHROPIC_MODEL,
        max_tokens: 1024,
        system,
        tools: [
          {
            name: 'search_intent',
            description:
              'Search filters for the menu. Do not invent dishes or prices.',
            input_schema: SEARCH_INTENT_JSON_SCHEMA,
          },
        ],
        tool_choice: { type: 'tool', name: 'search_intent' },
        messages: conversation,
      }
    }
    return {
      model: OPENAI_MODEL,
      messages: [{ role: 'system', content: system }, ...conversation],
      tools: [
        {
          type: 'function',
          function: {
            name: 'search_intent',
            description:
              'Search filters for the menu. Do not invent dishes or prices.',
            parameters: SEARCH_INTENT_JSON_SCHEMA,
          },
        },
      ],
      tool_choice: {
        type: 'function',
        function: { name: 'search_intent' },
      },
    }
  }
}

function systemPrompt (cuisines: readonly string[]): string {
  return [
    'Convert the conversation into a search_intent tool call.',
    'You never invent dishes, restaurants, or prices.',
    'The only price you may set is maxPriceAgorot, and only from a budget the user stated: agorot = shekels * 100.',
    `Cuisines you may use: ${cuisines.join(', ') || '(none)'}.`,
    `Dietary tags you may use: ${DIETARY_TAGS.join(', ')}.`,
    'Put food words the user asked for in keywords.',
    'cheaper or less expensive sets sort to price_asc.',
    'open now sets openNowOnly to true.',
    'Do not include a menu, dish list, or any item price.',
  ].join('\n')
}

function readToolInput (provider: LlmProvider, body: unknown): unknown {
  if (typeof body !== 'object' || body === null) return undefined
  if (provider === 'anthropic') {
    if (!('content' in body) || !Array.isArray(body.content)) return undefined
    for (const block of body.content) {
      if (typeof block !== 'object' || block === null) continue
      if (
        'type' in block &&
        block.type === 'tool_use' &&
        'name' in block &&
        block.name === 'search_intent' &&
        'input' in block
      ) {
        return block.input
      }
    }
    return undefined
  }

  if (!('choices' in body) || !Array.isArray(body.choices)) return undefined
  const choice = body.choices[0]
  if (typeof choice !== 'object' || choice === null || !('message' in choice)) {
    return undefined
  }
  const message = choice.message
  if (
    typeof message !== 'object' ||
    message === null ||
    !('tool_calls' in message) ||
    !Array.isArray(message.tool_calls)
  ) {
    return undefined
  }
  const call = message.tool_calls[0]
  if (typeof call !== 'object' || call === null || !('function' in call)) {
    return undefined
  }
  const fn = call.function
  if (typeof fn !== 'object' || fn === null) return undefined
  if (!('name' in fn) || fn.name !== 'search_intent' || !('arguments' in fn)) {
    return undefined
  }
  if (typeof fn.arguments === 'string') return JSON.parse(fn.arguments) as unknown
  return fn.arguments
}

function normalizeIntent (
  parsed: z.infer<typeof searchIntentSchema>,
  cuisines: readonly string[],
): SearchIntent {
  const known = new Map(
    cuisines.map((cuisine) => [cuisine.toLowerCase(), cuisine]),
  )
  return {
    keywords: cleanWords(parsed.keywords),
    excludeKeywords: cleanWords(parsed.excludeKeywords),
    cuisines: unique(
      parsed.cuisines.flatMap((cuisine) => {
        const canonical = known.get(cuisine.trim().toLowerCase())
        return canonical ? [canonical] : []
      }),
    ),
    includeTags: unique(parsed.includeTags),
    excludeTags: unique(parsed.excludeTags),
    maxPriceAgorot: parsed.maxPriceAgorot,
    openNowOnly: parsed.openNowOnly,
    sort: parsed.sort,
  }
}

function cleanWords (words: readonly string[]): string[] {
  return unique(
    words.map((word) => word.trim().toLowerCase()).filter((word) => word.length > 0),
  )
}

function unique<T> (values: readonly T[]): T[] {
  const seen = new Set<T>()
  const result: T[] = []
  for (const value of values) {
    if (seen.has(value)) continue
    seen.add(value)
    result.push(value)
  }
  return result
}
