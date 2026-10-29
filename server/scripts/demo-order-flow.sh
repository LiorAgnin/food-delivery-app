#!/usr/bin/env bash
# Place one order and walk it to DELIVERED against the compose API.
# Mint the bearer token inside the api container (Postgres is not published
# on the host). OTP verify is used instead when that route exists.
#
#   API_PORT=3102 docker compose -p fda-orders up -d --build
#   API_PORT=3102 COMPOSE_PROJECT=fda-orders server/scripts/demo-order-flow.sh
#   docker compose -p fda-orders down -v
set -euo pipefail

cd "$(dirname "$0")/../.."

API_PORT="${API_PORT:-3000}"
COMPOSE_PROJECT="${COMPOSE_PROJECT:-fda-orders}"
PHONE="${DEMO_PHONE:-+972501234567}"
BASE="http://127.0.0.1:${API_PORT}/api"

echo "waiting for ${BASE}/health"
ready=0
for _ in $(seq 1 90); do
  if curl -fsS "${BASE}/health" >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 1
done
if [[ "$ready" -ne 1 ]]; then
  echo "API did not become healthy at ${BASE}/health" >&2
  exit 1
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

token=""
request_code="$(curl -sS -o "${work}/otp-request.json" -w '%{http_code}' -X POST "${BASE}/auth/otp/request" \
  -H 'Content-Type: application/json' \
  --data "{\"phone\":\"${PHONE}\"}" || true)"
if [[ "$request_code" == "202" ]]; then
  verify_code="$(curl -sS -o "${work}/otp-verify.json" -w '%{http_code}' -X POST "${BASE}/auth/otp/verify" \
    -H 'Content-Type: application/json' \
    --data "{\"phone\":\"${PHONE}\",\"code\":\"123456\"}" || true)"
  if [[ "$verify_code" == "200" ]]; then
    token="$(node -e 'const fs=require("node:fs"); const body=JSON.parse(fs.readFileSync(process.argv[1],"utf8")); if (!body.accessToken) process.exit(1); process.stdout.write(body.accessToken)' "${work}/otp-verify.json")"
  fi
fi
if [[ -z "$token" ]]; then
  token="$(docker compose -p "$COMPOSE_PROJECT" exec -T api node dist/auth/print-token.js "$PHONE" | tr -d '\r\n')"
fi
if [[ -z "$token" ]]; then
  echo "failed to mint a customer token" >&2
  exit 1
fi

curl -fsS "${BASE}/restaurants" -o "${work}/restaurants.json"
WORK="$work" node <<'EOF'
const fs = require('node:fs')
const path = require('node:path')
const dir = process.env.WORK
const restaurants = JSON.parse(fs.readFileSync(path.join(dir, 'restaurants.json'), 'utf8')).restaurants
const open = restaurants.find((restaurant) => restaurant.isOpen)
if (!open) {
  console.error('no open restaurant')
  process.exit(1)
}
fs.writeFileSync(path.join(dir, 'restaurant.json'), JSON.stringify(open))
EOF

restaurant_id="$(WORK="$work" node -e 'const fs=require("node:fs"); const path=require("node:path"); const open=JSON.parse(fs.readFileSync(path.join(process.env.WORK,"restaurant.json"),"utf8")); process.stdout.write(open.id)')"
curl -fsS "${BASE}/restaurants/${restaurant_id}/menu" -o "${work}/menu.json"

WORK="$work" node <<'EOF'
const fs = require('node:fs')
const path = require('node:path')
const dir = process.env.WORK
const open = JSON.parse(fs.readFileSync(path.join(dir, 'restaurant.json'), 'utf8'))
const menu = JSON.parse(fs.readFileSync(path.join(dir, 'menu.json'), 'utf8'))
const available = menu.categories
  .flatMap((category) => category.items)
  .filter((item) => item.isAvailable)
  .sort((left, right) => right.priceAgorot - left.priceAgorot || left.name.localeCompare(right.name))
const items = []
let subtotal = 0
for (const item of available) {
  if (subtotal >= open.minOrderAgorot) break
  const quantity = Math.min(50, Math.ceil((open.minOrderAgorot - subtotal) / item.priceAgorot))
  items.push({ menuItemId: item.id, quantity })
  subtotal += item.priceAgorot * quantity
}
if (subtotal < open.minOrderAgorot) {
  console.error('menu cannot reach the minimum')
  process.exit(1)
}
fs.writeFileSync(path.join(dir, 'order.json'), JSON.stringify({
  restaurantId: open.id,
  items,
}))
EOF

key="$(node -e 'process.stdout.write(require("node:crypto").randomUUID())')"
create_code="$(curl -sS -o "${work}/created.json" -w '%{http_code}' -X POST "${BASE}/orders" \
  -H "Authorization: Bearer ${token}" \
  -H "Idempotency-Key: ${key}" \
  -H 'Content-Type: application/json' \
  --data-binary @"${work}/order.json")"
if [[ "$create_code" != "201" ]]; then
  echo "POST /orders failed with HTTP ${create_code}" >&2
  cat "${work}/created.json" >&2
  exit 1
fi

order_id="$(node -e 'const fs=require("node:fs"); const body=JSON.parse(fs.readFileSync(process.argv[1],"utf8")); process.stdout.write(body.id)' "${work}/created.json")"
echo "placed ${order_id}"

advance () {
  local to="$1"
  local actor="$2"
  local code
  code="$(curl -sS -o "${work}/status.json" -w '%{http_code}' -X PATCH "${BASE}/orders/${order_id}/status" \
    -H 'Content-Type: application/json' \
    --data "{\"status\":\"${to}\",\"actor\":\"${actor}\"}")"
  if [[ "$code" != "200" ]]; then
    echo "PATCH ${to} by ${actor} failed with HTTP ${code}" >&2
    cat "${work}/status.json" >&2
    exit 1
  fi
  echo "${actor} -> ${to}"
}

advance ACCEPTED restaurant
advance PREPARING restaurant
advance PICKED_UP courier
advance DELIVERED courier

curl -fsS "${BASE}/orders/${order_id}" -H "Authorization: Bearer ${token}" -o "${work}/final.json"
final_status="$(node -e 'const fs=require("node:fs"); const body=JSON.parse(fs.readFileSync(process.argv[1],"utf8")); process.stdout.write(body.status)' "${work}/final.json")"
if [[ "$final_status" != "DELIVERED" ]]; then
  echo "expected DELIVERED, got ${final_status}" >&2
  cat "${work}/final.json" >&2
  exit 1
fi
echo "order ${order_id} is DELIVERED"
