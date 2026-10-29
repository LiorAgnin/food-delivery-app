import { Inject, Injectable } from '@nestjs/common'
import { and, asc, eq, inArray } from 'drizzle-orm'
import type { ExtractTablesWithRelations } from 'drizzle-orm'
import type { NodePgQueryResultHKT } from 'drizzle-orm/node-postgres'
import type { PgTransaction } from 'drizzle-orm/pg-core'
import { DomainError } from '../common/domain-error'
import { DRIZZLE, type Database } from '../db/database.module'
import {
  type OrderRow,
  menuItems,
  openingHours,
  orderItems,
  orderStatusEvents,
  orders,
  restaurants,
} from '../db/schema'
import * as schema from '../db/schema'
import { isOpenNow } from '../restaurants/is-open-now'
import { idempotencyBodyHash } from './idempotency-body'
import { assertTransition, type Actor, type OrderStatus } from './order-lifecycle'
import { toOrderResponse, type OrderResponse } from './order-response'
import { priceOrder, type OrderItemRequest } from './price-order'

type OrderTx = PgTransaction<
  NodePgQueryResultHKT,
  typeof schema,
  ExtractTablesWithRelations<typeof schema>
>

type OrderDb = Database | OrderTx

type PlaceResult = { created: boolean; order: OrderResponse }

const IDEMPOTENCY_CONSTRAINT = 'orders_customer_idempotency_uq'

@Injectable()
export class OrdersService {
  constructor (@Inject(DRIZZLE) private readonly db: Database) {}

  async place (
    customerId: string,
    idempotencyKey: string,
    body: { restaurantId: string; items: OrderItemRequest[] },
  ): Promise<PlaceResult> {
    const hash = idempotencyBodyHash(body)
    const existing = await this.findByKey(this.db, customerId, idempotencyKey)
    if (existing) return this.replay(this.db, existing, hash, customerId)

    try {
      return await this.db.transaction(async (tx) => {
        const raced = await this.findByKey(tx, customerId, idempotencyKey)
        if (raced) return this.replay(tx, raced, hash, customerId)

        const priced = await this.price(tx, body, new Date())
        const [inserted] = await tx
          .insert(orders)
          .values({
            customerId,
            restaurantId: priced.restaurantId,
            status: 'PLACED',
            subtotalAgorot: priced.subtotalAgorot,
            deliveryFeeAgorot: priced.deliveryFeeAgorot,
            totalAgorot: priced.totalAgorot,
            restaurantName: priced.restaurantName,
            idempotencyKey,
            idempotencyBodyHash: hash,
          })
          .returning({ id: orders.id })
        if (!inserted) {
          throw new DomainError('INTERNAL', 'Order insert returned no row')
        }

        await tx.insert(orderItems).values(
          priced.items.map((item) => ({
            orderId: inserted.id,
            menuItemId: item.menuItemId,
            name: item.name,
            unitPriceAgorot: item.unitPriceAgorot,
            quantity: item.quantity,
            lineTotalAgorot: item.lineTotalAgorot,
          })),
        )
        await tx.insert(orderStatusEvents).values({
          orderId: inserted.id,
          fromStatus: null,
          toStatus: 'PLACED',
          actor: 'customer',
        })
        return {
          created: true,
          order: await this.readOrder(tx, inserted.id, customerId),
        }
      })
    } catch (error) {
      // A unique violation aborts the transaction, so the winner is read after rollback.
      if (!isIdempotencyRace(error)) throw error
      const winner = await this.findByKey(this.db, customerId, idempotencyKey)
      if (!winner) throw error
      return this.replay(this.db, winner, hash, customerId)
    }
  }

  get (customerId: string, orderId: string): Promise<OrderResponse> {
    return this.readOrder(this.db, orderId, customerId)
  }

  async transition (
    orderId: string,
    to: OrderStatus,
    actor: Actor,
  ): Promise<OrderResponse> {
    return this.db.transaction(async (tx) => {
      const [current] = await tx
        .select()
        .from(orders)
        .where(eq(orders.id, orderId))
      if (!current) throw new DomainError('NOT_FOUND', 'Order not found')

      assertTransition(current.status, to, actor)

      const [updated] = await tx
        .update(orders)
        .set({ status: to, updatedAt: new Date() })
        .where(and(eq(orders.id, orderId), eq(orders.status, current.status)))
        .returning({ id: orders.id })
      if (!updated) {
        throw new DomainError(
          'CONCURRENT_UPDATE',
          'Order status changed concurrently',
        )
      }

      await tx.insert(orderStatusEvents).values({
        orderId,
        fromStatus: current.status,
        toStatus: to,
        actor,
      })
      return this.readOrder(tx, orderId)
    })
  }

  private async findByKey (
    db: OrderDb,
    customerId: string,
    idempotencyKey: string,
  ): Promise<OrderRow | undefined> {
    const [row] = await db
      .select()
      .from(orders)
      .where(
        and(
          eq(orders.customerId, customerId),
          eq(orders.idempotencyKey, idempotencyKey),
        ),
      )
    return row
  }

  private async replay (
    db: OrderDb,
    row: OrderRow,
    hash: string,
    customerId: string,
  ): Promise<PlaceResult> {
    if (row.idempotencyBodyHash !== hash) {
      throw new DomainError(
        'IDEMPOTENCY_CONFLICT',
        'Idempotency key was already used with a different request',
      )
    }
    return {
      created: false,
      order: await this.readOrder(db, row.id, customerId),
    }
  }

  private async price (
    db: OrderDb,
    body: { restaurantId: string; items: OrderItemRequest[] },
    now: Date,
  ) {
    if (body.items.length === 0) return priceOrder(body, null, [])

    const [restaurant] = await db
      .select()
      .from(restaurants)
      .where(eq(restaurants.id, body.restaurantId))
    const hours = restaurant
      ? await db
          .select()
          .from(openingHours)
          .where(eq(openingHours.restaurantId, restaurant.id))
      : []
    const catalog = await db
      .select()
      .from(menuItems)
      .where(
        inArray(
          menuItems.id,
          body.items.map((item) => item.menuItemId),
        ),
      )

    return priceOrder(
      body,
      restaurant
        ? {
            id: restaurant.id,
            name: restaurant.name,
            minOrderAgorot: restaurant.minOrderAgorot,
            deliveryFeeAgorot: restaurant.deliveryFeeAgorot,
            isOpen: isOpenNow(restaurant, hours, now),
          }
        : null,
      catalog,
    )
  }

  private async readOrder (
    db: OrderDb,
    orderId: string,
    customerId?: string,
  ): Promise<OrderResponse> {
    const filters = [eq(orders.id, orderId)]
    if (customerId !== undefined) {
      filters.push(eq(orders.customerId, customerId))
    }
    const [order] = await db
      .select()
      .from(orders)
      .where(and(...filters))
    if (!order) throw new DomainError('NOT_FOUND', 'Order not found')

    const items = await db
      .select()
      .from(orderItems)
      .where(eq(orderItems.orderId, orderId))
      .orderBy(asc(orderItems.name), asc(orderItems.id))
    const events = await db
      .select()
      .from(orderStatusEvents)
      .where(eq(orderStatusEvents.orderId, orderId))
      .orderBy(asc(orderStatusEvents.createdAt), asc(orderStatusEvents.id))
    return toOrderResponse(order, items, events)
  }
}

function isIdempotencyRace (error: unknown): boolean {
  const seen = new Set<unknown>()
  let current: unknown = error
  while (current && typeof current === 'object' && !seen.has(current)) {
    seen.add(current)
    const record = current as {
      code?: unknown
      constraint?: unknown
      message?: unknown
      cause?: unknown
    }
    if (record.code === '23505') {
      const message = typeof record.message === 'string' ? record.message : ''
      if (
        record.constraint === IDEMPOTENCY_CONSTRAINT ||
        message.includes(IDEMPOTENCY_CONSTRAINT)
      ) {
        return true
      }
    }
    current = record.cause
  }
  return false
}
