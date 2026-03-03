# MetaClaw Setup Architect

A MetaClaw-branded OpenClaw skill that generates complete multi-agent setups from natural language descriptions. Describe what you want, and the MetaClaw Setup Architect produces every configuration file — agents, skills, workflows, memory, and installation steps — zero effort.

---

## What Is This?

The **MetaClaw Setup Architect** is an OpenClaw skill that acts as a setup factory. Instead of manually configuring agents, writing SKILL.md files, and wiring up MCP servers, you describe your use case in plain English and the skill:

1. **Discovers** your requirements through 4-6 targeted questions
2. **Designs** a multi-agent architecture with the right tools and patterns
3. **Generates** every file: AGENTS.md, SOUL.md, MEMORY.md, skills, workflows, openclaw.json
4. **Installs** the configuration with copy-pasteable commands

## Quick Start

### Install the Skill

#### Recommended (GitHub / skills.sh)

```bash
# Install directly from GitHub repo
npx skills add mverab/metaclaw --skill metaclaw-setup-architect
```

```bash
# Optional: verify what the repo exposes
npx skills add mverab/metaclaw --list
```

#### Local Development

```bash
# Validate local skill discovery before pushing changes
npx skills add /absolute/path/to/metaclaw --list
```

```bash
# Install from local repo copy
npx skills add /absolute/path/to/metaclaw --skill metaclaw-setup-architect
```

### Use It

Send your OpenClaw agent a message like:

> "I want to create a multi-agent setup for YouTube clipping viral short-form content from long-form videos. Consider the entire pipeline, tools, editing, and publishing."

Or:

> "Help me create an OpenClaw setup for a community assistant that helps Skool community owners manage questions and find relevant lessons."

MetaClaw Setup Architect takes over from there.

---

## Project Structure

```
skills/metaclaw-setup-architect/
├── SKILL.md                          ← Main skill (the orchestrator)
│
├── knowledge/                        ← Reference knowledge base
│   ├── file-system.md                ← Complete OpenClaw file system reference
│   ├── tool-catalog.md               ← 80+ tools/MCPs categorized by domain
│   ├── agent-patterns.md             ← 5 multi-agent architecture patterns
│   └── skill-templates.md            ← Domain-specific SKILL.md templates
│
├── templates/                        ← File generation templates
│   ├── AGENTS.md.tmpl                ← Agent operating instructions
│   ├── SOUL.md.tmpl                  ← Agent personality
│   ├── USER.md.tmpl                  ← Human profile
│   ├── MEMORY.md.tmpl                ← Semantic memory
│   ├── TOOLS.md.tmpl                 ← Environment config
│   ├── HEARTBEAT.md.tmpl             ← Periodic schedule
│   ├── IDENTITY.md.tmpl              ← Agent identity card
│   ├── BOOTSTRAP.md.tmpl             ← First-run setup
│   ├── SKILL.md.tmpl                 ← Custom skill template
│   ├── workflow-AGENT.md.tmpl        ← Workflow algorithm
│   ├── openclaw.json.tmpl            ← Gateway configuration
│   └── MOC.md.tmpl                   ← Map of Content
│
└── examples/                         ← Complete end-to-end examples
    ├── youtube-clipper.md             ← 3-agent YouTube clipping pipeline
    └── community-assistant.md         ← 2-agent Skool community manager
```

## Knowledge Base

| File | What It Contains |
|------|-----------------|
| `file-system.md` | Every file in OpenClaw's architecture — paths, purposes, formats, loading behavior |
| `tool-catalog.md` | 80+ tools organized in 12 categories: Web, Filesystem, Video, Comms, AI Models, Data, Productivity, Marketing, Commerce, DevOps, Health, Community |
| `agent-patterns.md` | 5 architecture patterns: Pipeline, Hub-and-Spoke, Autonomous Loop, Human-in-the-Loop, Supervisor |
| `skill-templates.md` | Ready-to-customize SKILL.md templates for 7 common domains |

## Multi-Agent Patterns

| Pattern | Best For | Example |
|---------|----------|---------|
| **Pipeline** | Sequential processing (A → B → C) | Content scrape → write → publish |
| **Hub-and-Spoke** | Coordinator + specialists | Lead dev + frontend + backend + QA |
| **Autonomous Loop** | Self-running recurring tasks | SEO monitor that runs 24/7 |
| **Human-in-the-Loop** | Agent proposes, human approves | Content review before publishing |
| **Supervisor** | Quality control over other agents | QA agent that reviews all outputs |

## Examples

### YouTube Viral Clipper (3 agents)
- **Scout**: Monitors channels, scores viral potential
- **Editor**: Downloads, transcribes, identifies clips, cuts vertical video
- **Publisher**: Human approval queue → publish to Shorts/TikTok/Reels

### Skool Community Assistant (2 agents)
- **Community Brain**: Answers questions, finds lessons, builds knowledge base
- **Engagement Ops**: Welcomes members, tracks metrics, weekly reports to owner

---

---

## Docker Testing

Spin up an isolated OpenClaw instance with the skill mounted — no local install required.

### Prerequisites
- Docker Desktop (or Docker Engine + Compose v2)
- At least 2 GB RAM

### Quick Start

```bash
# 1. Copy env file and add your API key
cp .env.example .env
# edit .env — add ANTHROPIC_API_KEY (minimum required)

# 2. Start gateway
make up

# 3. Open Control UI
open http://127.0.0.1:18789

# 4. Run smoke tests
make test
```

### What the Smoke Test Checks

1. **Gateway health** — `GET /healthz` responds 200
2. **Skill mounted** — `SKILL.md` exists inside the container
3. **Knowledge base** — all 4 knowledge files present
4. **Templates** — all 11 template files present
5. **Examples** — both example files present
6. **Skill discovered** — appears in `openclaw skills list`
7. **Agent trigger** — agent correctly activates Discovery phase on a test prompt

### Useful Commands

```bash
make logs    # tail gateway logs
make shell   # bash session inside the container
make down    # stop containers (data preserved)
make clean   # hard reset — wipes the volume
make pull    # update to latest OpenClaw image
```

### How It Works

The `docker-compose.yml` uses the official `ghcr.io/openclaw/openclaw:latest` image (no local build) and bind-mounts the skill as read-only into the container's shared skills directory:

```
./skills/metaclaw-setup-architect  →  /home/node/.openclaw/skills/metaclaw-setup-architect (ro)
```

The test workspace (`./test/workspace/`) is also mounted so the test agent's AGENTS.md and SOUL.md are available without any manual configuration.

---

## Extending

### Add New Tool Categories
Edit `knowledge/tool-catalog.md` to add new tools or MCP servers.

### Add New Architecture Patterns
Edit `knowledge/agent-patterns.md` to add new multi-agent patterns.

### Add New Skill Templates
Edit `knowledge/skill-templates.md` to add domain-specific SKILL.md templates.

### Add New Examples
Create new files in `examples/` following the existing format.

---

## License

MIT
