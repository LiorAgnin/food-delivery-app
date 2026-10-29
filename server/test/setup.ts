import type { INestApplication } from '@nestjs/common'
import { Test } from '@nestjs/testing'
import type { StartedPostgreSqlContainer } from '@testcontainers/postgresql'

let container: StartedPostgreSqlContainer | undefined
let app: INestApplication | undefined

export async function createTestApp (): Promise<INestApplication> {
  const { PostgreSqlContainer } = await import('@testcontainers/postgresql')
  container = await new PostgreSqlContainer('postgres:17-alpine')
    .withStartupTimeout(120_000)
    .start()

  process.env.DATABASE_URL = container.getConnectionUri()
  process.env.JWT_SECRET = 'test-secret'
  process.env.OTP_DEV_MODE = 'true'
  process.env.PORT = '3000'

  const { resetEnvCache } = await import('../src/config/env')
  resetEnvCache()

  const { migrate } = await import('../src/db/migrate')
  await migrate()
  const { seed } = await import('../src/db/seed')
  await seed()
  await seed()

  const { AppModule } = await import('../src/app.module')
  const { configureApp } = await import('../src/configure-app')
  const moduleRef = await Test.createTestingModule({
    imports: [AppModule],
  }).compile()
  app = moduleRef.createNestApplication()
  configureApp(app)
  await app.init()
  return app
}

export async function destroyTestApp (): Promise<void> {
  await app?.close()
  app = undefined
  await container?.stop()
  container = undefined
}
