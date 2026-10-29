# API and data contract

Single source of truth shared by `server/` and `mobile/`. Change it in its own commit before changing either side.

## Conventions

- Base URL: `http://localhost:3000/api`. JSON only. Field names are camelCase.
- IDs are UUID v4 strings.
- Money is an integer number of agorot (`4200` = 42.00 ₪). Fields end in `Agorot`. No floats anywhere.
- Timestamps are ISO-8601 UTC strings.
- Auth: `Authorization: Bearer <accessToken>` (JWT, HS256, `sub` = customer id, 7-day expiry). Required on `/orders` (except the status update) and `/dish-finder`. Public: `/auth/*`, `/restaurants*`, `/health`.
- Error envelope for every non-2xx response:

```json
{ "error": { "code": "BELOW_MINIMUM", "message": "Human readable", "details": {} } }
```

Error codes are a closed set: `VALIDATION_FAILED` (400), `UNAUTHORIZED` (401), `NOT_FOUND` (404), `INVALID_TRANSITION` (409), `CONCURRENT_UPDATE` (409), `IDEMPOTENCY_CONFLICT` (409), `RESTAURANT_CLOSED` (422), `ITEM_UNAVAILABLE` (422), `ITEM_NOT_IN_RESTAURANT` (422), `BELOW_MINIMUM` (422), `OTP_INVALID` (401), `OTP_EXPIRED` (401), `OTP_TOO_MANY_ATTEMPTS` (429), `INTERNAL` (500).

## Schema (PostgreSQL)

```text
customers          id uuid pk, phone text unique not null (E.164), created_at
otp_challenges     id uuid pk, phone text not null, code_hash text not null, expires_at, attempts int default 0 check (attempts >= 0),
                   consumed_at null, created_at
                   index (phone, created_at desc)
restaurants        id uuid pk, name text not null, cuisine text not null, address text not null,
                   timezone text not null default 'Asia/Jerusalem',
                   is_accepting_orders bool not null default true,       -- manual open/closed switch
                   min_order_agorot int not null check (>= 0), delivery_fee_agorot int not null check (>= 0), created_at
opening_hours      restaurant_id fk -> restaurants on delete cascade, day_of_week smallint check (0..6, 0 = Sunday),
                   opens_at time not null, closes_at time not null      -- closes_at < opens_at means it closes after midnight
                   pk (restaurant_id, day_of_week, opens_at)
menu_categories    id uuid pk, restaurant_id fk on delete cascade, name text not null, sort_order int not null,
                   unique (restaurant_id, name)
menu_items         id uuid pk, restaurant_id fk on delete cascade, category_id fk -> menu_categories,
                   name text not null, description text not null default '', price_agorot int not null check (> 0),
                   dietary_tags text[] not null default '{}'  -- subset of DietaryTag
                   is_available bool not null default true, created_at, updated_at
                   index (restaurant_id, category_id); GIN index on to_tsvector('simple', name || ' ' || description); GIN on dietary_tags
orders             id uuid pk, customer_id fk -> customers, restaurant_id fk -> restaurants,
                   status order_status not null default 'PLACED',
                   subtotal_agorot int not null check (> 0), delivery_fee_agorot int not null check (>= 0),
                   total_agorot int not null, check (total_agorot = subtotal_agorot + delivery_fee_agorot),
                   restaurant_name text not null,                       -- snapshot
                   idempotency_key text not null, unique (customer_id, idempotency_key),
                   created_at, updated_at
                   index (customer_id, created_at desc)
order_items        id uuid pk, order_id fk on delete cascade, menu_item_id fk -> menu_items on delete set null,
                   name text not null, unit_price_agorot int not null check (> 0),   -- snapshots
                   quantity int not null check (quantity between 1 and 50),
                   line_total_agorot int not null, check (line_total_agorot = unit_price_agorot * quantity)
                   index (order_id)
order_status_events id bigserial pk, order_id fk on delete cascade, from_status order_status null, to_status order_status not null,
                   actor text not null check (actor in ('customer','restaurant','courier','system')), created_at
                   index (order_id, created_at)
```

`order_status` is a Postgres enum: `PLACED, ACCEPTED, PREPARING, PICKED_UP, DELIVERED, CANCELLED`.

`DietaryTag` closed set: `vegetarian, vegan, spicy, gluten_free, dairy_free, contains_nuts`.

**Open now** = `is_accepting_orders AND` the current local time (restaurant timezone) falls in an `opening_hours` row for today, or in yesterday's row that runs past midnight. Computed in SQL or the service, never stored.

## Order lifecycle

Transitions and the actor allowed to make them. Everything else is `INVALID_TRANSITION`. `DELIVERED` and `CANCELLED` are terminal.

| from | to | actors |
| --- | --- | --- |
| (create) | PLACED | customer |
| PLACED | ACCEPTED | restaurant |
| PLACED | CANCELLED | customer, restaurant |
| ACCEPTED | PREPARING | restaurant |
| ACCEPTED | CANCELLED | restaurant |
| PREPARING | PICKED_UP | courier |
| PICKED_UP | DELIVERED | courier |

The update is a compare-and-set: `UPDATE orders SET status = :to WHERE id = :id AND status = :from`. Zero rows after a successful read means `CONCURRENT_UPDATE`. Each transition inserts an `order_status_events` row in the same transaction.

## Endpoints

### `GET /health` → `200 { "status": "ok" }`

### `POST /auth/otp/request`

Body `{ "phone": "+972501234567" }` (E.164, validated). Creates an `otp_challenges` row with a 6-digit code, hashed, 5-minute expiry. Max 5 verify attempts per challenge.
`202 { "expiresInSeconds": 300, "devCode": "123456" }`. `devCode` appears only when `OTP_DEV_MODE=true` (default in docker compose). With dev mode on, the code is always `123456`, so demos and tests are deterministic. No SMS provider is wired.

### `POST /auth/otp/verify`

Body `{ "phone": "...", "code": "123456" }`. Upserts the customer by phone and consumes the challenge.
`200 { "accessToken": "jwt", "customer": { "id": "uuid", "phone": "+972..." } }`. Errors: `OTP_INVALID`, `OTP_EXPIRED`, `OTP_TOO_MANY_ATTEMPTS`.

### `GET /restaurants`

`200 { "restaurants": Restaurant[] }`, open restaurants first, then by name.

```ts
type Restaurant = {
  id: string; name: string; cuisine: string; address: string;
  isOpen: boolean;                       // "open now" as defined above
  openingHours: { dayOfWeek: number; opensAt: "HH:mm"; closesAt: "HH:mm" }[];
  minOrderAgorot: number; deliveryFeeAgorot: number;
};
```

### `GET /restaurants/:id/menu`

`200 { "restaurant": Restaurant, "categories": MenuCategory[] }`. Categories in `sort_order`; items by name. Unavailable items are included with `isAvailable: false`. `404 NOT_FOUND` for an unknown id.

```ts
type MenuCategory = { id: string; name: string; items: MenuItem[] };
type MenuItem = {
  id: string; restaurantId: string; categoryId: string; name: string; description: string;
  priceAgorot: number; dietaryTags: DietaryTag[]; isAvailable: boolean;
};
```

### `POST /orders` (auth)

Header `Idempotency-Key: <client-generated uuid>` (required). Body:

```json
{ "restaurantId": "uuid", "items": [{ "menuItemId": "uuid", "quantity": 2 }] }
```

Rules, checked in this order inside one transaction:
1. `items` has 1..50 entries, quantities are 1..50, and `menuItemId`s are unique. Otherwise `VALIDATION_FAILED`.
2. Restaurant exists (`NOT_FOUND`) and is open now (`RESTAURANT_CLOSED`).
3. Every item belongs to the restaurant (`ITEM_NOT_IN_RESTAURANT`, `details.menuItemIds`) and is available (`ITEM_UNAVAILABLE`, `details.menuItemIds`).
4. Subtotal is at least the minimum. Otherwise `BELOW_MINIMUM`, `details: { minOrderAgorot, subtotalAgorot }`.
5. Prices come from the database, never from the client. Names and prices are snapshotted into `order_items`.

The same `(customer, Idempotency-Key)` with the same body returns the original order with `200`. A different body returns `IDEMPOTENCY_CONFLICT`. A new order returns `201 Order`.

### `GET /orders/:id` (auth)

`200 Order`. Another customer's order returns `404` so that order IDs don't leak.

```ts
type OrderStatus = "PLACED" | "ACCEPTED" | "PREPARING" | "PICKED_UP" | "DELIVERED" | "CANCELLED";
type Order = {
  id: string; status: OrderStatus;
  restaurant: { id: string; name: string };            // name is the snapshot
  items: { menuItemId: string | null; name: string; unitPriceAgorot: number; quantity: number; lineTotalAgorot: number }[];
  subtotalAgorot: number; deliveryFeeAgorot: number; totalAgorot: number;
  statusHistory: { from: OrderStatus | null; to: OrderStatus; actor: Actor; at: string }[];
  createdAt: string; updatedAt: string;
};
type Actor = "customer" | "restaurant" | "courier" | "system";
```

### `PATCH /orders/:id/status`

This is the restaurant and courier integration. It has no customer auth, and production would put staff auth or service tokens on it (see README).
Body `{ "status": OrderStatus, "actor": Actor }` → `200 Order`. Errors: `NOT_FOUND`, `INVALID_TRANSITION` (`details: { from, to, actor }`), `CONCURRENT_UPDATE`.

### `POST /dish-finder/search` (auth)

The client keeps the session history and sends the whole conversation every turn, so the server stays stateless.

```json
{ "messages": [ { "role": "user", "content": "something spicy with chicken under 60" },
                { "role": "assistant", "content": "..." },
                { "role": "user", "content": "cheaper ones?" } ] }
```

At most 20 messages of at most 500 characters each, and the last message has role `user`.

```ts
type DishFinderResponse = {
  reply: string;                         // short, friendly, never names a dish that isn't in results
  results: DishResult[];                 // max 10, ranked
  intent: SearchIntent;                  // what the server understood; shown for transparency and debugging
  relaxed: string[];                     // constraints dropped to find close alternatives, e.g. ["maxPriceAgorot"]; empty when exact
};
type DishResult = {
  menuItem: MenuItem;
  restaurant: { id: string; name: string; cuisine: string; isOpen: boolean };
  orderable: boolean;                    // menuItem.isAvailable && restaurant.isOpen
};
type SearchIntent = {
  keywords: string[]; excludeKeywords: string[];
  cuisines: string[];
  includeTags: DietaryTag[]; excludeTags: DietaryTag[];
  maxPriceAgorot: number | null;
  openNowOnly: boolean;
  sort: "relevance" | "price_asc";
};
```

Results only ever come from a SQL query over `menu_items` joined to `restaurants`. The model (when configured) only turns the conversation into a `SearchIntent`. A deterministic parser does the same with no API key. Non-orderable results are included but marked and ranked last, unless `openNowOnly` is set, which excludes closed restaurants.
