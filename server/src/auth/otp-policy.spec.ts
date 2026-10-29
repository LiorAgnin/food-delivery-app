import { DomainError } from '../common/domain-error'
import {
  OtpCodeGenerator,
  OtpPolicy,
  type OtpChallengeSnapshot,
} from './otp-policy'

describe('OTP code generator', () => {
  it('returns the fixed dev code and does not draw a random one', () => {
    const randomInt = (): number => {
      throw new Error('dev mode must not draw a random code')
    }
    const codes = new OtpCodeGenerator(true, randomInt)

    expect(codes.nextCode()).toBe('123456')
  })

  it('pads a non-dev draw to six digits', () => {
    const codes = new OtpCodeGenerator(false, () => 42)

    expect(codes.nextCode()).toBe('000042')
  })
})

const SECRET = 'test-secret'
const CODE_HASH =
  '66390255070e83b7c8a6ef04304e527e289538931b78520d0be9a2a439e918a3'

function policyAt (
  iso: string,
  codes: { nextCode: () => string } = { nextCode: () => '123456' },
): OtpPolicy {
  const now = new Date(iso)
  return new OtpPolicy({ now: () => now }, codes, SECRET)
}

function challenge (
  overrides: Partial<OtpChallengeSnapshot> = {},
): OtpChallengeSnapshot {
  return {
    codeHash: CODE_HASH,
    expiresAt: new Date('2026-01-15T12:05:00.000Z'),
    attempts: 0,
    consumedAt: null,
    ...overrides,
  }
}

describe('OTP policy', () => {
  it('issues a code that expires five minutes later and stores its hmac', () => {
    const policy = policyAt('2026-01-15T12:00:00.000Z')

    const issued = policy.issue(0)

    expect(issued).toEqual({
      code: '123456',
      codeHash: CODE_HASH,
      expiresAt: new Date('2026-01-15T12:05:00.000Z'),
    })
    expect(policy.windowStart().toISOString()).toBe('2026-01-15T11:50:00.000Z')
  })

  it('refuses a fourth request inside the ten-minute window', () => {
    const policy = policyAt('2026-01-15T12:00:00.000Z')

    expect(() => policy.issue(2)).not.toThrow()
    expect(() => policy.issue(3)).toThrow(DomainError)
    try {
      policy.issue(3)
    } catch (error) {
      expect(error).toMatchObject({
        code: 'OTP_TOO_MANY_ATTEMPTS',
        status: 429,
      })
    }
  })

  it('accepts the matching code before expiry', () => {
    const policy = policyAt('2026-01-15T12:04:59.000Z')

    expect(policy.decide(challenge(), '123456')).toEqual({ kind: 'accept' })
  })

  it('rejects a wrong code and counts the attempt', () => {
    const policy = policyAt('2026-01-15T12:01:00.000Z')

    expect(policy.decide(challenge({ attempts: 2 }), '000000')).toEqual({
      kind: 'mismatch',
      attempts: 3,
    })
  })

  it('stops at five attempts even when the later code is right', () => {
    const policy = policyAt('2026-01-15T12:01:00.000Z')

    expect(policy.decide(challenge({ attempts: 5 }), '123456')).toEqual({
      kind: 'too_many_attempts',
    })
  })

  it('rejects a code at the expiry instant', () => {
    const policy = policyAt('2026-01-15T12:05:00.000Z')

    expect(policy.decide(challenge(), '123456')).toEqual({ kind: 'expired' })
  })

  it('rejects a consumed code without counting another attempt', () => {
    const policy = policyAt('2026-01-15T12:01:00.000Z')

    expect(
      policy.decide(
        challenge({ consumedAt: new Date('2026-01-15T12:00:30.000Z') }),
        '123456',
      ),
    ).toEqual({ kind: 'invalid' })
  })

  it('rejects a verify when no challenge exists', () => {
    const policy = policyAt('2026-01-15T12:01:00.000Z')

    expect(policy.decide(null, '123456')).toEqual({ kind: 'invalid' })
  })

  it('hides the code unless dev mode is on', () => {
    expect(OtpPolicy.requestBody(false, '123456')).toEqual({
      expiresInSeconds: 300,
    })
    expect(OtpPolicy.requestBody(true, '123456')).toEqual({
      expiresInSeconds: 300,
      devCode: '123456',
    })
  })
})
