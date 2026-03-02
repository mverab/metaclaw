.PHONY: up down test logs shell pull clean

## Start the OpenClaw gateway with the Setup Architect skill mounted
up:
	@test -f .env || (cp .env.example .env && echo "⚠  Created .env from .env.example — add your API keys before continuing" && exit 1)
	docker compose up -d
	@echo "✓ Gateway starting at http://127.0.0.1:18789"
	@echo "  Waiting for health check..."
	@sleep 20
	@curl -fsS http://127.0.0.1:18789/healthz > /dev/null && echo "✓ Gateway healthy" || echo "✗ Gateway not ready yet — try: make logs"

## Stop and remove containers (data volume preserved)
down:
	docker compose down

## Run the E2E smoke test suite
test:
	@echo "Running Setup Architect smoke tests..."
	./test/smoke-test.sh

## Tail gateway logs
logs:
	docker compose logs -f openclaw-gateway

## Open a shell inside the running gateway container
shell:
	docker compose exec openclaw-gateway bash

## Pull latest OpenClaw image
pull:
	docker compose pull openclaw-gateway

## Destroy everything including the data volume (hard reset)
clean:
	docker compose down -v
	@echo "✓ Volume deleted — next 'make up' will be a fresh install"
