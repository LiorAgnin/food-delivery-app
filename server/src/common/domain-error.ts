export const ERROR_CODES = [
  'VALIDATION_FAILED',
  'UNAUTHORIZED',
  'NOT_FOUND',
  'INVALID_TRANSITION',
  'CONCURRENT_UPDATE',
  'IDEMPOTENCY_CONFLICT',
  'RESTAURANT_CLOSED',
  'ITEM_UNAVAILABLE',
  'ITEM_NOT_IN_RESTAURANT',
  'BELOW_MINIMUM',
  'OTP_INVALID',
  'OTP_EXPIRED',
  'OTP_TOO_MANY_ATTEMPTS',
  'INTERNAL',
] as const

export type ErrorCode = (typeof ERROR_CODES)[number]

const ERROR_STATUS: Record<ErrorCode, number> = {
  VALIDATION_FAILED: 400,
  UNAUTHORIZED: 401,
  NOT_FOUND: 404,
  INVALID_TRANSITION: 409,
  CONCURRENT_UPDATE: 409,
  IDEMPOTENCY_CONFLICT: 409,
  RESTAURANT_CLOSED: 422,
  ITEM_UNAVAILABLE: 422,
  ITEM_NOT_IN_RESTAURANT: 422,
  BELOW_MINIMUM: 422,
  OTP_INVALID: 401,
  OTP_EXPIRED: 401,
  OTP_TOO_MANY_ATTEMPTS: 429,
  INTERNAL: 500,
}

export class DomainError extends Error {
  readonly status: number
  readonly details: Record<string, unknown>

  constructor (
    readonly code: ErrorCode,
    message: string,
    details: Record<string, unknown> = {},
  ) {
    super(message)
    this.name = 'DomainError'
    this.status = ERROR_STATUS[code]
    this.details = details
  }
}
