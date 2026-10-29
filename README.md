# Food delivery take-home

A thin slice of a food delivery marketplace for LevelApp. A NestJS + PostgreSQL API serves restaurants, menus, OTP login, orders with a server-enforced lifecycle, and a dish finder chat. A Flutter app runs the customer journey on top of it: log in, browse, build a one-restaurant cart, place an order, watch it move to Delivered, or ask the dish finder for "spicy chicken under 60 ₪" and add a result straight to the cart.

`docs/CONTRACT.md` is the API and schema contract both sides were built against.

## Demo

The app on an Android phone against `docker compose up`. It shows OTP login, browsing, the dish finder with a "cheaper ones?" follow-up, the cart minimum, and an order polled through to Delivered.

https://github.com/user-attachments/assets/4c590e78-564f-4bde-96d0-12ee8130e47d

## Run it

### Backend

```sh
docker compose up --build
```

The API listens on `http://localhost:3000/api`. Set `API_PORT` to publish it elsewhere. Postgres is not published to the host. On start the API container runs the migrations, then the seed, then Nest (`server/docker-entrypoint.sh`). The seed is idempotent, so restarts don't duplicate rows. `docker compose down -v` resets the database.

Compose sets `OTP_DEV_MODE=true`. In dev mode every OTP code is `123456` and `POST /auth/otp/request` returns it as `devCode`. With dev mode off the code is random and `devCode` is omitted. No SMS provider is wired.

Seed: five restaurants, ten dishes each, in Starters, Mains and Drinks.

| Restaurant | Cuisine | Min order | Delivery fee | Notes |
| --- | --- | --- | --- | --- |
| Alei Gefen | Vegan | ₪45 | ₪12 | |
| HaTachana Grill | Grill | ₪55 | ₪18 | spicy chicken dishes either side of ₪60 |
| Sushi Yama | Japanese | ₪70 | ₪20 | |
| Trattoria HaYarkon | Italian | ₪49 | ₪15 | `White truffle tagliatelle` is out of stock |
| Falafel HaShuk | Israeli | ₪30 | ₪8 | closed by its manual switch |

Every restaurant's hours cover all 24 hours in two windows that meet at midnight. So Falafel HaShuk is the only closed restaurant at any time of day, and a reviewer at 3am sees the same app as one at noon.

Get a token without the app:

```sh
curl -s localhost:3000/api/auth/otp/request -H 'content-type: application/json' -d '{"phone":"+972501234567"}'
curl -s localhost:3000/api/auth/otp/verify -H 'content-type: application/json' -d '{"phone":"+972501234567","code":"123456"}'
```

Or mint one inside the container, which upserts the customer by phone:

```sh
docker compose exec api node dist/auth/print-token.js +972501234567
```

`server/scripts/demo-otp.sh` requests and verifies a code. `server/scripts/demo-order-flow.sh` places an order and walks it to `DELIVERED`. `server/scripts/demo-dish-finder.sh` runs the example conversations.

### Mobile

```sh
cd mobile
flutter pub get
dart run build_runner build -d
flutter run
```

The default base URL is `http://localhost:3000/api` on iOS and `http://10.0.2.2:3000/api` on the Android emulator, where `10.0.2.2` is the emulator's alias for the host. Both live in `mobile/lib/data/api_base_url.dart`. Override it with `--dart-define=API_BASE_URL=http://<host>:<port>/api`. On a USB Android device, run `adb reverse tcp:3000 tcp:3000` and use `localhost`.

Log in with any Israeli mobile number, for example `050-123-4567`. Debug builds show "Dev code: 123456" and fill it in.

## Tests

| Suite | Command, from the folder shown |
| --- | --- |
| Server unit | `server/`: `npm test` |
| Server e2e | `server/`: `npm run test:e2e`. Needs Docker. Testcontainers starts a throwaway Postgres per run on a random port. |
| Mobile unit and widget | `mobile/`: `flutter test` |
| Mobile e2e, Patrol | `mobile/`: `tool/e2e.sh --port 3000 --target patrol_test/catalog_test.dart` against a running `docker compose` stack |

All three Patrol journeys, catalog, checkout, and login with the dish finder chat, pass on a OnePlus 7 Pro running Android 16 against the `docker compose` backend.

Lint and build: `npm run lint && npm run build` in `server/`, `dart format . && flutter analyze` in `mobile/`. Run `dart run build_runner build -d` after changing any freezed, json_serializable or Riverpod source.

Run Patrol only through `tool/e2e.sh`. It takes `--port`, `--target` and `--device`. It prefers a USB-attached Android device and `adb reverse`s the API port. Otherwise it uses a running emulator, or boots the `Pixel_10_Pro` AVD, and points the app at `10.0.2.2`. Without `--port` or `API_PORT` it assumes port 3101. It holds a lock at `/tmp/fda-e2e.lock` so parallel runs queue for the one device. `patrol_test/checkout_test.dart` needs `E2E_ACCESS_TOKEN=<jwt>` in the environment, minted with the `print-token` command above.

## Architecture

```text
server/   NestJS 11, TypeScript strict, Drizzle ORM over pg
mobile/   Flutter, Riverpod 3 codegen, freezed, go_router, http
docs/     CONTRACT.md
```

### Server

One folder per feature under `server/src/`. Each has its module, controller, service, DTOs and colocated `*.spec.ts`.

- `config/env.ts` parses the environment once with zod at boot. A bad env stops the process.
- `common/` holds `DomainError`, which carries one of the contract's closed error codes and derives the HTTP status from the code. `AllExceptionsFilter` turns every error into the contract envelope `{ error: { code, message, details } }`. The global `ValidationPipe` runs with `whitelist` and `forbidNonWhitelisted`, so a client that sends `priceAgorot` gets a 400.
- `db/` has `schema.ts`, the single schema source, plus `migrate.ts` and `seed.ts`.
- `restaurants/` serves the list and the menu. `is-open-now.ts` is the one place that decides open or closed.
- `auth/` has OTP request and verify, `TokenService`, `JwtAuthGuard` and the `@CurrentCustomer()` decorator.
- `orders/` has `price-order.ts`, a pure function that validates and prices an order before anything is written, `order-lifecycle.ts` with the transition table, and the service that persists both.
- `dish-finder/` has the intent extractors, the SQL search, the relaxation planner and the reply composer.

Queries use Drizzle's SQL-like builder, `db.select().from().where()`, so each one maps to a SQL statement you can read. The relational `db.query` API is not used.

### Mobile

`mobile/lib/` has five layers.

- `domain/` holds plain Dart models, the sealed `ApiResult` (`ApiOk` or `ApiFailure`), the typed `ApiError`, phone normalization, and repository ports. It imports neither Flutter nor `http`. `test/domain_posture_test.dart` enforces that.
- `application/` holds the Riverpod notifiers: `AuthSession`, `Login`, `Cart`, `Checkout`, `OrderTracker`, `DishFinderChat`, the restaurant list and the menu.
- `data/` holds `ApiClient`, the HTTP adapters for each port, the DTOs and the session store. All HTTP goes through `ApiClient`. It returns `ApiResult` and maps the error envelope to an `ApiError` with its code.
- `presentation/` holds the screens, the router and money formatting. Money is an `int` of agorot until a widget formats it.
- `app/bootstrap.dart` is the composition root. It binds the ports to real adapters. Tests bind fakes at the same providers.

The router's redirect sends a signed-out user to `/login`. A 401 for the current token clears the session, and the router follows.

## Data model

All of it is in `server/src/db/schema.ts`. `drizzle-kit generate` turned that into `server/drizzle/0000_initial.sql`, which the API applies on boot. Read that file for the exact DDL. The parts that matter:

- **Money is integer agorot.** Every money column is `integer` and ends in `_agorot`. `4200` is ₪42.00. There is no float anywhere, so `CHECK (total_agorot = subtotal_agorot + delivery_fee_agorot)` and `CHECK (line_total_agorot = unit_price_agorot * quantity)` hold exactly. Prices must be positive, fees and minimums non-negative.
- **`restaurants`** carries `timezone` and `is_accepting_orders`, the manual switch. "Open now" is never stored. It is the switch plus the current local time falling in an `opening_hours` row for today, or in yesterday's row that runs past midnight.
- **`opening_hours`** is keyed on `(restaurant_id, day_of_week, opens_at)`, so a day can have several windows. `closes_at < opens_at` means the window ends after midnight. `day_of_week` is checked to `0..6`, Sunday first.
- **`menu_categories`** has `unique (restaurant_id, name)` and `unique (id, restaurant_id)`. The second one exists only as the target of a composite foreign key.
- **`menu_items`** references its category through `(category_id, restaurant_id) -> menu_categories (id, restaurant_id)`. A dish can't be filed under another restaurant's category, and the database enforces it. `dietary_tags` is `text[]` with a check that every tag is in the closed set. Indexes: `(restaurant_id, category_id)` for the menu, GIN on `dietary_tags`, and a GIN `tsvector` index on name and description.
- **`orders`** snapshots `restaurant_name`. `unique (customer_id, idempotency_key)` makes a retried POST unable to create a second row. `idempotency_body_hash` is the sha256 of the normalized body: `restaurantId` plus items sorted by `menuItemId`, UUIDs lowercased. The same key with a different body is a conflict, not a replay. FKs to `customers` and `restaurants` are `restrict`, so order history can't be deleted out from under you. Index `(customer_id, created_at desc)` is there for an order history list.
- **`order_items`** snapshots `name` and `unit_price_agorot`. Its `menu_item_id` is `on delete set null`, so deleting a dish keeps old orders intact. Quantity is checked to `1..50`.
- **`order_status_events`** is an append-only log: `from_status`, `to_status`, `actor`, `created_at`, indexed on `(order_id, created_at)`. Every transition, including the initial PLACED, writes a row in the same transaction as the status change. `GET /orders/:id` returns it as `statusHistory`.
- **`otp_challenges`** stores an HMAC-SHA256 of the code keyed with `JWT_SECRET`, never the code. It has `expires_at`, `attempts >= 0` and `consumed_at`. Index `(phone, created_at desc)` serves both "latest challenge for this phone" and the rate-limit count.
- **`customers`** is `phone` unique, E.164. Verify upserts on it.

`order_status` is a Postgres enum. Restaurant-owned rows cascade on restaurant delete.

## Order lifecycle

`server/src/orders/order-lifecycle.ts` holds the table. Anything not in it is `409 INVALID_TRANSITION` with `{ from, to, actor }`.

| From | To | Allowed actors |
| --- | --- | --- |
| (create) | PLACED | customer |
| PLACED | ACCEPTED | restaurant |
| PLACED | CANCELLED | customer, restaurant |
| ACCEPTED | PREPARING | restaurant |
| ACCEPTED | CANCELLED | restaurant |
| PREPARING | PICKED_UP | courier |
| PICKED_UP | DELIVERED | courier |

`DELIVERED` and `CANCELLED` are terminal. A customer can cancel only before the restaurant accepts. After that, food is being made, and cancelling becomes a support conversation.

`PATCH /orders/:id/status` reads the order, checks the table, then runs a compare-and-set: `UPDATE orders SET status = :to WHERE id = :id AND status = :from`. Zero rows means someone else moved the order between the read and the write, and the caller gets `409 CONCURRENT_UPDATE`. The event row is inserted in the same transaction. I chose CAS over `SELECT ... FOR UPDATE` because it needs no lock held across the check and gives the losing caller a clear error.

`POST /orders` checks, in this order inside one transaction: shape, restaurant exists, restaurant open, every item belongs to that restaurant, every item available, subtotal meets the minimum. Prices and names come from the database. Then it inserts the order, its items and the PLACED event. A replay with the same `Idempotency-Key` and body returns the original order with 200. Two concurrent creates with one key race on the unique constraint. The loser catches the violation, rolls back, reads the winner, and returns it if the body hash matches. The idempotency lookup runs before the open-now check, so a retry that arrives after the restaurant closes still returns the order that was placed.

`GET /orders/:id` looks the order up by id and customer in one query. Another customer's order and an id that doesn't exist both end in the same `NOT_FOUND` error with the same body, so the response can't confirm that someone else's order exists.

The status endpoint has no auth, per the contract. It stands in for the restaurant and courier integrations.

## Dish finder

`POST /dish-finder/search` is stateless. The app sends the whole conversation every turn, at most 20 messages of 500 characters, and the server stores nothing.

A rule parser folds the user turns into a `SearchIntent`: keywords, excluded words, dietary tags to include and exclude, cuisines loaded from the database, a price ceiling in agorot, open-now, and sort. "Under 60" is an inclusive ceiling of 6000. A turn that says "actually" or "never mind" starts over. Dietary words become tags, so "spicy chicken" is keyword `chicken` plus tag `spicy`.

With `ANTHROPIC_API_KEY` or `OPENAI_API_KEY` set, the conversation goes to that API as a single tool call that returns the same `SearchIntent`. Anthropic wins if both are set. The model sees the cuisine and tag lists, never the menu or prices. Zod validates its output. A timeout after 5 seconds, bad JSON or a schema miss falls back to the rules. Without a key the rules run alone, and every example in the brief works that way.

Search is one SQL query over menu items joined to categories and restaurants. Keywords match dish name, description, category, cuisine and restaurant name, which is how "sushi" finds Sushi Yama's rolls. Tags, excluded words, price and cuisine are filters. Orderable dishes rank first, then by price or relevance, then name. At most 10 rows.

Unavailable dishes and closed restaurants are included, marked `orderable: false`, and ranked last. A user who asks for a dish should learn it exists and why they can't order it, instead of getting "nothing found". "Open now" is the exception. When the user asks for it, closed restaurants are dropped.

If nothing matches, the server relaxes one constraint at a time in a fixed order: price ceiling, excluded words, required tags, cuisine, then narrowing to the longest keyword. It stops at the first step that returns rows and reports what it dropped in `relaxed`. The app labels those results "Close matches".

"Cheaper ones?" sorts by price and sets the ceiling one agora under the cheapest dish from the previous turn. On that turn the price ceiling is never relaxed, because returning a pricier dish to "cheaper ones?" is wrong. The other constraints still relax, and the reply says so: "No spicy chicken dishes cheaper than ₪48, but here are close alternatives." If nothing at all is under the ceiling, the reply ends with "Those were the cheapest."

The reply is a template built from the result rows: a count and the restated filters, like "Found 2 spicy chicken dishes under ₪60." A full page of 10 reads "Here are 10 vegan dishes.", because 10 is the cap, not the total. It never names a dish. Results only ever come from the SQL query, and the model only produces search parameters, so the bot has no path to invent a dish, a price or a restaurant.

I picked intent extraction over letting a model answer from a menu dump because the dump can hallucinate, costs tokens per turn, and grows with the catalog. Embeddings are overkill for 50 dishes.

## Key decisions

- **One repo over two.** The contract changes in the same commit as the server and the app that implement it.
- **Drizzle over Prisma, TypeORM and Kysely.** One `schema.ts` produces both the types and the DDL, and the builder maps one to one onto SQL. Prisma hides SQL behind its engine and makes a compare-and-set update clumsy. TypeORM's SQL is opaque and its null types are weak. Kysely's types are synced with migrations by hand.
- **Integer agorot over `numeric`.** `numeric` drags decimals into the JSON and into Dart. Integers keep the totals checks exact.
- **A transition table and compare-and-set over scattered status checks or `SELECT ... FOR UPDATE`.** Illegal moves are rejected in one place, and CAS holds no lock across the check.
- **Snapshotted names and prices over reading through to `menu_items`.** Reading through would rewrite past orders whenever the menu changes.
- **An `Idempotency-Key` on `POST /orders` over none.** Without it, a retry after a timeout places a second order.
- **A fixed dev OTP code over a real SMS provider.** Demos and tests are deterministic, and SMS is out of scope.
- **Intent, then SQL, then a template, over a model answering from a menu dump.** The dump lets the model name dishes that don't exist and costs tokens every turn. Embeddings are overkill for 50 dishes.
- **Showing unorderable dishes last over hiding them.** Hiding them makes a real dish look missing. An explicit "open now" still drops closed restaurants.
- **Testcontainers over a shared compose database for e2e.** Each run gets its own Postgres on a random port, so concurrent runs never share rows.
- **Riverpod 3 codegen, freezed and go_router over Bloc.** Bloc needs more boilerplate per feature. `go_router`'s redirect is the auth gate.
- **Polling every 3 seconds over SSE.** SSE adds a long-lived connection and reconnect logic to the app, too much for a 4-hour build. Production would push.
- **Test-first at fixed seams, with Patrol on Android, over `integration_test` or Patrol on iOS.** `integration_test` can't tap native dialogs. Patrol on iOS needs an extra `RunnerUITests` target in Xcode.

## Assumptions

- One currency, shekels, stored as agorot. One timezone per restaurant, `Asia/Jerusalem` for all seeded ones.
- The cart lives on the device and belongs to one restaurant. Adding a dish from another restaurant asks "Start a new cart?" before clearing it.
- The client generates one idempotency key per cart and keeps it until the cart changes, including across failed attempts. A new key after a timeout could double-order.
- The server accepts any E.164 phone. The app normalizes Israeli formats like `050-123-4567` and `+972 50 123 4567` before sending.
- OTP: codes expire after 5 minutes, a challenge allows 5 verify attempts, and a phone can request 3 codes per 10 minutes. A successful verify consumes every outstanding challenge for that phone.
- The status endpoint trusts the `actor` in the body. That's acceptable only because it stands in for authenticated integrations.
- Order status is polled every 3 seconds while the screen is open. A tick is skipped while the previous poll is still in flight, so a slow response can't paint an older status. Polling stops at a terminal status or when the screen closes.

## Edge cases handled

- **Out-of-stock dish.** The menu greys it out with no add button. If it goes out of stock after it's in the cart, the server returns `ITEM_UNAVAILABLE` with the ids and the cart offers "Remove unavailable items".
- **Closed restaurant.** The list marks it "Closed". Placing an order returns `RESTAURANT_CLOSED`.
- **Below the minimum.** The cart shows "Add ₪11.00 more to reach the ₪45.00 minimum" and disables Place order. The server enforces it too and returns both amounts in `details`.
- **Price tampering.** Unknown body fields are rejected. Prices always come from the database.
- **Menu changes after ordering.** Names and prices are snapshotted, so the order screen shows what was bought at the price paid.
- **Double tap and flaky networks.** A second tap while submitting is ignored. A retry after a network error or timeout reuses the idempotency key and gets the same order back.
- **Concurrent status updates.** Exactly one wins. The other gets `CONCURRENT_UPDATE` or `INVALID_TRANSITION`, depending on whether it read before or after the winner committed. An e2e test races two PATCHes and asserts exactly one wins.
- **Opening hours across midnight and time zones.** `isOpenNow` checks yesterday's overnight window and computes local time from the restaurant's timezone, DST included.
- **OTP abuse.** Wrong codes count toward the attempt cap. The request rate limit takes `pg_advisory_xact_lock(hashtext(phone))` first, so a parallel burst can't slip past the count. Codes are compared with `timingSafeEqual`.
- **Malformed or oversized bodies** return `400 VALIDATION_FAILED`, never `500`. Broken JSON gets the message "Malformed JSON body" instead of the parser's internals.
- **Expired or revoked session.** A 401 clears the stored session and the router returns to login. A late 401 for a token that was already replaced is ignored, so it can't sign out the new session.
- **Token for a deleted customer.** After `docker compose down -v`, an old JWT still verifies, but `POST /orders` returns 401 instead of a foreign-key 500.
- **Uppercase UUIDs.** The order DTO lowercases `restaurantId` and `menuItemId`, so the item lookup and the idempotency hash agree.
- **Lost connection on the order screen.** The last known status stays on screen with a reconnecting notice, and polling continues.
- **Dish finder with no match.** Relaxation finds close alternatives, labelled as such. With none, the reply says so plainly.

## Out of scope, and what production would add

- **Real SMS.** Twilio Verify or a local provider behind the existing code generator, `OTP_DEV_MODE` off, plus per-IP limits on top of the per-phone ones.
- **Staff auth on the status endpoint.** Service tokens for restaurants and couriers. The actor comes from the token, not the body, and a restaurant can only touch its own orders.
- **Push instead of polling.** SSE or a WebSocket while the order screen is open, FCM and APNs when it isn't. `order_status_events` already is the event log. An outbox table read by a worker would publish from it.
- **Payments.** An order starts as pending payment, the PSP authorizes on placement and captures on delivery, and the idempotency key is forwarded to the PSP so a retry can't charge twice.
- **Rate limiting at the edge.** A gateway or CDN limit per IP and per token, so abusive traffic never reaches Nest.
- **Observability.** Structured logs with a request id, OpenTelemetry traces through Nest and pg, and metrics on order transitions, `CONCURRENT_UPDATE` rate, and how often the dish finder falls back from the model to the rules.
- **Addresses and delivery zones.** PostGIS, a zone polygon per restaurant, and `ST_Contains` on the delivery point.
- **Courier assignment, ratings, admin panel.** Not started. Courier assignment would hang off the ACCEPTED event.
- **Search at scale.** Move keyword matching to the `tsvector` index or `pg_trgm`, and consider embeddings once menus grow past a few thousand dishes.

## Known gaps

These were still open at submission.

Server:

- The dish finder matches keywords with `ILIKE`, so the GIN `tsvector` index in the migration is unused. With 50 dishes a sequential scan is fine.
- Cuisines are loaded once at boot. A new cuisine needs a restart before the parser knows it.
- The model path has only been tested with a fake `fetch`. Compose ships without an API key.
- The snapshot e2e changes a dish's price after ordering but not its name, so serving live names instead of snapshotted ones would pass it.
- `Clock.advance()` is on the production clock class, because the auth e2e uses it to step past OTP expiry.
- An invalid timezone in a restaurant row would make the whole list return 500. Nothing writes restaurants today.
- `npm audit` reports 3 high-severity advisories, all in runtime dependencies: `multer` through `@nestjs/platform-express`, and `zod`. The fixes are Nest 12 and zod 4, both major upgrades. No route accepts file uploads, so multer never runs. Zod parses only the env at boot and the model's reply.
- The foundation code was written before I switched to test-first. Its tests came after, and each was proven by breaking the code and watching it fail.

Mobile:

- `ApiClient` can still throw on a malformed `API_BASE_URL`, because it parses the URL before its `try`. An envelope with a code and no message maps to `unknown`. A TLS handshake failure maps to `unknown` instead of `network`.
- `data/data_plane.dart` calls into `application/` to clear the session on a 401, so the data layer depends on the layer above it.
- A fractional price on the wire is truncated instead of rejected.
- The cart accepts more than the server's 50 lines, keeps the first price it saw when an item is re-added, and survives sign-out.
- Order status times show in UTC.
- The mobile cart, orders, login and chat code had no independent review before the deadline.

## Time spent

About 3 hours, from the first commit at 12:17 to the last code commit at 15:03.
