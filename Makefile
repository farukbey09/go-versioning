APP    := server
BINARY := ./$(APP)
IMAGE  := ghcr.io/$(shell git config --get remote.origin.url 2>/dev/null | sed 's|.*github.com[:/]||;s|\.git$$||' || echo "user/$(APP)")

VERSION    := $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
COMMIT     := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_TIME := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

LDFLAGS := -ldflags "-s -w \
  -X main.Version=$(VERSION) \
  -X main.Commit=$(COMMIT) \
  -X main.BuildTime=$(BUILD_TIME)"

.PHONY: build run dev docker-build docker-run version clean

## Versiyon bilgisini ekleyerek derle
build:
	go build $(LDFLAGS) -o $(BINARY) .

## Derleyip çalıştır
run: build
	$(BINARY)

## go run (hızlı geliştirme, ldflags yok)
dev:
	go run .

## Docker image derle (CI ile aynı ARG'lar)
docker-build:
	docker build \
	  --build-arg VERSION=$(VERSION) \
	  --build-arg COMMIT=$(COMMIT) \
	  --build-arg BUILD_TIME=$(BUILD_TIME) \
	  -t $(IMAGE):$(VERSION) \
	  -t $(IMAGE):latest \
	  .

## Docker image'ı çalıştır
docker-run:
	docker run --rm -p 8080:8080 $(IMAGE):latest

## Mevcut git versiyon bilgisini göster
version:
	@echo "Version:    $(VERSION)"
	@echo "Commit:     $(COMMIT)"
	@echo "Build Time: $(BUILD_TIME)"

clean:
	rm -f $(BINARY)
