#!/bin/sh
# Request a dev OTP, verify 123456, and call a guarded route.
# Usage from anywhere: API_PORT=3106 server/scripts/demo-otp.sh
set -eu

root=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
cd "$root"

API_PORT="${API_PORT:-3106}"
export API_PORT
base="http://127.0.0.1:${API_PORT}"
phone="+972501234567"

cleanup () {
  docker compose -p fda-auth down -v
}
trap cleanup EXIT

docker compose -p fda-auth up -d --build

ready=0
for _ in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30; do
  if curl -sf "${base}/api/health" >/dev/null; then
    ready=1
    break
  fi
  sleep 2
done
if [ "$ready" -ne 1 ]; then
  echo "api did not become ready on ${base}" >&2
  docker compose -p fda-auth logs api >&2 || true
  exit 1
fi

echo "POST /api/auth/otp/request"
curl -sS -X POST "${base}/api/auth/otp/request" \
  -H 'content-type: application/json' \
  -d "{\"phone\":\"${phone}\"}"
echo

echo "POST /api/auth/otp/verify"
verify=$(curl -sS -X POST "${base}/api/auth/otp/verify" \
  -H 'content-type: application/json' \
  -d "{\"phone\":\"${phone}\",\"code\":\"123456\"}")
printf '%s\n' "$verify"

token=$(printf '%s' "$verify" | node -e "let s='';process.stdin.on('data',(d)=>s+=d);process.stdin.on('end',()=>{const body=JSON.parse(s); if(!body.accessToken){process.stderr.write(s); process.exit(1)}; process.stdout.write(body.accessToken)})")

echo "GET /api/auth/me"
curl -sS "${base}/api/auth/me" -H "Authorization: Bearer ${token}"
echo
