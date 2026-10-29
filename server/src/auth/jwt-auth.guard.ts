import {
  type CanActivate,
  type ExecutionContext,
  Injectable,
} from '@nestjs/common'
import { JwtService } from '@nestjs/jwt'
import { DomainError } from '../common/domain-error'
import type { RequestWithCustomer } from './authenticated-request'

const BEARER = /^Bearer\s+(\S+)\s*$/i

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor (private readonly jwt: JwtService) {}

  canActivate (context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<RequestWithCustomer>()
    const header = request.headers.authorization
    const token =
      typeof header === 'string' ? BEARER.exec(header)?.[1] : undefined
    if (!token) {
      throw new DomainError('UNAUTHORIZED', 'Missing bearer token')
    }

    let payload: unknown
    try {
      payload = this.jwt.verify(token)
    } catch {
      throw new DomainError('UNAUTHORIZED', 'Invalid token')
    }

    const customerId = readSubject(payload)
    if (!customerId) {
      throw new DomainError('UNAUTHORIZED', 'Invalid token')
    }

    request.customer = { id: customerId }
    return true
  }
}

function readSubject (payload: unknown): string | undefined {
  if (typeof payload !== 'object' || payload === null || !('sub' in payload)) {
    return undefined
  }
  const subject = (payload as { sub: unknown }).sub
  if (typeof subject !== 'string' || subject.length === 0) return undefined
  return subject
}
