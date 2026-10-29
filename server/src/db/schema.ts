import { sql } from 'drizzle-orm'
import {
  bigserial,
  boolean,
  check,
  foreignKey,
  index,
  integer,
  pgEnum,
  pgTable,
  primaryKey,
  smallint,
  text,
  time,
  timestamp,
  unique,
  uuid,
} from 'drizzle-orm/pg-core'

export const DIETARY_TAGS = [
  'vegetarian',
  'vegan',
  'spicy',
  'gluten_free',
  'dairy_free',
  'contains_nuts',
] as const

export type DietaryTag = (typeof DIETARY_TAGS)[number]

const dietaryTagList = sql.raw(`ARRAY['${DIETARY_TAGS.join("', '")}']::text[]`)

export const orderStatus = pgEnum('order_status', [
  'PLACED',
  'ACCEPTED',
  'PREPARING',
  'PICKED_UP',
  'DELIVERED',
  'CANCELLED',
])

const createdAt = () =>
  timestamp('created_at', { withTimezone: true, mode: 'date' })
    .notNull()
    .defaultNow()

const updatedAt = () =>
  timestamp('updated_at', { withTimezone: true, mode: 'date' })
    .notNull()
    .defaultNow()

export const customers = pgTable('customers', {
  id: uuid('id').primaryKey().defaultRandom(),
  phone: text('phone').notNull().unique(),
  createdAt: createdAt(),
})

export const otpChallenges = pgTable(
  'otp_challenges',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    phone: text('phone').notNull(),
    codeHash: text('code_hash').notNull(),
    expiresAt: timestamp('expires_at', {
      withTimezone: true,
      mode: 'date',
    }).notNull(),
    attempts: integer('attempts').notNull().default(0),
    consumedAt: timestamp('consumed_at', { withTimezone: true, mode: 'date' }),
    createdAt: createdAt(),
  },
  (table) => [
    check('otp_challenges_attempts_non_negative', sql`${table.attempts} >= 0`),
    index('otp_challenges_phone_created_idx').on(
      table.phone,
      table.createdAt.desc(),
    ),
  ],
)

export const restaurants = pgTable(
  'restaurants',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    name: text('name').notNull(),
    cuisine: text('cuisine').notNull(),
    address: text('address').notNull(),
    timezone: text('timezone').notNull().default('Asia/Jerusalem'),
    isAcceptingOrders: boolean('is_accepting_orders').notNull().default(true),
    minOrderAgorot: integer('min_order_agorot').notNull(),
    deliveryFeeAgorot: integer('delivery_fee_agorot').notNull(),
    createdAt: createdAt(),
  },
  (table) => [
    check(
      'restaurants_min_order_non_negative',
      sql`${table.minOrderAgorot} >= 0`,
    ),
    check(
      'restaurants_delivery_fee_non_negative',
      sql`${table.deliveryFeeAgorot} >= 0`,
    ),
  ],
)

export const openingHours = pgTable(
  'opening_hours',
  {
    restaurantId: uuid('restaurant_id')
      .notNull()
      .references(() => restaurants.id, { onDelete: 'cascade' }),
    dayOfWeek: smallint('day_of_week').notNull(),
    opensAt: time('opens_at').notNull(),
    closesAt: time('closes_at').notNull(),
  },
  (table) => [
    primaryKey({
      columns: [table.restaurantId, table.dayOfWeek, table.opensAt],
    }),
    check(
      'opening_hours_day_of_week_range',
      sql`${table.dayOfWeek} between 0 and 6`,
    ),
  ],
)

export const menuCategories = pgTable(
  'menu_categories',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    restaurantId: uuid('restaurant_id')
      .notNull()
      .references(() => restaurants.id, { onDelete: 'cascade' }),
    name: text('name').notNull(),
    sortOrder: integer('sort_order').notNull(),
  },
  (table) => [
    unique('menu_categories_restaurant_name_uq').on(
      table.restaurantId,
      table.name,
    ),
    unique('menu_categories_id_restaurant_uq').on(table.id, table.restaurantId),
  ],
)

export const menuItems = pgTable(
  'menu_items',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    restaurantId: uuid('restaurant_id')
      .notNull()
      .references(() => restaurants.id, { onDelete: 'cascade' }),
    categoryId: uuid('category_id').notNull(),
    name: text('name').notNull(),
    description: text('description').notNull().default(''),
    priceAgorot: integer('price_agorot').notNull(),
    dietaryTags: text('dietary_tags')
      .array()
      .notNull()
      .default(sql`'{}'::text[]`),
    isAvailable: boolean('is_available').notNull().default(true),
    createdAt: createdAt(),
    updatedAt: updatedAt(),
  },
  (table) => [
    // NO ACTION so a restaurant delete can cascade items and categories in one
    // statement. RESTRICT would reject that delete if categories went first.
    foreignKey({
      name: 'menu_items_category_restaurant_fk',
      columns: [table.categoryId, table.restaurantId],
      foreignColumns: [menuCategories.id, menuCategories.restaurantId],
    }).onDelete('no action'),
    check('menu_items_price_positive', sql`${table.priceAgorot} > 0`),
    check(
      'menu_items_dietary_tags_known',
      sql`${table.dietaryTags} <@ ${dietaryTagList}`,
    ),
    index('menu_items_restaurant_category_idx').on(
      table.restaurantId,
      table.categoryId,
    ),
    index('menu_items_search_idx').using(
      'gin',
      sql`to_tsvector('simple', ${table.name} || ' ' || ${table.description})`,
    ),
    index('menu_items_dietary_tags_idx').using('gin', table.dietaryTags),
  ],
)

export const orders = pgTable(
  'orders',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    customerId: uuid('customer_id')
      .notNull()
      .references(() => customers.id, { onDelete: 'restrict' }),
    restaurantId: uuid('restaurant_id')
      .notNull()
      .references(() => restaurants.id, { onDelete: 'restrict' }),
    status: orderStatus('status').notNull().default('PLACED'),
    subtotalAgorot: integer('subtotal_agorot').notNull(),
    deliveryFeeAgorot: integer('delivery_fee_agorot').notNull(),
    totalAgorot: integer('total_agorot').notNull(),
    restaurantName: text('restaurant_name').notNull(),
    idempotencyKey: text('idempotency_key').notNull(),
    idempotencyBodyHash: text('idempotency_body_hash').notNull(),
    createdAt: createdAt(),
    updatedAt: updatedAt(),
  },
  (table) => [
    check('orders_subtotal_positive', sql`${table.subtotalAgorot} > 0`),
    check(
      'orders_delivery_fee_non_negative',
      sql`${table.deliveryFeeAgorot} >= 0`,
    ),
    check(
      'orders_total_is_subtotal_plus_fee',
      sql`${table.totalAgorot} = ${table.subtotalAgorot} + ${table.deliveryFeeAgorot}`,
    ),
    unique('orders_customer_idempotency_uq').on(
      table.customerId,
      table.idempotencyKey,
    ),
    index('orders_customer_created_idx').on(
      table.customerId,
      table.createdAt.desc(),
    ),
  ],
)

export const orderItems = pgTable(
  'order_items',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    orderId: uuid('order_id')
      .notNull()
      .references(() => orders.id, { onDelete: 'cascade' }),
    menuItemId: uuid('menu_item_id').references(() => menuItems.id, {
      onDelete: 'set null',
    }),
    name: text('name').notNull(),
    unitPriceAgorot: integer('unit_price_agorot').notNull(),
    quantity: integer('quantity').notNull(),
    lineTotalAgorot: integer('line_total_agorot').notNull(),
  },
  (table) => [
    check('order_items_unit_price_positive', sql`${table.unitPriceAgorot} > 0`),
    check(
      'order_items_quantity_range',
      sql`${table.quantity} between 1 and 50`,
    ),
    check(
      'order_items_line_total',
      sql`${table.lineTotalAgorot} = ${table.unitPriceAgorot} * ${table.quantity}`,
    ),
    index('order_items_order_idx').on(table.orderId),
  ],
)

export const orderStatusEvents = pgTable(
  'order_status_events',
  {
    id: bigserial('id', { mode: 'number' }).primaryKey(),
    orderId: uuid('order_id')
      .notNull()
      .references(() => orders.id, { onDelete: 'cascade' }),
    fromStatus: orderStatus('from_status'),
    toStatus: orderStatus('to_status').notNull(),
    actor: text('actor').notNull(),
    createdAt: createdAt(),
  },
  (table) => [
    check(
      'order_status_events_actor_known',
      sql`${table.actor} in ('customer', 'restaurant', 'courier', 'system')`,
    ),
    index('order_status_events_order_created_idx').on(
      table.orderId,
      table.createdAt,
    ),
  ],
)

export type CustomerRow = typeof customers.$inferSelect
export type OtpChallengeRow = typeof otpChallenges.$inferSelect
export type RestaurantRow = typeof restaurants.$inferSelect
export type OpeningHourRow = typeof openingHours.$inferSelect
export type MenuCategoryRow = typeof menuCategories.$inferSelect
export type MenuItemRow = typeof menuItems.$inferSelect
export type OrderRow = typeof orders.$inferSelect
export type OrderItemRow = typeof orderItems.$inferSelect
export type OrderStatusEventRow = typeof orderStatusEvents.$inferSelect
