import { LlmIntentExtractor, chooseLlmProvider } from './llm-intent-extractor'
import { RuleBasedIntentExtractor } from './rule-based-intent-extractor'
import type { SearchIntent } from './search-intent'

const CUISINES = ['Italian', 'Japanese', 'Vegan']

const MARGHERITA: SearchIntent = {
  keywords: ['margherita', 'pizza'],
  excludeKeywords: [],
  cuisines: [],
  includeTags: [],
  excludeTags: [],
  maxPriceAgorot: null,
  openNowOnly: false,
  sort: 'relevance',
}

const RAMEN: SearchIntent = {
  keywords: ['ramen'],
  excludeKeywords: [],
  cuisines: ['Japanese'],
  includeTags: [],
  excludeTags: [],
  maxPriceAgorot: null,
  openNowOnly: false,
  sort: 'relevance',
}

const CHEAPER: SearchIntent = {
  keywords: ['chicken'],
  excludeKeywords: [],
  cuisines: [],
  includeTags: ['spicy'],
  excludeTags: [],
  maxPriceAgorot: 4799,
  openNowOnly: false,
  sort: 'price_asc',
}

function jsonResponse (body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'content-type': 'application/json' },
  })
}

function anthropicMessage (intent: SearchIntent): unknown {
  return {
    content: [
      {
        type: 'tool_use',
        name: 'search_intent',
        input: intent,
      },
    ],
  }
}

describe('chooseLlmProvider', () => {
  it('prefers Anthropic when both keys are set', () => {
    expect(
      chooseLlmProvider({
        anthropicApiKey: 'sk-ant',
        openaiApiKey: 'sk-openai',
      }),
    ).toBe('anthropic')
  })

  it('uses OpenAI when it is the only key', () => {
    expect(chooseLlmProvider({ openaiApiKey: 'sk-openai' })).toBe('openai')
  })

  it('stays on the rules when no key is set', () => {
    expect(chooseLlmProvider({})).toBeNull()
    expect(chooseLlmProvider({ anthropicApiKey: '' })).toBeNull()
  })
})

describe('LlmIntentExtractor', () => {
  const rules = new RuleBasedIntentExtractor(CUISINES)
  const messages = [
    { role: 'user' as const, content: 'I want a margherita pizza' },
  ]

  it('uses an Anthropic tool call as the intent and does not send the menu', async () => {
    const calls: Array<{ url: string; init: RequestInit | undefined }> = []
    const fetchImpl: typeof fetch = async (input, init) => {
      calls.push({ url: String(input), init })
      return jsonResponse(anthropicMessage({ ...RAMEN, keywords: ['Ramen'] }))
    }
    const extractor = new LlmIntentExtractor({
      fetch: fetchImpl,
      provider: 'anthropic',
      apiKey: 'sk-ant-secret',
      cuisines: CUISINES,
      rules,
      timeoutMs: 5000,
    })

    await expect(extractor.extract(messages)).resolves.toEqual(RAMEN)

    const call = calls[0]
    expect(call?.url).toBe('https://api.anthropic.com/v1/messages')
    expect(call?.init?.method).toBe('POST')
    expect(call?.init?.signal).toBeInstanceOf(AbortSignal)
    const headers = call?.init?.headers as Record<string, string>
    expect(headers['x-api-key']).toBe('sk-ant-secret')
    const body = String(call?.init?.body)
    expect(body).toContain('I want a margherita pizza')
    expect(body).toContain('Italian')
    expect(body).toContain('gluten_free')
    expect(body).not.toContain('Salmon nigiri')
    expect(body).not.toContain('5400')
  })

  it('reads an OpenAI function call', async () => {
    const fetchImpl: typeof fetch = async () =>
      jsonResponse({
        choices: [
          {
            message: {
              tool_calls: [
                {
                  function: {
                    name: 'search_intent',
                    arguments: JSON.stringify(RAMEN),
                  },
                },
              ],
            },
          },
        ],
      })
    const extractor = new LlmIntentExtractor({
      fetch: fetchImpl,
      provider: 'openai',
      apiKey: 'sk-openai-secret',
      cuisines: CUISINES,
      rules,
    })

    await expect(extractor.extract(messages)).resolves.toEqual(RAMEN)
  })

  it.each([
    ['an HTTP error', async () => jsonResponse({ error: 'nope' }, 500)],
    ['malformed JSON', async () => new Response('not-json', { status: 200 })],
    [
      'a schema mismatch',
      async () =>
        jsonResponse(
          anthropicMessage({
            ...RAMEN,
            maxPriceAgorot: 'cheap' as unknown as number,
          }),
        ),
    ],
    [
      'a timeout',
      async () => {
        throw Object.assign(new Error('timed out'), { name: 'TimeoutError' })
      },
    ],
  ])('falls back to the rules after %s', async (_label, fetchImpl) => {
    const warnings: string[] = []
    const extractor = new LlmIntentExtractor({
      fetch: fetchImpl,
      provider: 'anthropic',
      apiKey: 'sk-ant-secret',
      cuisines: CUISINES,
      rules,
      logger: {
        warn (message: string) {
          warnings.push(message)
        },
      },
    })

    await expect(extractor.extract(messages)).resolves.toEqual(MARGHERITA)
    expect(warnings[0]).toMatch(/rule-based/i)
    expect(warnings.join('\n')).not.toContain('sk-ant-secret')
  })

  it('applies the cheaper ceiling from the rules when the model fails', async () => {
    const extractor = new LlmIntentExtractor({
      fetch: async () => jsonResponse({ error: 'nope' }, 503),
      provider: 'anthropic',
      apiKey: 'sk-ant-secret',
      cuisines: CUISINES,
      rules,
      logger: { warn () {} },
    })

    await expect(
      extractor.extract(
        [
          { role: 'user', content: 'Something spicy with chicken under 60 ₪' },
          { role: 'user', content: 'cheaper ones?' },
        ],
        { previousCheapestAgorot: 4800 },
      ),
    ).resolves.toEqual(CHEAPER)
  })

  it('drops a cuisine the model invented', async () => {
    const extractor = new LlmIntentExtractor({
      fetch: async () =>
        jsonResponse(
          anthropicMessage({
            ...RAMEN,
            cuisines: ['Martian', 'Italian'],
          }),
        ),
      provider: 'anthropic',
      apiKey: 'sk-ant-secret',
      cuisines: CUISINES,
      rules,
    })

    await expect(extractor.extract(messages)).resolves.toEqual({
      ...RAMEN,
      cuisines: ['Italian'],
    })
  })
})
