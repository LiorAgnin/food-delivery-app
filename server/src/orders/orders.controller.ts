import {
  Body,
  Controller,
  Get,
  Headers,
  Param,
  Patch,
  Post,
  Res,
  UseGuards,
} from '@nestjs/common'
import type { Response } from 'express'
import type { AuthenticatedCustomer } from '../auth/authenticated-request'
import { CurrentCustomer } from '../auth/current-customer.decorator'
import { JwtAuthGuard } from '../auth/jwt-auth.guard'
import { DomainError } from '../common/domain-error'
import { ParseUuidPipe } from '../common/parse-uuid.pipe'
import { CreateOrderDto } from './dto/create-order.dto'
import { UpdateOrderStatusDto } from './dto/update-order-status.dto'
import type { OrderResponse } from './order-response'
import { OrdersService } from './orders.service'

const MAX_IDEMPOTENCY_KEY_LENGTH = 200

export function requireIdempotencyKey (
  value: string | string[] | undefined,
): string {
  if (Array.isArray(value)) {
    throw new DomainError('VALIDATION_FAILED', 'Validation failed', {
      fields: { 'Idempotency-Key': ['must be a single value'] },
    })
  }
  const key = value?.trim() ?? ''
  if (key.length === 0 || key.length > MAX_IDEMPOTENCY_KEY_LENGTH) {
    throw new DomainError('VALIDATION_FAILED', 'Validation failed', {
      fields: { 'Idempotency-Key': ['is required'] },
    })
  }
  return key
}

@Controller('orders')
export class OrdersController {
  constructor (private readonly orders: OrdersService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  async create (
    @CurrentCustomer() customer: AuthenticatedCustomer,
    @Headers('idempotency-key') idempotencyKey: string | string[] | undefined,
    @Body() body: CreateOrderDto,
    @Res({ passthrough: true }) response: Response,
  ): Promise<OrderResponse> {
    const placed = await this.orders.place(
      customer.id,
      requireIdempotencyKey(idempotencyKey),
      body,
    )
    response.status(placed.created ? 201 : 200)
    return placed.order
  }

  @Get(':id')
  @UseGuards(JwtAuthGuard)
  get (
    @CurrentCustomer() customer: AuthenticatedCustomer,
    @Param('id', ParseUuidPipe) id: string,
  ): Promise<OrderResponse> {
    return this.orders.get(customer.id, id)
  }

  @Patch(':id/status')
  updateStatus (
    @Param('id', ParseUuidPipe) id: string,
    @Body() body: UpdateOrderStatusDto,
  ): Promise<OrderResponse> {
    return this.orders.transition(id, body.status, body.actor)
  }
}
