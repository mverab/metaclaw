# Skill Templates by Domain

Pre-built SKILL.md templates for common domains. The metaclaw-setup-architect uses these as starting points when generating custom skills for a setup.

---

## How to Use

When generating a setup, pick the relevant domain templates below and customize them based on the user's specific requirements. Each template is a complete SKILL.md ready to be placed in `skills/{skill-name}/SKILL.md`.

---

## Web Scraping & Monitoring

```markdown
---
name: web_monitor
description: Monitor web sources for new content, trends, and updates. Scrapes RSS feeds, social media, and websites on a schedule.
emoji: 🔍
requires:
  bins: []
  env: []
---

# Web Monitor

## When to Use
When you need to check web sources for new content, trending topics, or updates relevant to the user's domain.

## Implementation
1. Read the list of sources from memory/SYSTEM.md under "## Monitored Sources"
2. For each source:
   - RSS feeds: Parse and extract new entries since last check
   - Websites: Use browser tool to scrape and extract relevant content
   - Social media: Use appropriate API to fetch recent posts
3. Filter results by relevance to the user's defined topics
4. Compile a summary of findings
5. Save raw data to memory/YYYY-MM-DD.md under "## Web Monitor Results"
6. If high-priority items found, notify the user immediately

## Sources Format (in SYSTEM.md)
```
## Monitored Sources
- RSS: https://example.com/feed
- Website: https://example.com/blog (selector: .post-title)
- Twitter: @username (keywords: AI, automation)
```

## Output Format
For each finding:
- **Source**: Where it came from
- **Title**: Headline or summary
- **Relevance**: Why it matters (1 sentence)
- **Link**: URL to original

## Guardrails
- Never scrape more than 20 pages per session
- Respect robots.txt
- Cache results to avoid duplicate notifications
```

---

## Content Generation

```markdown
---
name: content_generator
description: Generate content in the user's voice and style. Supports posts, articles, newsletters, scripts.
emoji: ✍️
requires:
  env: []
---

# Content Generator

## When to Use
When the user asks to create content or when a workflow triggers content generation.

## Implementation
1. Read the user's brand voice profile from SOUL.md
2. Read content strategy from memory/SYSTEM.md under "## Content Strategy"
3. Based on the content type requested:
   - **Short post** (X/Twitter, LinkedIn): 280 chars max, hook + value + CTA
   - **Long post** (blog, newsletter): Structure with headers, intro → body → conclusion
   - **Video script**: Hook (first 3 seconds) → problem → solution → CTA
   - **Newsletter**: Subject line + preview text + sections + CTA
4. Generate draft following the user's voice profile
5. Present draft for review

## Voice Calibration
Read SOUL.md for tone, vocabulary, and style preferences. Key aspects:
- Formality level (casual / professional / mixed)
- Vocabulary patterns (technical jargon / simple language)
- Sentence structure (short punchy / flowing narrative)
- Signature phrases or expressions

## Output Format
Present the content with clear labeling:
```
**Type**: [post/article/script/newsletter]
**Platform**: [where it will be published]
**Word count**: [number]

---
[Content here]
---

Ready to publish? Reply APPROVE or suggest changes.
```

## Guardrails
- Always match the user's voice — never sound generic
- Never fabricate quotes, statistics, or citations
- Flag if content could be controversial or sensitive
```

---

## Video Processing

```markdown
---
name: video_processor
description: Download, analyze, clip, and process videos. Handles YouTube downloads, transcription, clipping, and subtitle generation.
emoji: 🎬
requires:
  bins: [yt-dlp, ffmpeg, whisper]
  env: []
install: |
  pip install yt-dlp openai-whisper
  brew install ffmpeg
---

# Video Processor

## When to Use
When the user needs to download videos, extract transcripts, create clips, or process video/audio files.

## Implementation

### Download Video
```bash
yt-dlp -f "bestvideo[height<=1080]+bestaudio" -o "%(title)s.%(ext)s" "{url}"
```

### Extract Audio Only
```bash
yt-dlp -x --audio-format mp3 -o "%(title)s.%(ext)s" "{url}"
```

### Get Transcript
```bash
yt-dlp --write-auto-sub --sub-lang en --skip-download -o "%(title)s" "{url}"
```
Or use Whisper for better quality:
```bash
whisper "{audio_file}" --model medium --output_format srt
```

### Clip Video
```bash
ffmpeg -i "{input}" -ss {start_time} -to {end_time} -c copy "{output}"
```

### Add Subtitles
```bash
ffmpeg -i "{input}" -vf "subtitles={srt_file}:force_style='FontSize=24'" "{output}"
```

### Create Vertical (9:16) from Horizontal
```bash
ffmpeg -i "{input}" -vf "crop=ih*9/16:ih,scale=1080:1920" "{output}"
```

## Guardrails
- Always check video license/copyright before processing
- Max video length for full processing: 3 hours
- Store processed files in workspace, not in memory
- Clean up temporary files after processing
```

---

## Data Analysis & Reporting

```markdown
---
name: data_analyst
description: Analyze data from various sources, generate reports, and visualize trends. Works with APIs, spreadsheets, and databases.
emoji: 📊
requires:
  env: []
---

# Data Analyst

## When to Use
When the user needs data pulled, analyzed, compared, or reported on.

## Implementation
1. Identify data source (API, spreadsheet, database, web scrape)
2. Fetch the data using appropriate tool
3. Clean and normalize the data
4. Analyze based on user's question:
   - Trends over time
   - Comparisons between metrics
   - Anomaly detection
   - Summary statistics
5. Present findings in a clear format
6. Save report to memory/YYYY-MM-DD.md

## Output Format
```
## Report: [Title]
**Period**: [date range]
**Source**: [where data came from]

### Key Findings
1. [Most important insight]
2. [Second insight]
3. [Third insight]

### Metrics
| Metric | Current | Previous | Change |
|--------|---------|----------|--------|
| ...    | ...     | ...      | ...    |

### Recommendations
- [Action item based on data]
```

## Guardrails
- Always cite data sources
- Flag uncertainty when sample sizes are small
- Never extrapolate beyond what the data supports
```

---

## Community Management

```markdown
---
name: community_manager
description: Monitor and manage online community interactions. Answer questions, find relevant content, track engagement, and assist members.
emoji: 👥
requires:
  env: []
---

# Community Manager

## When to Use
When managing a community platform (Skool, Discord, Circle, etc.) — answering questions, finding lessons, welcoming members, tracking engagement.

## Implementation

### Answer Questions
1. When a member asks a question, search the knowledge base first
2. Check memory/SYSTEM.md for "## FAQ" section
3. Search published lessons/content using RAG or browser tool
4. If answer found: respond with source link and summary
5. If not found: flag for human review and provide best-effort response

### Find Relevant Content
1. Parse the member's question for keywords and intent
2. Search published lessons, posts, and resources
3. Rank results by relevance
4. Present top 3 results with direct links

### Welcome New Members
1. Detect new member join events
2. Send personalized welcome message (read template from SYSTEM.md)
3. Suggest first steps and key resources
4. Log new member in memory

### Track Engagement
1. Monitor unanswered questions (older than 24h)
2. Track most active topics
3. Identify members who might need attention
4. Weekly engagement report to owner

## Output Format
When answering members:
```
Hey [name]! Great question 👋

[Answer here]

📚 Related resources:
- [Lesson Title](link) — [1-line description]
- [Post Title](link) — [1-line description]

Hope that helps! Let me know if you need anything else.
```

## Guardrails
- Always be friendly and helpful
- Never share private member information
- Escalate sensitive issues to human owner
- Don't answer medical, legal, or financial advice
```

---

## SEO & Marketing

```markdown
---
name: seo_operator
description: Execute SEO workflows — keyword research, content optimization, backlink outreach, and performance monitoring.
emoji: 🔎
requires:
  env: [SEARCH_CONSOLE_API_KEY]
---

# SEO Operator

## When to Use
When running SEO tasks — finding keywords, optimizing content, building backlinks, or monitoring rankings.

## Implementation

### Keyword Research
1. Start with seed keyword from user
2. Use web search to find related terms
3. Check Search Console for existing ranking keywords
4. Classify keywords by intent: informational, transactional, navigational
5. Prioritize by: search volume estimate × relevance × competition gap
6. Output keyword clusters with content recommendations

### Content Optimization
1. Read the target content
2. Check for: title tag, meta description, H1, H2 structure, keyword density
3. Compare against top-ranking pages for the target keyword
4. Suggest specific improvements with before/after examples
5. Check internal linking opportunities

### Backlink Outreach
1. Find relevant websites in the niche using web search
2. Identify contact information (email, contact form)
3. Draft personalized outreach email based on template in SYSTEM.md
4. Log outreach attempts in memory/YYYY-MM-DD.md
5. Track responses and follow up after 3 days

### Performance Monitoring
1. Pull data from Search Console API
2. Compare current period vs previous period
3. Identify: ranking improvements, drops, new keywords, lost keywords
4. Generate weekly performance report

## Guardrails
- Max 10 outreach emails per day
- Never use spammy or manipulative SEO tactics
- Always disclose AI-generated content when required
- Respect nofollow and noindex directives
```

---

## Task & Workflow Automation

```markdown
---
name: task_automator
description: Automate recurring tasks, manage to-do lists, and execute multi-step workflows based on triggers and schedules.
emoji: ⚡
requires:
  env: []
---

# Task Automator

## When to Use
When automating recurring tasks, managing task lists, or executing multi-step workflows.

## Implementation

### Create Task
1. Parse task description from user input
2. Classify: priority (high/medium/low), category, deadline
3. Add to task list in memory/SYSTEM.md under "## Active Tasks"
4. Set reminder if deadline provided

### Execute Workflow
1. Read workflow definition from workflows/{name}/AGENT.md
2. Follow steps sequentially
3. At each step: execute, verify result, log outcome
4. If step fails: retry once, then flag for human review
5. Update agent_notes.md with lessons learned

### Daily Review
1. Check all active tasks
2. Identify overdue items
3. Suggest task priorities for the day
4. Present summary to user

## Guardrails
- Never delete completed tasks — move to "## Completed" section
- Always confirm destructive actions with the user
- Log every workflow execution in logs/
```
