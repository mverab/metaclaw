#!/usr/bin/env bash
# Setup Architect — E2E Smoke Test
# Usage: ./test/smoke-test.sh
# Requires: docker compose up -d (gateway running)
set -euo pipefail

PASS=0
FAIL=0
CLI="docker compose --profile cli run -T --rm openclaw-cli --no-color"
MODEL_PRIMARY="anthropic/claude-sonnet-4-5"
MODEL_FALLBACK="anthropic/claude-haiku-4-5"
SKILL_DIR="$(find "$(cd "$(dirname "$0")/.." && pwd)/skills" -mindepth 1 -maxdepth 1 -type d | head -1 | xargs basename)"
SKILL_PATH="/home/node/.openclaw/skills/$SKILL_DIR"
SKILL_NAME=""

# ── Colors ──────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}✓${NC} $1"; PASS=$((PASS+1)); }
fail() { echo -e "${RED}✗${NC} $1"; FAIL=$((FAIL+1)); }
info() { echo -e "${YELLOW}→${NC} $1"; }

check_optional_file() {
  local rel="$1"
  local local_path="$(cd "$(dirname "$0")/.." && pwd)/skills/$SKILL_DIR/$rel"
  local container_path="$SKILL_PATH/$rel"
  if [ -f "$local_path" ]; then
    if docker compose exec openclaw-gateway test -f "$container_path"; then
      pass "$rel present"
    else
      fail "$rel missing in container"
    fi
  else
    info "Skipping optional check (not present locally): $rel"
  fi
}

echo ""
echo "══════════════════════════════════════════════"
echo "   Setup Architect — Smoke Test"
echo "══════════════════════════════════════════════"
echo ""

if [ -z "$SKILL_DIR" ] || [ ! -f "$(cd "$(dirname "$0")/.." && pwd)/skills/$SKILL_DIR/SKILL.md" ]; then
  fail "No skill directory with SKILL.md found under ./skills"
  exit 1
fi
SKILL_NAME="$(sed -n 's/^name:[[:space:]]*//p' "$(cd "$(dirname "$0")/.." && pwd)/skills/$SKILL_DIR/SKILL.md" | head -1 | tr -d '\r')"

# ── 1. Gateway health ────────────────────────────────────────────────────────
info "Checking gateway health..."
if docker compose exec openclaw-gateway curl -fsS http://127.0.0.1:18789/healthz > /dev/null 2>&1; then
  pass "Gateway is healthy"
else
  fail "Gateway is not healthy inside container network"
  echo "Run: docker compose up -d && sleep 20 && docker compose logs openclaw-gateway"
  exit 1
fi

# ── 2. Skill file is mounted ─────────────────────────────────────────────────
info "Verifying skill is mounted in container..."
if docker compose exec openclaw-gateway test -f "$SKILL_PATH/SKILL.md"; then
  pass "SKILL.md found at $SKILL_PATH/SKILL.md"
else
  fail "SKILL.md not found — check volume mount in docker-compose.yml"
fi

# ── 3. Knowledge base files present ─────────────────────────────────────────
info "Checking knowledge base files..."
check_optional_file "knowledge/file-system.md"
check_optional_file "knowledge/tool-catalog.md"
check_optional_file "knowledge/agent-patterns.md"
check_optional_file "knowledge/skill-templates.md"

# ── 4. Template files present ───────────────────────────────────────────────
info "Checking template files..."
check_optional_file "templates/AGENTS.md.tmpl"
check_optional_file "templates/SOUL.md.tmpl"
check_optional_file "templates/IDENTITY.md.tmpl"
check_optional_file "templates/MEMORY.md.tmpl"
check_optional_file "templates/TOOLS.md.tmpl"
check_optional_file "templates/HEARTBEAT.md.tmpl"
check_optional_file "templates/BOOTSTRAP.md.tmpl"
check_optional_file "templates/SKILL.md.tmpl"
check_optional_file "templates/workflow-AGENT.md.tmpl"
check_optional_file "templates/openclaw.json.tmpl"
check_optional_file "templates/MOC.md.tmpl"

# ── 5. Example files present ─────────────────────────────────────────────────
info "Checking example files..."
check_optional_file "examples/youtube-clipper.md"
check_optional_file "examples/community-assistant.md"
check_optional_file "examples/obsidian-llm-wiki.md"

# ── 6. Enforce low-cost model policy (no Opus) ──────────────────────────────
info "Enforcing model policy (Sonnet primary, Haiku fallback)..."
$CLI config set agents.defaults.model.primary "$MODEL_PRIMARY" >/dev/null 2>&1 || true
$CLI config set agents.defaults.model.fallbacks "[\"$MODEL_FALLBACK\"]" >/dev/null 2>&1 || true
$CLI config set agents.defaults.models "{\"$MODEL_PRIMARY\":{},\"$MODEL_FALLBACK\":{}}" >/dev/null 2>&1 || true
docker compose restart openclaw-gateway > /dev/null 2>&1 || true
sleep 5

MODEL_STATUS=$($CLI models status --json 2>/dev/null || echo "")
if echo "$MODEL_STATUS" | grep -Eq "\"resolvedDefault\"[[:space:]]*:[[:space:]]*\"$MODEL_PRIMARY\"" && \
   ! echo "$MODEL_STATUS" | grep -qi "claude-opus"; then
  pass "Model policy enforced (default=$MODEL_PRIMARY, fallback=$MODEL_FALLBACK, no Opus)"
else
  fail "Model policy not enforced — status: $MODEL_STATUS"
fi

# ── 7. Skill is discoverable by OpenClaw ─────────────────────────────────────
info "Checking if skill is discovered by OpenClaw..."
SKILLS_LIST=$($CLI skills list 2>/dev/null || echo "")
SKILL_MATCH=1
for token in $(echo "$SKILL_NAME" | tr '_-' ' '); do
  if ! echo "$SKILLS_LIST" | grep -qi "$token"; then
    SKILL_MATCH=0
    break
  fi
done
if echo "$SKILLS_LIST" | grep -q "openclaw-managed" && [ "$SKILL_MATCH" -eq 1 ]; then
  pass "$SKILL_NAME skill discovered by OpenClaw"
else
  fail "$SKILL_NAME skill not in skill list — check SKILL.md frontmatter (name: $SKILL_NAME)"
  echo "      Skill list output: $SKILLS_LIST"
fi

# ── 8. Agent responds to a skill trigger ─────────────────────────────────────
info "Sending test prompt to agent (may take 30-60s)..."
PROMPT="Use the $SKILL_NAME skill. I want a simple single-agent setup for monitoring RSS feeds and sending me a daily digest via Telegram. Just do the Discovery phase and stop — ask me the required questions."

RESPONSE=$($CLI agent --agent main --message "$PROMPT" --timeout 90 2>/dev/null || echo "ERROR: agent command failed")

if echo "$RESPONSE" | grep -qi "discovery\|question\|pipeline\|channel\|telegram"; then
  pass "Agent triggered Discovery phase correctly"
  echo ""
  echo "      Agent response preview:"
  echo "      $(echo "$RESPONSE" | head -5 | sed 's/^/      /')"
else
  fail "Agent did not trigger Discovery phase as expected"
  echo ""
  echo "      Agent response:"
  echo "      $(echo "$RESPONSE" | head -10 | sed 's/^/      /')"
fi

# ── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo "══════════════════════════════════════════════"
echo -e "   Results: ${GREEN}${PASS} passed${NC}  ${RED}${FAIL} failed${NC}"
echo "══════════════════════════════════════════════"
echo ""

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
