import { createHmac, timingSafeEqual } from 'node:crypto'
import { DomainError } from '../common/domain-error'

const OTP_CODE_SPACE = 1_000_000
const OTP_TTL_MS = 5 * 60 * 1000
const OTP_MAX_ATTEMPTS = 5
const OTP_MAX_REQUESTS = 3
const OTP_REQUEST_WINDOW_MS = 10 * 60 * 1000

export type Clock = {
  now: () => Date
}

export type OtpChallengeSnapshot = {
  codeHash: string
  expiresAt: Date
  attempts: number
  consumedAt: Date | null
}

export type IssuedOtp = {
  code: string
  codeHash: string
  expiresAt: Date
}

export type OtpDecision =
  | { kind: 'accept' }
  | { kind: 'mismatch'; attempts: number }
  | { kind: 'expired' }
  | { kind: 'too_many_attempts' }
  | { kind: 'invalid' }

export type OtpRequestBody = {
  expiresInSeconds: number
  devCode?: string
}

export class OtpCodeGenerator {
  constructor (
    private readonly devMode: boolean,
    private readonly randomInt: (min: number, max: number) => number,
  ) {}

  nextCode (): string {
    if (this.devMode) return '123456'
    return this.randomInt(0, OTP_CODE_SPACE).toString().padStart(6, '0')
  }
}

export class OtpPolicy {
  constructor (
    private readonly clock: Clock,
    private readonly codes: { nextCode: () => string },
    private readonly secret: string,
  ) {}

  static requestBody (devMode: boolean, code: string): OtpRequestBody {
    const expiresInSeconds = OTP_TTL_MS / 1000
    if (devMode) return { expiresInSeconds, devCode: code }
    return { expiresInSeconds }
  }

  windowStart (): Date {
    return new Date(this.clock.now().getTime() - OTP_REQUEST_WINDOW_MS)
  }

  issue (requestsInWindow: number): IssuedOtp {
    if (requestsInWindow >= OTP_MAX_REQUESTS) {
      throw new DomainError(
        'OTP_TOO_MANY_ATTEMPTS',
        'Too many code requests. Try again in a few minutes.',
      )
    }
    const code = this.codes.nextCode()
    return {
      code,
      codeHash: hashOtpCode(code, this.secret),
      expiresAt: new Date(this.clock.now().getTime() + OTP_TTL_MS),
    }
  }

  decide (
    challenge: OtpChallengeSnapshot | null,
    submittedCode: string,
  ): OtpDecision {
    if (!challenge || challenge.consumedAt) return { kind: 'invalid' }
    if (this.clock.now().getTime() >= challenge.expiresAt.getTime()) {
      return { kind: 'expired' }
    }
    if (challenge.attempts >= OTP_MAX_ATTEMPTS) {
      return { kind: 'too_many_attempts' }
    }
    const submittedHash = hashOtpCode(submittedCode, this.secret)
    if (!hashesMatch(challenge.codeHash, submittedHash)) {
      return { kind: 'mismatch', attempts: challenge.attempts + 1 }
    }
    return { kind: 'accept' }
  }
}

function hashOtpCode (code: string, secret: string): string {
  return createHmac('sha256', secret).update(code).digest('hex')
}

function hashesMatch (storedHex: string, submittedHex: string): boolean {
  const stored = Buffer.from(storedHex, 'hex')
  const submitted = Buffer.from(submittedHex, 'hex')
  if (stored.length === 0 || stored.length !== submitted.length) return false
  return timingSafeEqual(stored, submitted)
}
