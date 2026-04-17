#!/usr/bin/env bash
# Setup Architect — Wrapper Utility E2E Test
# Usage: ./test/e2e-wrapper-test.sh
set -euo pipefail

PASS=0
FAIL=0
CLI="docker compose --profile cli run -T --rm openclaw-cli --no-color"
MODEL_PRIMARY="anthropic/claude-sonnet-4-5"
MODEL_FALLBACK="anthropic/claude-haiku-4-5"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}✓${NC} $1"; PASS=$((PASS+1)); }
fail() { echo -e "${RED}✗${NC} $1"; FAIL=$((FAIL+1)); }
info() { echo -e "${YELLOW}→${NC} $1"; }

echo ""
echo "══════════════════════════════════════════════"
echo "   Setup Architect — Wrapper E2E Test"
echo "══════════════════════════════════════════════"
echo ""

info "Checking gateway health..."
if docker compose exec openclaw-gateway curl -fsS http://127.0.0.1:18789/healthz > /dev/null 2>&1; then
  pass "Gateway is healthy"
else
  fail "Gateway is not healthy inside container network"
  echo "Run: docker compose up -d && sleep 20 && docker compose logs openclaw-gateway"
  exit 1
fi

info "Enforcing model policy (Sonnet primary, Haiku fallback)..."
$CLI config set agents.defaults.model.primary "$MODEL_PRIMARY" >/dev/null 2>&1 || true
$CLI config set agents.defaults.model.fallbacks "[\"$MODEL_FALLBACK\"]" >/dev/null 2>&1 || true
$CLI config set agents.defaults.models "{\"$MODEL_PRIMARY\":{},\"$MODEL_FALLBACK\":{}}" >/dev/null 2>&1 || true
docker compose restart openclaw-gateway > /dev/null 2>&1 || true
sleep 5

MODEL_STATUS=$($CLI models status --json 2>/dev/null || echo "")
if echo "$MODEL_STATUS" | grep -Eq "\"resolvedDefault\"[[:space:]]*:[[:space:]]*\"$MODEL_PRIMARY\"" && \
   ! echo "$MODEL_STATUS" | grep -qi "claude-opus"; then
  pass "Model policy enforced (no Opus)"
else
  fail "Model policy not enforced"
fi

info "Running wrapper-generation prompt (no clarifications requested)..."
PROMPT="Use the metaclaw-setup-architect skill to design an OpenClaw wrapper for monitoring RSS feeds and sending one daily Telegram digest. Assume sensible defaults for missing details and do not ask clarifying questions. Return exactly these sections: Setup Brief, Architecture Blueprint, Files to Generate."
RESPONSE=$($CLI agent --agent main --message "$PROMPT" --timeout 120 2>/dev/null || echo "ERROR: agent command failed")

if echo "$RESPONSE" | grep -qi "setup brief"; then
  pass "Includes Setup Brief"
else
  fail "Missing Setup Brief section"
fi

if echo "$RESPONSE" | grep -qi "architecture blueprint"; then
  pass "Includes Architecture Blueprint"
else
  fail "Missing Architecture Blueprint section"
fi

if echo "$RESPONSE" | grep -qi "files to generate"; then
  pass "Includes Files to Generate section"
else
  fail "Missing Files to Generate section"
fi

if echo "$RESPONSE" | grep -Eqi "pipeline|trigger|digest|telegram"; then
  pass "Contains wrapper-relevant pipeline/channel details"
else
  fail "Missing concrete wrapper pipeline/channel details"
fi

if echo "$RESPONSE" | grep -Eqi "AGENTS\.md|SKILL\.md|openclaw\.json"; then
  pass "References core wrapper output files"
else
  fail "Does not reference key wrapper files (AGENTS.md/SKILL.md/openclaw.json)"
fi

echo ""
echo "      Response preview:"
echo "      $(echo "$RESPONSE" | head -15 | sed 's/^/      /')"

echo ""
echo "══════════════════════════════════════════════"
echo -e "   Results: ${GREEN}${PASS} passed${NC}  ${RED}${FAIL} failed${NC}"
echo "══════════════════════════════════════════════"
echo ""

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
