# syntax=docker/dockerfile:1.7
# ── Stage 1: Build ──────────────────────────────────────────────────────────
FROM node:20-alpine AS builder

RUN apk add --no-cache git python3 make g++ linux-headers

WORKDIR /opt/9router

RUN git clone --depth 1 --branch master https://github.com/decolua/9router.git .

ENV NEXT_TELEMETRY_DISABLED=1

# Cache npm install — only re-runs when package.json / package-lock.json changes
RUN --mount=type=cache,target=/root/.npm \
    npm install && npm install prop-types

ENV NODE_ENV=production

# Cache Next.js build cache — only re-compiles changed pages/modules
RUN --mount=type=cache,target=/opt/9router/.next/cache \
    npm run build


# ── Stage 2: Runner ─────────────────────────────────────────────────────────
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    PORT=20128 \
    HOSTNAME=0.0.0.0 \
    HOME=/data \
    DATA_DIR=/data/.9router \
    BROWSER=none

# Copy the Next.js standalone server
COPY --from=builder /opt/9router/.next/standalone ./

# Copy static assets (CSS, JS chunks) — required for styling to work
COPY --from=builder /opt/9router/.next/static ./.next/static

# Copy public folder (images, icons, fonts, etc.)
COPY --from=builder /opt/9router/public ./public

# Copy extra runtime files referenced by the server
COPY --from=builder /opt/9router/open-sse ./open-sse
COPY --from=builder /opt/9router/src/mitm ./src/mitm
COPY --from=builder /opt/9router/node_modules/node-forge ./node_modules/node-forge

# Runtime data directory (backed by Fly volume at /data)
RUN mkdir -p /data

# Startup script
COPY scripts/start.sh /app/start.sh
RUN sed -i 's/\r$//' /app/start.sh && chmod +x /app/start.sh

EXPOSE 20128

CMD ["/app/start.sh"]
