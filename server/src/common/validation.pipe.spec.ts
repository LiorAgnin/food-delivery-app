import {
  Body,
  Controller,
  Get,
  type INestApplication,
  Module,
  Param,
  Post,
} from '@nestjs/common'
import { Test } from '@nestjs/testing'
import { IsString } from 'class-validator'
import request from 'supertest'
import { configureApp } from '../configure-app'
import { ParseUuidPipe } from './parse-uuid.pipe'

class ProbeBody {
  @IsString()
  name!: string
}

@Controller('probe')
class ProbeController {
  @Post()
  create (@Body() _body: ProbeBody): { ok: true } {
    return { ok: true }
  }

  @Get(':restaurantId')
  byRestaurant (@Param('restaurantId', ParseUuidPipe) restaurantId: string): {
    restaurantId: string
  } {
    return { restaurantId }
  }
}

@Module({ controllers: [ProbeController] })
class ProbeModule {}

describe('validation envelope', () => {
  let app: INestApplication

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [ProbeModule],
    }).compile()
    app = moduleRef.createNestApplication()
    configureApp(app)
    await app.init()
  })

  afterAll(async () => {
    await app.close()
  })

  it('maps class-validator failures to VALIDATION_FAILED with field details', async () => {
    const response = await request(app.getHttpServer())
      .post('/api/probe')
      .send({})
      .expect(400)

    expect(response.body.error.code).toBe('VALIDATION_FAILED')
    expect(response.body.error.message).toBe('Validation failed')
    expect(response.body.error.details.fields.name.length).toBeGreaterThan(0)
  })

  it('rejects unknown fields', async () => {
    const response = await request(app.getHttpServer())
      .post('/api/probe')
      .send({ name: 'Ada', extra: true })
      .expect(400)

    expect(response.body.error.code).toBe('VALIDATION_FAILED')
    expect(response.body.error.details.fields.extra).toBeDefined()
  })

  it('names the invalid uuid field after the route param', async () => {
    const response = await request(app.getHttpServer())
      .get('/api/probe/not-a-uuid')
      .expect(400)

    expect(response.body.error.code).toBe('VALIDATION_FAILED')
    expect(response.body.error.details.fields).toEqual({
      restaurantId: ['must be a UUID v4'],
    })
  })

  it('accepts a valid body', async () => {
    await request(app.getHttpServer())
      .post('/api/probe')
      .send({ name: 'Ada' })
      .expect(201)
  })
})
