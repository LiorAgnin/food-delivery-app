import {
  type ArgumentsHost,
  ForbiddenException,
  HttpException,
} from '@nestjs/common'
import { AllExceptionsFilter } from './all-exceptions.filter'
import { DomainError } from './domain-error'

function capture (): {
  host: ArgumentsHost
  status: () => number | undefined
  body: () => unknown
} {
  const captured: { status?: number; body?: unknown } = {}
  const response = {
    status (code: number) {
      captured.status = code
      return this
    },
    json (payload: unknown) {
      captured.body = payload
    },
  }
  const host = {
    switchToHttp: () => ({
      getResponse: () => response,
    }),
  } as ArgumentsHost
  return {
    host,
    status: () => captured.status,
    body: () => captured.body,
  }
}

function bodyParserError (type: string, status: number, message: string): Error {
  return Object.assign(new Error(message), { type, status, statusCode: status })
}

describe('exception envelope', () => {
  const filter = new AllExceptionsFilter()

  it('maps an oversized body to VALIDATION_FAILED', () => {
    const captured = capture()
    filter.catch(
      bodyParserError('entity.too.large', 413, 'request entity too large'),
      captured.host,
    )
    expect(captured.status()).toBe(400)
    expect(captured.body()).toEqual({
      error: {
        code: 'VALIDATION_FAILED',
        message: 'request entity too large',
        details: {},
      },
    })
  })

  it('maps a malformed body to VALIDATION_FAILED', () => {
    const captured = capture()
    filter.catch(
      bodyParserError('entity.parse.failed', 400, 'Unexpected token'),
      captured.host,
    )
    expect(captured.status()).toBe(400)
    expect(captured.body()).toEqual({
      error: {
        code: 'VALIDATION_FAILED',
        message: 'Unexpected token',
        details: {},
      },
    })
  })

  it('maps ForbiddenException to UNAUTHORIZED', () => {
    const captured = capture()
    filter.catch(new ForbiddenException(), captured.host)
    expect(captured.status()).toBe(401)
    expect(captured.body()).toEqual({
      error: {
        code: 'UNAUTHORIZED',
        message: 'Forbidden',
        details: {},
      },
    })
  })

  it('maps an unmapped 4xx HttpException to VALIDATION_FAILED', () => {
    const captured = capture()
    filter.catch(new HttpException('unsupported media type', 415), captured.host)
    expect(captured.status()).toBe(400)
    expect(captured.body()).toEqual({
      error: {
        code: 'VALIDATION_FAILED',
        message: 'unsupported media type',
        details: {},
      },
    })
  })

  it('keeps a DomainError code', () => {
    const captured = capture()
    filter.catch(new DomainError('NOT_FOUND', 'Restaurant not found'), captured.host)
    expect(captured.status()).toBe(404)
    expect(captured.body()).toEqual({
      error: {
        code: 'NOT_FOUND',
        message: 'Restaurant not found',
        details: {},
      },
    })
  })

  it('reserves INTERNAL for a real fault', () => {
    const captured = capture()
    filter.catch(new Error('database down'), captured.host)
    expect(captured.status()).toBe(500)
    expect(captured.body()).toEqual({
      error: {
        code: 'INTERNAL',
        message: 'Internal server error',
        details: {},
      },
    })
  })
})
