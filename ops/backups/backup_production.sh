#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

if [ ! -f .env.production ]; then
  echo ".env.production is missing."
  exit 1
fi

set -a
source .env.production
set +a

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
DEST="$ROOT/backups/$STAMP"
mkdir -p "$DEST"

docker compose --env-file .env.production -f compose.production.yaml exec -T postgres \
  pg_dump -U "$DB_USERNAME" -d "$DB_DATABASE" -Fc > "$DEST/database.dump"

docker run --rm \
  -v agrilink-lanka_public_storage:/source:ro \
  -v "$DEST":/backup \
  alpine:3.21 \
  tar -czf /backup/public-storage.tar.gz -C /source .

sha256sum "$DEST/database.dump" "$DEST/public-storage.tar.gz" \
  > "$DEST/SHA256SUMS"

find "$ROOT/backups" -mindepth 1 -maxdepth 1 -type d -mtime +14 -exec rm -rf {} +

echo "Backup created: $DEST"
