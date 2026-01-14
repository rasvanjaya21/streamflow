FROM oven/bun:1.3.0-alpine AS base

RUN apk update && apk add --no-cache ffmpeg

RUN addgroup -S pinc && adduser -S -u 1001 -G pinc pinc

FROM base AS development-dependencies
WORKDIR /app
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

FROM base AS production-dependencies
WORKDIR /app
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile --production && bun pm cache rm

FROM base AS runner
WORKDIR /app
COPY ./ ./
COPY --from=production-dependencies /app/node_modules ./node_modules
RUN chown -R pinc:pinc /app
ENV NODE_ENV production

USER pinc
CMD [ "bun", "start" ]