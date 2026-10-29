import path from 'node:path'
import { NestFactory } from '@nestjs/core'
import { AppModule } from './app.module'
import { getEnv } from './config/env'
import { configureApp } from './configure-app'

async function bootstrap (): Promise<void> {
  const app = await NestFactory.create(AppModule)
  configureApp(app)
  app.enableShutdownHooks()
  await app.listen(getEnv().PORT)
}

function isDirectRun (): boolean {
  const entry = process.argv[1]
  if (!entry) return false
  return path.resolve(entry) === path.resolve(__filename)
}

if (isDirectRun()) {
  bootstrap().catch((error: unknown) => {
    console.error(error)
    process.exit(1)
  })
}
