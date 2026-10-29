import { Injectable, type PipeTransform } from '@nestjs/common'
import { DomainError } from './domain-error'

const UUID_V4 =
  /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i

@Injectable()
export class ParseUuidPipe implements PipeTransform<string, string> {
  transform (value: string): string {
    if (!UUID_V4.test(value)) {
      throw new DomainError('VALIDATION_FAILED', 'Validation failed', {
        fields: { id: ['must be a UUID v4'] },
      })
    }
    return value
  }
}
