# OpenClaw File System Reference

Complete reference of the OpenClaw memory file system architecture. Use this to know exactly what files to generate, where they go, and what each one does.

---

## Directory Layout

```
~/.openclaw/
├── openclaw.json                          ← Gateway configuration (agents, channels, bindings, MCP servers)
├── skills/                                ← Shared skills (available to ALL agents)
│   └── {skill-name}/SKILL.md
├── workspace/                             ← Default single-agent workspace
│   ├── AGENTS.md                          ← Operating instructions + memory directives
│   ├── SOUL.md                            ← Persona, boundaries, tone, style
│   ├── USER.md                            ← Human profile + preferred address
│   ├── IDENTITY.md                        ← Agent name, vibe, emoji
│   ├── TOOLS.md                           ← User-maintained tool notes + conventions
│   ├── BOOTSTRAP.md                       ← One-time first-run ritual (deleted after completion)
│   ├── MEMORY.md                          ← Curated semantic memory (~100 lines max)
│   ├── HEARTBEAT.md                       ← Periodic check schedule + cron tasks
│   ├── memory/
│   │   ├── YYYY-MM-DD.md                  ← Daily episodic logs
│   │   ├── SYSTEM.md                      ← Operational knowledge (tools, configs, workflows)
│   │   ├── OWNER.md                       ← Strategic notes (decisions, insights, goals)
│   │   └── TOOLING.md                     ← Connected services + reconnection protocols
│   ├── skills/                            ← Per-workspace skills (only this agent)
│   │   └── {skill-name}/SKILL.md
│   └── workflows/
│       └── {workflow-name}/
│           ├── AGENT.md                   ← Workflow algorithm
│           ├── rules.md                   ← User preferences (NEVER overwritten by updates)
│           ├── agent_notes.md             ← Learned patterns (grows over time)
│           └── logs/                      ← Execution history
│
├── workspace-{agentId}/                   ← Per-agent workspaces (multi-agent mode)
│   └── (same structure as workspace/)
│
└── agents/
    └── {agentId}/
        ├── agent/
        │   └── auth-profiles.json         ← Per-agent auth
        └── sessions/
            └── {sessionId}.jsonl          ← Chat history + routing state
```

---

## Bootstrap Files (Injected Every Session)

These files are loaded into the agent context at the start of every new session. Blank files are skipped. Large files are trimmed.

### AGENTS.md
- **Purpose**: Operating instructions — tells the agent HOW to behave, what to do, what rules to follow
- **Contains**: Task instructions, memory management rules, tool usage guidelines, response formatting
- **Loaded**: Every session, first turn
- **Size guidance**: Keep focused. This is the agent's "job description"

### SOUL.md
- **Purpose**: Persona definition — WHO the agent is
- **Contains**: Personality traits, communication style, tone, boundaries, values
- **Loaded**: Every session, first turn
- **Key**: This is what makes each agent unique. A coding agent sounds different from a health coach

### USER.md
- **Purpose**: Human profile — WHO the agent is talking to
- **Contains**: Name, role, preferences, goals, communication style, timezone
- **Loaded**: Every session, first turn
- **Key**: Helps the agent personalize responses and understand context

### IDENTITY.md
- **Purpose**: Quick reference card — agent's name, emoji, one-line description
- **Contains**: Agent name, emoji identifier, short description
- **Loaded**: Every session
- **Format**: Very short, 3-5 lines

### TOOLS.md
- **Purpose**: User-maintained tool notes and conventions
- **Contains**: Local environment config, installed tools, API endpoints, naming conventions
- **Loaded**: Every session, first turn
- **Key**: Tells the agent what tools are available and how to use them in THIS specific environment

### BOOTSTRAP.md
- **Purpose**: One-time first-run ritual
- **Contains**: Setup steps to run on first boot (install dependencies, create dirs, configure APIs)
- **Loaded**: Only on first session, then DELETED
- **Key**: This is the "unboxing experience" — what happens when someone installs the wrapper

### HEARTBEAT.md
- **Purpose**: Periodic check schedule
- **Contains**: Cron-like schedule of recurring tasks the agent should perform
- **Loaded**: When heartbeat poll triggers
- **Key**: Enables autonomous operation — the agent wakes up and checks this to know what to do

---

## Memory System

### MEMORY.md (Semantic — Always Loaded)
- Curated essentials that are ALWAYS true
- ~100 lines max
- No dates, no one-time events
- Example: "Owner prefers .99 pricing", "Always use TypeScript for new projects"
- **Promotion rule**: If an episodic observation recurs 3+ times, promote it to MEMORY.md

### memory/YYYY-MM-DD.md (Episodic — Today + Yesterday)
- What happened on this specific day
- Decisions made, tasks completed, errors encountered
- Today + yesterday loaded automatically
- Older logs searchable via semantic search

### memory/SYSTEM.md (Operational — Per Project)
- Tools, configs, workflows specific to this project
- API endpoints, credentials locations, deployment procedures
- Loaded per-project context

### memory/OWNER.md (Strategic — Per Project)
- High-level decisions, insights, goals
- Business strategy, priorities, constraints
- The "why" behind decisions

### memory/TOOLING.md (Connections — Per Project)
- Connected external services
- Reconnection protocols if service drops
- API keys location, rate limits, known issues

---

## Multi-Agent Configuration (openclaw.json)

```json
{
  "agents": {
    "defaults": {
      "model": "provider/model-name",
      "workspace": "~/.openclaw/workspace"
    },
    "list": [
      {
        "id": "agent-id",
        "workspace": "~/.openclaw/workspace-agent-id",
        "sandbox": {
          "mode": "off|all",
          "scope": "agent"
        },
        "tools": {
          "allow": ["tool1", "tool2"],
          "deny": ["tool3"]
        }
      }
    ]
  },
  "bindings": [
    {
      "agentId": "agent-id",
      "match": {
        "channel": "whatsapp|telegram|discord|slack",
        "accountId": "account-name",
        "peer": {
          "kind": "direct|group",
          "id": "peer-identifier"
        }
      }
    }
  ],
  "channels": {
    "whatsapp": { "dmPolicy": "allowlist", "allowFrom": ["+1..."] },
    "telegram": { "accounts": { "bot-name": { "token": "env:TELEGRAM_TOKEN" } } },
    "discord": { "accounts": { "bot-name": { "token": "env:DISCORD_TOKEN" } } }
  },
  "mcp": {
    "servers": {
      "server-name": {
        "type": "stdio",
        "command": "npx",
        "args": ["-y", "@package/mcp-server"],
        "env": { "API_KEY": "env:API_KEY" }
      }
    }
  }
}
```

### Routing Rules (priority order)
1. peer match (exact DM/group/channel id)
2. parentPeer match (thread inheritance)
3. guildId + roles (Discord role routing)
4. guildId (Discord)
5. teamId (Slack)
6. accountId match for a channel
7. channel-level match (accountId: "*")
8. fallback to default agent (first in list or marked default)

---

## Skills System

### SKILL.md Format
```markdown
---
name: skill_name
description: What this skill does and when to use it
emoji: 🔧
requires:
  bins: [ffmpeg, yt-dlp]
  env: [YOUTUBE_API_KEY]
  config: [youtube.channel_id]
install: |
  pip install yt-dlp
---

# Skill Name

## Description
Explain what this skill does and when the agent should use it.

## Usage
Show example commands the user might give.

## Implementation
Step-by-step instructions for the agent to follow.

## Guardrails
What the agent should NOT do with this skill.

## Output Format
How results should be formatted and presented.
```

### Skill Locations
- **Shared**: `~/.openclaw/skills/` — available to ALL agents
- **Workspace**: `<workspace>/skills/` — only for that specific agent
- **Bundled**: Shipped with OpenClaw install (50+ built-in)

---

## Workflows System

Workflows are autonomous agents with STATE and LEARNING. Unlike skills (called on demand), workflows run on schedule.

### AGENT.md (Workflow Algorithm)
- The algorithm/process the workflow follows
- Updates with the wrapper/skill package
- Defines the step-by-step autonomous behavior

### rules.md (User Preferences)
- User's personal rules and preferences
- NEVER overwritten by updates
- The user customizes this file

### agent_notes.md (Learned Patterns)
- Patterns the workflow has learned over time
- Grows organically through operation
- Self-improving behavior log

### logs/ (Execution History)
- Timestamped execution records
- Used for debugging and pattern analysis
