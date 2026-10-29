import { type ExecutionContext } from '@nestjs/common'
import { JwtService } from '@nestjs/jwt'
import { DomainError } from '../common/domain-error'
import type { RequestWithCustomer } from './authenticated-request'
import { customerFromRequest } from './current-customer.decorator'
import { JwtAuthGuard } from './jwt-auth.guard'
import { TokenService } from './token.service'

const SEVEN_DAYS_SECONDS = 60 * 60 * 24 * 7

function jwtWith (secret: string): JwtService {
  return new JwtService({
    secret,
    signOptions: { algorithm: 'HS256', expiresIn: SEVEN_DAYS_SECONDS },
    verifyOptions: { algorithms: ['HS256'] },
  })
}

function contextFor (request: RequestWithCustomer): ExecutionContext {
  return {
    switchToHttp: () => ({
      getRequest: () => request,
    }),
  } as ExecutionContext
}

describe('auth plumbing', () => {
  const jwt = jwtWith('test-secret')
  const tokens = new TokenService(jwt)
  const guard = new JwtAuthGuard(jwt)

  it('signs a 7-day HS256 token whose sub is the customer id', () => {
    const token = tokens.sign('customer-1')
    const decoded = jwt.decode(token) as {
      sub: string
      iat: number
      exp: number
    }

    expect(decoded.sub).toBe('customer-1')
    expect(decoded.exp - decoded.iat).toBe(SEVEN_DAYS_SECONDS)

    const request: RequestWithCustomer = {
      headers: { authorization: `Bearer ${token}` },
    }
    expect(guard.canActivate(contextFor(request))).toBe(true)
    expect(request.customer).toEqual({ id: 'customer-1' })
    expect(customerFromRequest(request)).toEqual({ id: 'customer-1' })
  })

  it('rejects a missing bearer token', () => {
    const request: RequestWithCustomer = { headers: {} }
    expect(() => guard.canActivate(contextFor(request))).toThrow(DomainError)
    try {
      guard.canActivate(contextFor(request))
    } catch (error) {
      expect(error).toMatchObject({ code: 'UNAUTHORIZED', status: 401 })
    }
  })

  it('rejects an expired token', () => {
    const token = jwt.sign({ sub: 'customer-1' }, { expiresIn: -10 })
    const request: RequestWithCustomer = {
      headers: { authorization: `Bearer ${token}` },
    }
    expect(() => guard.canActivate(contextFor(request))).toThrow(DomainError)
    try {
      guard.canActivate(contextFor(request))
    } catch (error) {
      expect(error).toMatchObject({ code: 'UNAUTHORIZED', status: 401 })
    }
  })

  it('rejects a token signed with another secret', () => {
    const token = new TokenService(jwtWith('other-secret')).sign('customer-1')
    const request: RequestWithCustomer = {
      headers: { authorization: `Bearer ${token}` },
    }
    expect(() => guard.canActivate(contextFor(request))).toThrow(DomainError)
  })

  it('requires the guard to have attached a customer', () => {
    expect(() => customerFromRequest({ headers: {} })).toThrow(DomainError)
  })
})
