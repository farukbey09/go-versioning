# ── Stage 1: Build ─────────────────────────────────────────────────────────────
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Bağımlılıkları önce kopyala (layer cache için)
COPY go.mod go.sum ./
RUN go mod download

COPY . .

# ARG'lar CI tarafından --build-arg ile geçilir
ARG VERSION=dev
ARG COMMIT=unknown
ARG BUILD_TIME=unknown

RUN go build \
    -ldflags "-s -w \
      -X main.Version=${VERSION} \
      -X main.Commit=${COMMIT} \
      -X main.BuildTime=${BUILD_TIME}" \
    -o server .

# ── Stage 2: Runtime ───────────────────────────────────────────────────────────
FROM alpine:3.20

# Güvenlik: root olarak çalıştırma
RUN adduser -D -u 1001 appuser
USER appuser

WORKDIR /app
COPY --from=builder /app/server .

EXPOSE 8080
ENTRYPOINT ["./server"]
