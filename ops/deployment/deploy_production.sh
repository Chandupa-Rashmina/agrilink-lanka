#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

if [ ! -f .env.production ]; then
  echo ".env.production is missing."
  exit 1
fi

docker compose --env-file .env.production -f compose.production.yaml build --pull
docker compose --env-file .env.production -f compose.production.yaml up -d

docker compose --env-file .env.production -f compose.production.yaml exec -T api \
  php artisan migrate --force

docker compose --env-file .env.production -f compose.production.yaml exec -T api \
  php artisan storage:link || true

docker compose --env-file .env.production -f compose.production.yaml exec -T api \
  php artisan optimize

docker compose --env-file .env.production -f compose.production.yaml ps
