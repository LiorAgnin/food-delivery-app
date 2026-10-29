#!/usr/bin/env bash
# Boots the API on port 3103, runs the assignment dish-finder conversations,
# prints each reply and the dish names, then removes the compose project.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

export API_PORT=3103

docker compose -p fda-finder up -d --build

cleanup () {
  docker compose -p fda-finder down -v
}
trap cleanup EXIT

for _ in $(seq 1 60); do
  if curl -sf "http://127.0.0.1:${API_PORT}/api/health" >/dev/null; then
    break
  fi
  sleep 2
done
curl -sf "http://127.0.0.1:${API_PORT}/api/health" >/dev/null

TOKEN="$(
  docker compose -p fda-finder exec -T api \
    node dist/auth/print-token.js +972500000001 | tr -d '\r'
)"

post () {
  local title="$1"
  local body="$2"
  echo "===== ${title} ====="
  curl -sS -X POST "http://127.0.0.1:${API_PORT}/api/dish-finder/search" \
    -H "Authorization: Bearer ${TOKEN}" \
    -H 'Content-Type: application/json' \
    -d "${body}" \
    | node -e '
      let raw = "";
      process.stdin.on("data", (chunk) => { raw += chunk; });
      process.stdin.on("end", () => {
        const body = JSON.parse(raw);
        console.log("reply:", body.reply);
        console.log("relaxed:", JSON.stringify(body.relaxed));
        console.log("results:");
        for (const result of body.results ?? []) {
          const flag = result.orderable ? "orderable" : "not orderable";
          console.log(" -", result.menuItem.name, "(" + flag + ")");
        }
      });
    '
  echo
}

post "margherita pizza" \
  '{"messages":[{"role":"user","content":"I want a margherita pizza"}]}'

post "spicy chicken under 60" \
  '{"messages":[{"role":"user","content":"Something spicy with chicken under 60 ₪"}]}'

post "vegan dinner, not burgers" \
  '{"messages":[{"role":"user","content":"Vegan dinner, not burgers"}]}'

post "sushi from places that are open now" \
  '{"messages":[{"role":"user","content":"Show me sushi from places that are open now"}]}'

post "cheaper ones" \
  '{"messages":[{"role":"user","content":"Something spicy with chicken under 60 ₪"},{"role":"assistant","content":"Found 2 spicy chicken dishes under ₪60."},{"role":"user","content":"cheaper ones?"}]}'
