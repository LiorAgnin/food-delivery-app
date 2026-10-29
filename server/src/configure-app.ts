import type { INestApplication } from '@nestjs/common'
import { AllExceptionsFilter } from './common/all-exceptions.filter'
import { validationPipe } from './common/validation.pipe'

export function configureApp (app: INestApplication): void {
  app.setGlobalPrefix('api')
  app.useGlobalPipes(validationPipe)
  app.useGlobalFilters(new AllExceptionsFilter())
}
