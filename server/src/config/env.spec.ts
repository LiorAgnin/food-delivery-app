import { getEnv, resetEnvCache } from './env'

const ORIGINAL = { ...process.env }

describe('getEnv', () => {
  afterEach(() => {
    process.env = { ...ORIGINAL }
    resetEnvCache()
  })

  it('defaults PORT and treats a missing OTP flag as off', () => {
    process.env.DATABASE_URL = 'postgres://food:food@localhost:5432/food'
    process.env.JWT_SECRET = 'test-secret'
    delete process.env.PORT
    delete process.env.OTP_DEV_MODE
    delete process.env.ANTHROPIC_API_KEY

    const env = getEnv()

    expect(env.PORT).toBe(3000)
    expect(env.OTP_DEV_MODE).toBe(false)
    expect(env.ANTHROPIC_API_KEY).toBeUndefined()
  })

  it('parses OTP dev mode and optional API keys', () => {
    process.env.DATABASE_URL = 'postgres://food:food@localhost:5432/food'
    process.env.JWT_SECRET = 'test-secret'
    process.env.PORT = '4000'
    process.env.OTP_DEV_MODE = 'true'
    process.env.ANTHROPIC_API_KEY = 'anthropic-key'
    process.env.OPENAI_API_KEY = ''

    const env = getEnv()

    expect(env.PORT).toBe(4000)
    expect(env.OTP_DEV_MODE).toBe(true)
    expect(env.ANTHROPIC_API_KEY).toBe('anthropic-key')
    expect(env.OPENAI_API_KEY).toBeUndefined()
  })

  it('fails fast when DATABASE_URL is missing', () => {
    delete process.env.DATABASE_URL
    process.env.JWT_SECRET = 'test-secret'

    expect(() => getEnv()).toThrow(/DATABASE_URL/)
  })
})
