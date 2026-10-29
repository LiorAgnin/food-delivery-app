# ============================================
# Base stage
# ============================================
FROM node:22-alpine AS base

RUN apk add --no-cache ca-certificates

WORKDIR /usr/src/app

RUN chown -R node:node /usr/src/app

# ============================================
# Dependencies stage
# ============================================
FROM base AS dependencies

USER node

COPY --chown=node:node package.json package-lock.json ./

RUN --mount=type=cache,id=npm-server,target=/home/node/.npm,uid=1000,gid=1000 \
    npm ci

# ============================================
# Builder stage
# ============================================
FROM dependencies AS builder

COPY --chown=node:node . .

RUN npm run build

# ============================================
# Production dependencies
# ============================================
FROM base AS production-dependencies

USER node

COPY --chown=node:node package.json package-lock.json ./

RUN --mount=type=cache,id=npm-server,target=/home/node/.npm,uid=1000,gid=1000 \
    npm ci --omit=dev --ignore-scripts

# ============================================
# Production stage — dist, prod deps, and the generated SQL migrations
# ============================================
FROM node:22-alpine AS production

RUN apk add --no-cache ca-certificates

WORKDIR /usr/src/app

COPY --from=production-dependencies --chown=node:node /usr/src/app/node_modules ./node_modules
COPY --from=builder --chown=node:node /usr/src/app/dist ./dist
COPY --from=builder --chown=node:node /usr/src/app/drizzle ./drizzle
COPY --chown=node:node package.json ./
COPY --chown=node:node docker-entrypoint.sh ./
RUN chmod +x docker-entrypoint.sh

USER node

EXPOSE 3000

ENTRYPOINT ["./docker-entrypoint.sh"]
