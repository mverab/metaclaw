#!/usr/bin/env bash
# Setup Architect — E2E Smoke Test
# Usage: ./test/smoke-test.sh
# Requires: docker compose up -d (gateway running)
set -euo pipefail

PASS=0
FAIL=0
CLI="docker compose run -T --rm --profile cli openclaw-cli"
SKILL_PATH="/home/node/.openclaw/skills/metaclaw-setup-architect"

# ── Colors ──────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}✓${NC} $1"; PASS=$((PASS+1)); }
fail() { echo -e "${RED}✗${NC} $1"; FAIL=$((FAIL+1)); }
info() { echo -e "${YELLOW}→${NC} $1"; }

# Check a list of files exist inside the gateway container.
# Usage: check_files "label" file1 file2 ...
check_files() {
  local label=$1; shift
  info "Checking $label files..."
  for f in "$@"; do
    if docker compose exec openclaw-gateway test -f "$SKILL_PATH/$f"; then
      pass "$f present"
    else
      fail "$f missing"
    fi
  done
}

echo ""
echo "══════════════════════════════════════════════"
echo "   Setup Architect — Smoke Test"
echo "══════════════════════════════════════════════"
echo ""

# ── 1. Gateway health ────────────────────────────────────────────────────────
info "Checking gateway health..."
if curl -fsS http://127.0.0.1:18789/healthz > /dev/null 2>&1; then
  pass "Gateway is healthy"
else
  fail "Gateway is not responding at http://127.0.0.1:18789"
  echo "Run: docker compose up -d && sleep 20"
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
check_files "knowledge base" \
  "knowledge/file-system.md" \
  "knowledge/tool-catalog.md" \
  "knowledge/agent-patterns.md" \
  "knowledge/skill-templates.md"

# ── 4. Template files present ───────────────────────────────────────────────
check_files "template" \
  "templates/AGENTS.md.tmpl" \
  "templates/SOUL.md.tmpl" \
  "templates/IDENTITY.md.tmpl" \
  "templates/MEMORY.md.tmpl" \
  "templates/TOOLS.md.tmpl" \
  "templates/HEARTBEAT.md.tmpl" \
  "templates/BOOTSTRAP.md.tmpl" \
  "templates/SKILL.md.tmpl" \
  "templates/workflow-AGENT.md.tmpl" \
  "templates/openclaw.json.tmpl" \
  "templates/MOC.md.tmpl"

# ── 5. Example files present ─────────────────────────────────────────────────
check_files "example" \
  "examples/youtube-clipper.md" \
  "examples/community-assistant.md"

# ── 6. Skill is discoverable by OpenClaw ─────────────────────────────────────
info "Checking if skill is discovered by OpenClaw..."
SKILLS_LIST=$($CLI skills list 2>/dev/null || echo "")
if echo "$SKILLS_LIST" | grep -q "metaclaw-setup-architect"; then
  pass "metaclaw-setup-architect skill discovered by OpenClaw"
else
  fail "metaclaw-setup-architect skill not in skill list — check SKILL.md frontmatter (name: metaclaw-setup-architect)"
  echo "      Skill list output: $SKILLS_LIST"
fi

# ── 7. Agent responds to a skill trigger ─────────────────────────────────────
info "Sending test prompt to agent (may take 30-60s)..."
PROMPT="Use the metaclaw-setup-architect skill. I want a simple single-agent setup for monitoring RSS feeds and sending me a daily digest via Telegram. Just do the Discovery phase and stop — ask me the required questions."

RESPONSE=$($CLI agent --message "$PROMPT" --timeout 90 2>/dev/null || echo "ERROR: agent command failed")

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
