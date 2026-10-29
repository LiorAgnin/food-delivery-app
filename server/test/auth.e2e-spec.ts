import type { INestApplication } from '@nestjs/common'
import request from 'supertest'
import { Clock } from '../src/auth/clock'
import { createTestApp, destroyTestApp } from './setup'

const FIVE_MINUTES_MS = 5 * 60 * 1000

describe('otp auth', () => {
  let app: INestApplication

  beforeAll(async () => {
    app = await createTestApp()
  })

  afterAll(async () => {
    await destroyTestApp()
  })

  it('issues a dev code and verifies it', async () => {
    const phone = '+972501110001'
    const http = request(app.getHttpServer())

    const requested = await http
      .post('/api/auth/otp/request')
      .send({ phone })
      .expect(202)
    expect(requested.body).toEqual({
      expiresInSeconds: 300,
      devCode: '123456',
    })

    const verified = await http
      .post('/api/auth/otp/verify')
      .send({ phone, code: '123456' })
      .expect(200)
    expect(verified.body.customer.phone).toBe(phone)
    expect(typeof verified.body.customer.id).toBe('string')
    expect(typeof verified.body.accessToken).toBe('string')

    await http.post('/api/auth/otp/request').send({ phone }).expect(202)
    const again = await http
      .post('/api/auth/otp/verify')
      .send({ phone, code: '123456' })
      .expect(200)
    expect(again.body.customer.id).toBe(verified.body.customer.id)
  })

  it('rejects a phone that is not E.164', async () => {
    const response = await request(app.getHttpServer())
      .post('/api/auth/otp/request')
      .send({ phone: '0501234567' })
      .expect(400)

    expect(response.body.error.code).toBe('VALIDATION_FAILED')
  })

  it('accepts the right code after a wrong one', async () => {
    const phone = '+972501110002'
    const http = request(app.getHttpServer())
    await http.post('/api/auth/otp/request').send({ phone }).expect(202)

    const wrong = await http
      .post('/api/auth/otp/verify')
      .send({ phone, code: '000000' })
      .expect(401)
    expect(wrong.body.error.code).toBe('OTP_INVALID')

    const right = await http
      .post('/api/auth/otp/verify')
      .send({ phone, code: '123456' })
      .expect(200)
    expect(right.body.customer.phone).toBe(phone)
  })

  it('rejects a code once the clock passes the five-minute expiry', async () => {
    const phone = '+972501110003'
    const http = request(app.getHttpServer())
    await http.post('/api/auth/otp/request').send({ phone }).expect(202)
    app.get(Clock).advance(FIVE_MINUTES_MS)

    const response = await http
      .post('/api/auth/otp/verify')
      .send({ phone, code: '123456' })
      .expect(401)
    expect(response.body.error.code).toBe('OTP_EXPIRED')
  })

  it('locks the challenge after five wrong codes', async () => {
    const phone = '+972501110004'
    const http = request(app.getHttpServer())
    await http.post('/api/auth/otp/request').send({ phone }).expect(202)

    for (let attempt = 0; attempt < 5; attempt += 1) {
      const wrong = await http
        .post('/api/auth/otp/verify')
        .send({ phone, code: '000000' })
        .expect(401)
      expect(wrong.body.error.code).toBe('OTP_INVALID')
    }

    const blocked = await http
      .post('/api/auth/otp/verify')
      .send({ phone, code: '123456' })
      .expect(429)
    expect(blocked.body.error.code).toBe('OTP_TOO_MANY_ATTEMPTS')
  })

  it('rejects a code that was already consumed', async () => {
    const phone = '+972501110005'
    const http = request(app.getHttpServer())
    await http.post('/api/auth/otp/request').send({ phone }).expect(202)
    await http
      .post('/api/auth/otp/verify')
      .send({ phone, code: '123456' })
      .expect(200)

    const replay = await http
      .post('/api/auth/otp/verify')
      .send({ phone, code: '123456' })
      .expect(401)
    expect(replay.body.error.code).toBe('OTP_INVALID')
  })

  it('rejects the older code after a newer one was consumed', async () => {
    const phone = '+972501110008'
    const http = request(app.getHttpServer())
    await http.post('/api/auth/otp/request').send({ phone }).expect(202)
    await http.post('/api/auth/otp/request').send({ phone }).expect(202)

    const verified = await http
      .post('/api/auth/otp/verify')
      .send({ phone, code: '123456' })
      .expect(200)
    expect(verified.body.customer.phone).toBe(phone)

    const replay = await http
      .post('/api/auth/otp/verify')
      .send({ phone, code: '123456' })
      .expect(401)
    expect(replay.body.error.code).toBe('OTP_INVALID')
  })

  it('allows three code requests in ten minutes and blocks the fourth', async () => {
    const phone = '+972501110006'
    const http = request(app.getHttpServer())
    for (let count = 0; count < 3; count += 1) {
      await http.post('/api/auth/otp/request').send({ phone }).expect(202)
    }

    const blocked = await http
      .post('/api/auth/otp/request')
      .send({ phone })
      .expect(429)
    expect(blocked.body.error.code).toBe('OTP_TOO_MANY_ATTEMPTS')

    app.get(Clock).advance(10 * 60 * 1000)
    await http.post('/api/auth/otp/request').send({ phone }).expect(202)
  })

  it('accepts the new code after five wrong tries on the previous one', async () => {
    const phone = '+972501110009'
    const http = request(app.getHttpServer())
    await http.post('/api/auth/otp/request').send({ phone }).expect(202)

    for (let attempt = 0; attempt < 5; attempt += 1) {
      const wrong = await http
        .post('/api/auth/otp/verify')
        .send({ phone, code: '000000' })
        .expect(401)
      expect(wrong.body.error.code).toBe('OTP_INVALID')
    }

    await http.post('/api/auth/otp/request').send({ phone }).expect(202)
    const verified = await http
      .post('/api/auth/otp/verify')
      .send({ phone, code: '123456' })
      .expect(200)
    expect(verified.body.customer.phone).toBe(phone)
  })

  it('accepts exactly three of ten parallel code requests for one phone', async () => {
    const phone = '+972501110007'
    const responses = await Promise.all(
      Array.from({ length: 10 }, () =>
        request(app.getHttpServer())
          .post('/api/auth/otp/request')
          .send({ phone }),
      ),
    )
    const statuses = responses.map((response) => response.status).sort()
    const blocked = responses.filter((response) => response.status === 429)

    expect(statuses).toEqual([202, 202, 202, 429, 429, 429, 429, 429, 429, 429])
    expect(blocked).toHaveLength(7)
    for (const response of blocked) {
      expect(response.body.error.code).toBe('OTP_TOO_MANY_ATTEMPTS')
    }
  })
})
