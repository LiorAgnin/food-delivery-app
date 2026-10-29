import { ValidationPipe, type ValidationPipeOptions } from '@nestjs/common'
import type { ValidationError } from 'class-validator'
import { DomainError } from './domain-error'

export function fieldErrors (
  errors: ValidationError[],
  prefix = '',
): Record<string, string[]> {
  const fields: Record<string, string[]> = {}
  for (const error of errors) {
    const path = prefix === '' ? error.property : `${prefix}.${error.property}`
    if (error.constraints) {
      fields[path] = Object.values(error.constraints)
    }
    if (error.children && error.children.length > 0) {
      Object.assign(fields, fieldErrors(error.children, path))
    }
  }
  return fields
}

export function validationException (errors: ValidationError[]): DomainError {
  return new DomainError('VALIDATION_FAILED', 'Validation failed', {
    fields: fieldErrors(errors),
  })
}

export function createValidationPipe (): ValidationPipe {
  const options: ValidationPipeOptions = {
    transform: true,
    whitelist: true,
    forbidNonWhitelisted: true,
    exceptionFactory: validationException,
  }
  return new ValidationPipe(options)
}

export const validationPipe = createValidationPipe()
