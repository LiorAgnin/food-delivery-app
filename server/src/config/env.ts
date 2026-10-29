import { config as loadDotenv } from 'dotenv'
import { z } from 'zod'

const emptyToUndefined = (value: unknown): unknown => {
  if (value === undefined || value === null || value === '') return undefined
  return value
}

const envSchema = z.object({
  DATABASE_URL: z.string().min(1),
  PORT: z.preprocess(
    (value) => (value === undefined || value === '' ? undefined : value),
    z.coerce.number().int().positive().default(3000),
  ),
  JWT_SECRET: z.string().min(1),
  OTP_DEV_MODE: z
    .enum(['true', 'false'])
    .default('false')
    .transform((value) => value === 'true'),
  ANTHROPIC_API_KEY: z.preprocess(
    emptyToUndefined,
    z.string().min(1).optional(),
  ),
  OPENAI_API_KEY: z.preprocess(emptyToUndefined, z.string().min(1).optional()),
})

export type Env = z.infer<typeof envSchema>

let dotenvLoaded = false
let cached: Env | undefined

export function resetEnvCache (): void {
  cached = undefined
}

export function getEnv (): Env {
  if (!dotenvLoaded) {
    loadDotenv({ quiet: true })
    dotenvLoaded = true
  }
  if (!cached) {
    const parsed = envSchema.safeParse(process.env)
    if (!parsed.success) {
      const message = parsed.error.issues
        .map((issue) => `${issue.path.join('.') || '(root)'}: ${issue.message}`)
        .join('; ')
      throw new Error(`Invalid environment: ${message}`)
    }
    cached = parsed.data
  }
  return cached
}
