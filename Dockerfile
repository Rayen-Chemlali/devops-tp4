# ─── Stage 1: Build & Test ────────────────────────────────────────────────────
FROM node:18-alpine AS builder

WORKDIR /app

COPY app/package*.json ./
RUN npm ci

COPY app/ .

# ─── Stage 2: Production ──────────────────────────────────────────────────────
FROM node:18-alpine AS production

# Sécurité : ne pas tourner en root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodeuser -u 1001

WORKDIR /app

COPY --from=builder /app/package*.json ./
RUN npm ci --only=production && npm cache clean --force

COPY --from=builder /app/app.js ./

# Changer la propriété des fichiers
RUN chown -R nodeuser:nodejs /app

USER nodeuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "app.js"]
