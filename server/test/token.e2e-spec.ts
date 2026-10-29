import { JwtService } from '@nestjs/jwt'
import { issueTokenForPhone } from '../src/auth/print-token'
import { createTestApp, destroyTestApp } from './setup'

const SEVEN_DAYS_SECONDS = 60 * 60 * 24 * 7

type AccessToken = { sub: string; iat: number; exp: number }

describe('dev token', () => {
  const jwt = new JwtService({ secret: 'test-secret' })

  beforeAll(async () => {
    await createTestApp()
  })

  afterAll(async () => {
    await destroyTestApp()
  })

  it('upserts a customer by phone and signs a 7-day token for that id', async () => {
    const phone = '+972509998877'
    const first = jwt.verify(await issueTokenForPhone(phone)) as AccessToken
    const second = jwt.verify(await issueTokenForPhone(phone)) as AccessToken
    const other = jwt.verify(
      await issueTokenForPhone('+972509998878'),
    ) as AccessToken

    expect(first.sub).toBe(second.sub)
    expect(other.sub).not.toBe(first.sub)
    expect(first.exp - first.iat).toBe(SEVEN_DAYS_SECONDS)
  })
})
