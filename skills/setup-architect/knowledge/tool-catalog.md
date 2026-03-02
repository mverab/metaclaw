# Tool & MCP Catalog

Categorized registry of tools, MCP servers, and APIs available for OpenClaw setups. Use this to recommend the right tools based on the user's use case.

---

## How to Use This Catalog

When designing a setup, match the user's requirements to tool categories. Prefer MCP servers over raw API calls when available — they integrate natively with OpenClaw's tool system.

**Format**: Each entry shows `tool-name` — what it does — `type` (mcp/native/cli/api)

---

## 1. Web & Browser Automation

| Tool | Description | Type |
|------|-------------|------|
| `browser` | OpenClaw built-in browser tool (navigate, click, extract) | native |
| `playwright-mcp` | Full browser automation — forms, screenshots, testing | mcp |
| `puppeteer-mcp` | Headless Chrome automation | mcp |
| `browser-use` | AI-driven web page operation — "sees" and "operates" pages | mcp |
| `web-search` | Built-in web search capability | native |
| `brave-search` | Privacy-focused web search API | mcp |
| `google-search` | Google Custom Search API | api |
| `serpapi` | Search engine results page scraping | api |
| `firecrawl` | Web scraping and crawling at scale | mcp |
| `url-to-markdown` | Convert any webpage to clean markdown | cli |

**Common use cases**: Research agents, SEO tools, content scrapers, monitoring bots

---

## 2. Filesystem & Code

| Tool | Description | Type |
|------|-------------|------|
| `read` | Read file contents | native |
| `write` | Write/create files | native |
| `edit` | Edit existing files | native |
| `exec` | Execute shell commands | native |
| `apply_patch` | Apply code patches | native |
| `filesystem-mcp` | Advanced filesystem operations (search, glob, watch) | mcp |
| `git-mcp` | Git operations — commit, branch, diff, log | mcp |
| `github-mcp` | GitHub API — repos, issues, PRs, actions | mcp |
| `gitlab-mcp` | GitLab API — repos, pipelines, merge requests | mcp |

**Common use cases**: Dev teams, code generation, file management, version control

---

## 3. Video & Media

| Tool | Description | Type |
|------|-------------|------|
| `yt-dlp` | Download YouTube videos, extract audio, get transcripts | cli |
| `ffmpeg` | Video/audio processing — cut, merge, transcode, filters | cli |
| `whisper` | Speech-to-text transcription (OpenAI or local) | cli/api |
| `remotion` | Programmatic video creation with React | cli |
| `imagemagick` | Image processing — resize, convert, compose | cli |
| `sharp` | High-performance image processing (Node.js) | cli |
| `peekaboo` | macOS screenshot capture | mcp |
| `dall-e` | AI image generation (OpenAI) | api |
| `imagen` | AI image generation (Google) | api |
| `midjourney-api` | AI image generation (Midjourney) | api |
| `elevenlabs` | AI voice synthesis and cloning | api |
| `heygen` | AI video generation with avatars | api |

**Common use cases**: Content creation, YouTube clipping, thumbnail generation, podcast processing

---

## 4. Communication Channels

| Tool | Description | Type |
|------|-------------|------|
| `whatsapp` | WhatsApp messaging (built-in OpenClaw channel) | native |
| `telegram` | Telegram bot messaging (built-in OpenClaw channel) | native |
| `discord` | Discord bot messaging (built-in OpenClaw channel) | native |
| `slack` | Slack workspace messaging (built-in OpenClaw channel) | native |
| `email-mcp` | Email send/receive via SMTP/IMAP | mcp |
| `imessage` | macOS iMessage integration | native |
| `twilio` | SMS and voice calls | api |
| `sendgrid` | Transactional email | api |
| `resend` | Developer-first email API | api |

**Common use cases**: Multi-channel bots, notification systems, outreach automation

---

## 5. AI Models & Providers

| Tool | Description | Type |
|------|-------------|------|
| `openai` | GPT-4o, o1, o3, Codex, DALL-E, Whisper | api |
| `anthropic` | Claude Opus, Sonnet, Haiku | api |
| `google` | Gemini Pro, Flash, Imagen | api |
| `ollama` | Local model hosting (Llama, Qwen, Mistral, etc.) | cli |
| `openrouter` | Multi-provider model routing | api |
| `groq` | Ultra-fast inference (Llama, Mixtral) | api |
| `together` | Open-source model hosting | api |
| `fireworks` | Fast inference for open models | api |
| `codex-cli` | OpenAI Codex for code generation via CLI | cli |
| `claude-code` | Anthropic's coding agent | cli |

**Multi-model routing pattern**:
```json
{
  "agents": {
    "defaults": {
      "model": "anthropic/claude-opus-4",
      "models": {
        "coding": "openai/codex-mini",
        "research": "google/gemini-2.5-flash",
        "creative": "anthropic/claude-sonnet-4",
        "fast": "groq/llama-4-scout"
      }
    }
  }
}
```

---

## 6. Data & Knowledge

| Tool | Description | Type |
|------|-------------|------|
| `rag-mcp` | Retrieval-Augmented Generation over local documents | mcp |
| `sqlite-mcp` | SQLite database operations | mcp |
| `postgres-mcp` | PostgreSQL database operations | mcp |
| `supabase-mcp` | Supabase (Postgres + Auth + Storage + Realtime) | mcp |
| `pinecone` | Vector database for embeddings | api |
| `chromadb` | Local vector database | cli |
| `redis-mcp` | Redis key-value store | mcp |
| `notion-mcp` | Notion pages, databases, blocks | mcp |
| `obsidian-mcp` | Obsidian vault access | mcp |
| `google-sheets-mcp` | Google Sheets read/write | mcp |
| `airtable-mcp` | Airtable bases and records | mcp |

**Common use cases**: Knowledge bases, RAG systems, data pipelines, CRM

---

## 7. Productivity & Project Management

| Tool | Description | Type |
|------|-------------|------|
| `google-calendar-mcp` | Calendar events — create, read, update | mcp |
| `asana-mcp` | Task and project management | mcp |
| `linear-mcp` | Issue tracking for dev teams | mcp |
| `todoist-mcp` | Personal task management | mcp |
| `trello-mcp` | Kanban board management | mcp |
| `google-drive-mcp` | Google Drive file management | mcp |
| `dropbox-mcp` | Dropbox file management | mcp |

**Common use cases**: Task automation, scheduling, project coordination

---

## 8. Marketing & SEO

| Tool | Description | Type |
|------|-------------|------|
| `search-console-mcp` | Google Search Console — rankings, clicks, impressions | mcp |
| `analytics-mcp` | Google Analytics — traffic, events, conversions | mcp |
| `semrush-api` | SEO research — keywords, competitors, backlinks | api |
| `ahrefs-api` | SEO research and backlink analysis | api |
| `mailchimp-mcp` | Email marketing campaigns | mcp |
| `hubspot-mcp` | CRM + marketing automation | mcp |
| `buffer-api` | Social media scheduling | api |
| `hootsuite-api` | Social media management | api |
| `twitter-api` | X/Twitter posting and monitoring | api |
| `reddit-api` | Reddit browsing and posting | api |
| `rss-reader` | RSS feed monitoring and parsing | cli |

**Common use cases**: SEO automation, content distribution, outreach, analytics

---

## 9. Commerce & Payments

| Tool | Description | Type |
|------|-------------|------|
| `stripe-mcp` | Payments, subscriptions, invoices | mcp |
| `shopify-mcp` | E-commerce store management | mcp |
| `woocommerce-api` | WordPress e-commerce | api |
| `gumroad-api` | Digital product sales | api |
| `lemonsqueezy-api` | SaaS billing and licensing | api |

**Common use cases**: E-commerce agents, billing automation, product management

---

## 10. Deployment & DevOps

| Tool | Description | Type |
|------|-------------|------|
| `vercel-mcp` | Vercel deployment and management | mcp |
| `netlify-mcp` | Netlify deployment and management | mcp |
| `docker-mcp` | Docker container management | mcp |
| `cloudflare-mcp` | Cloudflare DNS, Workers, Pages | mcp |
| `aws-mcp` | AWS services (S3, Lambda, EC2, etc.) | mcp |
| `railway-mcp` | Railway app deployment | mcp |
| `fly-mcp` | Fly.io deployment and scaling | mcp |

**Common use cases**: CI/CD pipelines, infrastructure management, deployment automation

---

## 11. Health & Fitness

| Tool | Description | Type |
|------|-------------|------|
| `apple-health-mcp` | Apple Health data — steps, heart rate, sleep, workouts | mcp |
| `fitbit-api` | Fitbit health and activity data | api |
| `nutritionix-api` | Food and nutrition database | api |
| `instacart-api` | Grocery delivery | api |
| `openai-vision` | Food recognition from photos | api |

**Common use cases**: Health coaching, meal tracking, fitness automation

---

## 12. Community & Education

| Tool | Description | Type |
|------|-------------|------|
| `skool-api` | Skool community management (web scraping based) | browser |
| `circle-api` | Circle community platform | api |
| `discourse-api` | Discourse forum management | api |
| `teachable-api` | Online course platform | api |
| `youtube-data-api` | YouTube channel and video management | api |
| `loom-api` | Video recording and sharing | api |

**Common use cases**: Community assistants, course management, member engagement

---

## MCP Server Configuration Pattern

```json
{
  "mcp": {
    "servers": {
      "server-name": {
        "type": "stdio",
        "command": "npx",
        "args": ["-y", "@package/mcp-server-name"],
        "env": {
          "API_KEY": "env:SERVICE_API_KEY"
        }
      }
    }
  }
}
```

For Python-based MCP servers:
```json
{
  "mcp": {
    "servers": {
      "server-name": {
        "type": "stdio",
        "command": "uvx",
        "args": ["mcp-server-name"],
        "env": {
          "API_KEY": "env:SERVICE_API_KEY"
        }
      }
    }
  }
}
```
