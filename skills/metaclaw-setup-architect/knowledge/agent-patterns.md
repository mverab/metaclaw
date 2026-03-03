# Multi-Agent Architecture Patterns

Reusable patterns for designing multi-agent OpenClaw setups. Use this to recommend the right architecture based on the user's requirements.

---

## How to Choose a Pattern

| If the user needs... | Use this pattern |
|---------------------|-----------------|
| Sequential processing (A → B → C) | Pipeline |
| One coordinator + specialized workers | Hub-and-Spoke |
| Self-running recurring tasks | Autonomous Loop |
| Agent proposes, human decides | Human-in-the-Loop |
| Agent watches and corrects other agents | Supervisor |
| Multiple patterns combined | Hybrid (combine 2-3) |

---

## 1. Pipeline Pattern

**When to use**: Tasks that flow through sequential stages where each stage transforms the output of the previous one.

```
[Input] → Agent A (collect) → Agent B (process) → Agent C (output) → [Result]
```

### Characteristics
- Each agent has a single, focused responsibility
- Output of one agent feeds into the next
- Easy to debug — you can inspect each stage
- Can run asynchronously with message queues

### Example: Content Pipeline
```
scout (scrape sources) → writer (draft content) → editor (refine + format) → publisher (schedule + post)
```

### Implementation Notes
- Each agent gets its own workspace: `~/.openclaw/workspace-{stage}/`
- Use Telegram/Discord channels per stage for inter-agent communication
- The first agent triggers the chain; subsequent agents listen for output
- HEARTBEAT.md on the first agent sets the pipeline cadence

### openclaw.json skeleton
```json
{
  "agents": {
    "list": [
      { "id": "collector", "workspace": "~/.openclaw/workspace-collector" },
      { "id": "processor", "workspace": "~/.openclaw/workspace-processor" },
      { "id": "publisher", "workspace": "~/.openclaw/workspace-publisher" }
    ]
  },
  "bindings": [
    { "agentId": "collector", "match": { "channel": "telegram", "peer": { "kind": "group", "id": "pipeline-input" } } },
    { "agentId": "processor", "match": { "channel": "telegram", "peer": { "kind": "group", "id": "pipeline-process" } } },
    { "agentId": "publisher", "match": { "channel": "telegram", "peer": { "kind": "group", "id": "pipeline-output" } } }
  ]
}
```

---

## 2. Hub-and-Spoke Pattern

**When to use**: A central coordinator delegates tasks to specialized agents and aggregates results.

```
              ┌─ Specialist A
              │
Coordinator ──┼─ Specialist B
              │
              └─ Specialist C
```

### Characteristics
- One "brain" agent that understands the full picture
- Specialist agents with deep skills in narrow domains
- Coordinator decides WHO does WHAT
- Good for complex, multi-domain tasks

### Example: Dev Team
```
lead-dev (coordinator) ──┬── frontend (React/Next.js specialist)
                         ├── backend (API/database specialist)
                         ├── qa (testing specialist)
                         └── devops (deployment specialist)
```

### Implementation Notes
- Coordinator uses a Discord server with separate channels per specialist
- Each specialist has domain-specific skills and tool access
- Coordinator's AGENTS.md includes routing logic: "for UI tasks, delegate to #frontend channel"
- Specialists have restricted tools (sandbox mode) for safety

### openclaw.json skeleton
```json
{
  "agents": {
    "list": [
      { "id": "coordinator", "workspace": "~/.openclaw/workspace-coordinator", "default": true },
      { "id": "frontend", "workspace": "~/.openclaw/workspace-frontend", "sandbox": { "mode": "all" } },
      { "id": "backend", "workspace": "~/.openclaw/workspace-backend", "sandbox": { "mode": "all" } },
      { "id": "qa", "workspace": "~/.openclaw/workspace-qa", "tools": { "allow": ["read", "exec"], "deny": ["write"] } }
    ]
  }
}
```

---

## 3. Autonomous Loop Pattern

**When to use**: An agent that operates continuously on a schedule without human intervention.

```
┌─────────────────────────────────┐
│  HEARTBEAT triggers             │
│       ↓                         │
│  Check conditions/sources       │
│       ↓                         │
│  Execute tasks                  │
│       ↓                         │
│  Log results + update memory    │
│       ↓                         │
│  Report to human (if needed)    │
│       ↓                         │
│  Sleep until next heartbeat     │
└─────────────────────────────────┘
```

### Characteristics
- Single agent with a HEARTBEAT.md schedule
- Checks conditions, acts, reports
- Self-improving through memory/agent_notes
- Minimal human intervention needed

### Example: SEO Monitor
```
Every 6 hours:
  1. Check Search Console rankings
  2. Identify drops or opportunities
  3. Generate/update content as needed
  4. Send outreach emails for backlinks
  5. Log results in memory/YYYY-MM-DD.md
  6. Report summary via WhatsApp
```

### Implementation Notes
- Single agent workspace with robust HEARTBEAT.md
- Workflow directory with AGENT.md defining the loop algorithm
- Memory system tracks state between cycles
- WhatsApp/Telegram for human notifications only

### HEARTBEAT.md skeleton
```markdown
# Heartbeat Schedule

## Every 6 hours
- Check rankings in Search Console
- Review content performance
- Identify keyword opportunities

## Daily (9am)
- Generate content for top opportunities
- Send outreach emails (max 10/day)
- Update memory with results

## Weekly (Monday 9am)
- Full performance report via WhatsApp
- Strategy review and plan adjustment
- Memory cleanup and promotion
```

---

## 4. Human-in-the-Loop Pattern

**When to use**: Agent does the work but requires human approval before executing high-stakes actions.

```
Agent works autonomously
       ↓
Reaches decision point
       ↓
Sends proposal to human (WhatsApp/Telegram)
       ↓
Human approves / modifies / rejects
       ↓
Agent executes (or adjusts)
```

### Characteristics
- Agent proposes, human disposes
- Good for financial decisions, public communications, irreversible actions
- Builds trust gradually — can loosen approval requirements over time
- Uses messaging channels as the approval interface

### Example: Content Publishing
```
Agent drafts 5 social posts for the week
  → Sends to WhatsApp: "Here are this week's posts. Reply APPROVE or edit any you want changed"
  → Human reviews and approves
  → Agent schedules approved posts
```

### Implementation Notes
- AGENTS.md includes clear "APPROVAL REQUIRED" sections listing what needs human sign-off
- Agent uses MEMORY.md to track approval patterns and learn preferences
- Over time, move low-risk actions to auto-approve based on confidence
- Use structured message formats so human can respond quickly

### AGENTS.md snippet
```markdown
## Approval Policy

### Always ask before:
- Publishing any content publicly
- Sending emails to external contacts
- Making purchases or financial transactions
- Deleting or modifying production data

### Auto-approved:
- Research and data gathering
- Draft creation and internal notes
- File organization and cleanup
- Routine monitoring and reporting
```

---

## 5. Supervisor Pattern

**When to use**: One agent monitors and corrects the behavior of other agents.

```
Supervisor (watches all)
    ↓           ↓           ↓
Agent A     Agent B     Agent C
(watched)   (watched)   (watched)
```

### Characteristics
- Supervisor has read access to all agent workspaces
- Monitors logs, outputs, and memory for quality
- Can intervene: correct, pause, or restart agents
- Acts as quality control layer

### Example: Quality Assurance
```
supervisor monitors:
  - content-agent: checks for brand voice consistency, factual accuracy
  - dev-agent: reviews code quality, security issues
  - outreach-agent: monitors response rates, flags failures
```

### Implementation Notes
- Supervisor has tools to read other agents' workspaces and logs
- Uses its own HEARTBEAT to periodically review agent outputs
- Can send messages to other agents' channels to correct behavior
- Stability plugin (if installed) provides behavioral monitoring

---

## 6. Hybrid Patterns

Most real-world setups combine 2-3 patterns. Common combinations:

### Pipeline + Human-in-the-Loop
```
collect → process → [HUMAN APPROVAL] → publish
```

### Hub-and-Spoke + Autonomous Loop
```
Coordinator assigns daily tasks to specialists on a schedule
```

### Autonomous Loop + Supervisor
```
Worker agents run on loops; supervisor monitors quality
```

---

## Choosing Number of Agents

| Complexity | Agents | Pattern |
|-----------|--------|---------|
| Simple automation | 1 | Autonomous Loop |
| Two-stage pipeline | 2 | Pipeline |
| Multi-domain work | 3-4 | Hub-and-Spoke |
| Full team simulation | 4-6 | Hub-and-Spoke + Supervisor |
| Enterprise pipeline | 5+ | Pipeline + Supervisor |

**Rule of thumb**: Start with fewer agents and split only when an agent's AGENTS.md exceeds ~200 lines or its responsibilities clearly span different domains.

---

## Communication Between Agents

| Method | Best for | Setup |
|--------|----------|-------|
| Discord channels | Structured multi-agent work | One channel per agent/stage |
| Telegram groups | Quick inter-agent messaging | Bot per agent in shared group |
| Shared files | Async data passing | Shared workspace directory |
| WhatsApp | Human notification only | DM to human for approvals/reports |

**Best practice**: Use Discord for agent-to-agent communication (channels per agent) and WhatsApp/Telegram for human-facing communication.
