import { Injectable } from '@nestjs/common'
import { JwtService } from '@nestjs/jwt'

const SEVEN_DAYS_SECONDS = 60 * 60 * 24 * 7

@Injectable()
export class TokenService {
  constructor (private readonly jwt: JwtService) {}

  sign (customerId: string): string {
    return this.jwt.sign(
      { sub: customerId },
      { expiresIn: SEVEN_DAYS_SECONDS, algorithm: 'HS256' },
    )
  }
}

export const ACCESS_TOKEN_TTL_SECONDS = SEVEN_DAYS_SECONDS
