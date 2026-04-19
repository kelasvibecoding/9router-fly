#!/bin/sh
set -eu

echo "[start.sh] === 9router startup ==="
echo "[start.sh] date: $(date -u)"

export HOME="${HOME:-/data}"
export DATA_DIR="${DATA_DIR:-$HOME/.9router}"
export PORT="${PORT:-20128}"
export HOSTNAME="${HOSTNAME:-0.0.0.0}"
export NODE_ENV="${NODE_ENV:-production}"
export NEXT_TELEMETRY_DISABLED="${NEXT_TELEMETRY_DISABLED:-1}"

mkdir -p "$DATA_DIR"

echo "[start.sh] DATA_DIR=$DATA_DIR"
echo "[start.sh] PORT=$PORT"
echo "[start.sh] HOSTNAME=$HOSTNAME"
echo "[start.sh] NODE_ENV=$NODE_ENV"
echo "[start.sh] launching standalone server.js"

cd /app
exec node server.js
