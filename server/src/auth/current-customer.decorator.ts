import { createParamDecorator, type ExecutionContext } from '@nestjs/common'
import { DomainError } from '../common/domain-error'
import type {
  AuthenticatedCustomer,
  RequestWithCustomer,
} from './authenticated-request'

export function customerFromRequest (
  request: RequestWithCustomer,
): AuthenticatedCustomer {
  if (!request.customer) {
    throw new DomainError('UNAUTHORIZED', 'Authentication required')
  }
  return request.customer
}

export const CurrentCustomer = createParamDecorator(
  (_data: unknown, context: ExecutionContext): AuthenticatedCustomer =>
    customerFromRequest(
      context.switchToHttp().getRequest<RequestWithCustomer>(),
    ),
)
