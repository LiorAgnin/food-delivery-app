import {
  type ArgumentsHost,
  Catch,
  type ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common'
import type { Response } from 'express'
import { DomainError, type ErrorCode } from './domain-error'

const STATUS_CODE: Partial<Record<number, ErrorCode>> = {
  [HttpStatus.BAD_REQUEST]: 'VALIDATION_FAILED',
  [HttpStatus.UNAUTHORIZED]: 'UNAUTHORIZED',
  [HttpStatus.NOT_FOUND]: 'NOT_FOUND',
  [HttpStatus.TOO_MANY_REQUESTS]: 'OTP_TOO_MANY_ATTEMPTS',
}

type Envelope = {
  status: number
  code: ErrorCode
  message: string
  details: Record<string, unknown>
}

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger(AllExceptionsFilter.name)

  catch (exception: unknown, host: ArgumentsHost): void {
    const response = host.switchToHttp().getResponse<Response>()
    const envelope = this.toEnvelope(exception)
    response.status(envelope.status).json({
      error: {
        code: envelope.code,
        message: envelope.message,
        details: envelope.details,
      },
    })
  }

  private toEnvelope (exception: unknown): Envelope {
    if (exception instanceof DomainError) {
      return {
        status: exception.status,
        code: exception.code,
        message: exception.message,
        details: exception.details,
      }
    }

    if (exception instanceof HttpException) {
      const status = exception.getStatus()
      if (status === HttpStatus.FORBIDDEN) {
        return {
          status: HttpStatus.UNAUTHORIZED,
          code: 'UNAUTHORIZED',
          message: httpMessage(exception),
          details: httpDetails(exception),
        }
      }
      const code = STATUS_CODE[status]
      if (code) {
        return {
          status,
          code,
          message: httpMessage(exception),
          details: httpDetails(exception),
        }
      }
      if (status >= 400 && status < 500) {
        return {
          status: HttpStatus.BAD_REQUEST,
          code: 'VALIDATION_FAILED',
          message: httpMessage(exception),
          details: httpDetails(exception),
        }
      }
    }

    if (isClientFault(exception)) {
      return {
        status: HttpStatus.BAD_REQUEST,
        code: 'VALIDATION_FAILED',
        message: clientFaultMessage(exception),
        details: {},
      }
    }

    this.logger.error(
      exception instanceof Error
        ? (exception.stack ?? exception.message)
        : 'Unknown error',
    )
    return {
      status: HttpStatus.INTERNAL_SERVER_ERROR,
      code: 'INTERNAL',
      message: 'Internal server error',
      details: {},
    }
  }
}

function isClientFault (exception: unknown): boolean {
  if (isBodyParserError(exception)) return true
  const status = readStatus(exception)
  return status !== undefined && status >= 400 && status < 500
}

function clientFaultMessage (exception: unknown): string {
  if (isParseFailure(exception)) return 'Malformed JSON body'
  if (exception instanceof Error && exception.message.length > 0) {
    return exception.message
  }
  return 'Validation failed'
}

function isParseFailure (exception: unknown): boolean {
  if (typeof exception !== 'object' || exception === null) return false
  return (exception as { type?: unknown }).type === 'entity.parse.failed'
}

function isBodyParserError (exception: unknown): boolean {
  if (typeof exception !== 'object' || exception === null) return false
  const type = (exception as { type?: unknown }).type
  return type === 'entity.too.large' || type === 'entity.parse.failed'
}

function readStatus (exception: unknown): number | undefined {
  if (typeof exception !== 'object' || exception === null) return undefined
  const record = exception as { status?: unknown; statusCode?: unknown }
  if (typeof record.status === 'number') return record.status
  if (typeof record.statusCode === 'number') return record.statusCode
  return undefined
}

function httpMessage (exception: HttpException): string {
  const body = exception.getResponse()
  const message = readHttpMessage(body, exception.message)
  // Nest wraps a JSON SyntaxError as BadRequestException and drops `type`.
  if (isMalformedJsonMessage(message)) return 'Malformed JSON body'
  return message
}

function readHttpMessage (body: unknown, fallback: string): string {
  if (typeof body === 'string' && body.length > 0) return body
  if (typeof body === 'object' && body !== null && 'message' in body) {
    const message = (body as { message: unknown }).message
    if (typeof message === 'string' && message.length > 0) return message
    if (Array.isArray(message)) return 'Validation failed'
  }
  return fallback
}

function isMalformedJsonMessage (message: string): boolean {
  return (
    message.includes('in JSON') ||
    message.includes('not valid JSON') ||
    message.includes('Unexpected end of JSON') ||
    message.includes('Unexpected token')
  )
}

function httpDetails (exception: HttpException): Record<string, unknown> {
  const body = exception.getResponse()
  if (typeof body !== 'object' || body === null) return {}
  if (
    'details' in body &&
    typeof (body as { details: unknown }).details === 'object' &&
    (body as { details: unknown }).details !== null &&
    !Array.isArray((body as { details: unknown }).details)
  ) {
    return (body as { details: Record<string, unknown> }).details
  }
  if (
    'message' in body &&
    Array.isArray((body as { message: unknown }).message)
  ) {
    const messages = (body as { message: unknown[] }).message.filter(
      (item): item is string => typeof item === 'string',
    )
    return { messages }
  }
  return {}
}
