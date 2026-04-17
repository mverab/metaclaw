# MetaClaw Founder Branding Assets Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Generate production-ready, founder-focused branding assets (logo, banner, social preview) via OpenAI image generation and integrate them into the repository.

**Architecture:** Use a single prompt system with shared style constraints to keep visual consistency across three asset types. Generate multiple candidates per asset, score against a fixed rubric, select one winner per slot, and wire selected outputs into README references.

**Tech Stack:** OpenAI CLI (`openai api images.generate`), shell scripts, Markdown docs, Git repo assets.

---

### Task 1: Validate prerequisites and establish output structure

**Files:**
- Create: `assets/branding/generated/.gitkeep`
- Modify: `assets/branding/brand-guide.md`

**Step 1: Create output directory scaffold**

Run: `mkdir -p assets/branding/generated/{logo,banner,social} && touch assets/branding/generated/.gitkeep`
Expected: directories exist and are empty.

**Step 2: Document generation constraints**

Add to `assets/branding/brand-guide.md` a short section with:
- founder-first audience
- abstract MetaLayer visual rule
- minimal text rule (`MetaClaw`, `Setup Architect` only)

**Step 3: Verify scaffold and guide update**

Run: `find assets/branding/generated -maxdepth 2 -type d | sort`
Expected: `logo`, `banner`, `social` directories present.

### Task 2: Define final prompt set and generation matrix

**Files:**
- Modify: `assets/branding/prompts.md`

**Step 1: Write canonical base style block**

Include: palette, geometry, contrast, exclusions.

**Step 2: Write per-asset prompts and negative prompts**

Add exactly:
- 3 logo prompts
- 3 banner prompts
- 2 social prompts

**Step 3: Add filename mapping table**

Map each prompt to file output name:
- `logo-01.png` ...
- `banner-01.png` ...
- `social-01.png` ...

**Step 4: Verify prompt file completeness**

Run: `rg -n "^## Logo|^## Banner|^## Social|Negative prompt|logo-01|banner-01|social-01" assets/branding/prompts.md`
Expected: all sections and mappings present.

### Task 3: Generate logo candidates with OpenAI imagegen

**Files:**
- Create: `assets/branding/generated/logo/logo-01.png`
- Create: `assets/branding/generated/logo/logo-02.png`
- Create: `assets/branding/generated/logo/logo-03.png`

**Step 1: Run generation for logo prompt 1**

Run (example):
`openai api images.generate -m gpt-image-1 -p "<logo prompt 1>" -s 1024x1024 --response-format b64_json | jq -r '.data[0].b64_json' | base64 -d > assets/branding/generated/logo/logo-01.png`
Expected: `logo-01.png` exists and opens.

**Step 2: Repeat for prompts 2 and 3**

Expected: `logo-02.png`, `logo-03.png` exist.

**Step 3: Quick technical validation**

Run: `file assets/branding/generated/logo/logo-0*.png`
Expected: each reports valid PNG image data.

### Task 4: Generate banner candidates with OpenAI imagegen

**Files:**
- Create: `assets/branding/generated/banner/banner-01.png`
- Create: `assets/branding/generated/banner/banner-02.png`
- Create: `assets/branding/generated/banner/banner-03.png`

**Step 1: Generate three banner images**

Use `-s 1536x1024` (or nearest supported) and later crop/fit to banner target if required.

**Step 2: Validate outputs**

Run: `file assets/branding/generated/banner/banner-0*.png`
Expected: all valid PNG.

### Task 5: Generate social preview candidates with OpenAI imagegen

**Files:**
- Create: `assets/branding/generated/social/social-01.png`
- Create: `assets/branding/generated/social/social-02.png`

**Step 1: Generate two social images**

Use target close to OG ratio (e.g., `1536x1024` then crop/fit to 1200x630).

**Step 2: Validate outputs**

Run: `file assets/branding/generated/social/social-0*.png`
Expected: valid PNG files.

### Task 6: Select winners and publish canonical assets

**Files:**
- Modify: `assets/branding/logo.png`
- Modify: `assets/branding/banner.png`
- Modify: `assets/branding/social-preview.png`
- Modify: `assets/branding/prompts.md`

**Step 1: Score candidates using 4-point rubric**

Rubric:
1. Legibility
2. Visual consistency
3. Founder-grade credibility
4. Distinctiveness

**Step 2: Copy selected winners into canonical file names**

Run examples:
- `cp assets/branding/generated/logo/logo-0X.png assets/branding/logo.png`
- `cp assets/branding/generated/banner/banner-0X.png assets/branding/banner.png`
- `cp assets/branding/generated/social/social-0X.png assets/branding/social-preview.png`

**Step 3: Record winner IDs in prompts doc**

Add selected prompt IDs and rationale.

### Task 7: Integrate assets into README and verify install flow

**Files:**
- Modify: `README.md`

**Step 1: Update image references to PNG canonical files**

Ensure header banner points to `assets/branding/banner.png`.

**Step 2: Preserve lightweight niche section**

Keep max 3 bullets, founder-first phrasing.

**Step 3: Verify install command order**

Run: `rg -n "npx skills add mverab/metaclaw --skill metaclaw-setup-architect|npx skills add mverab/metaclaw --list|/absolute/path/to/metaclaw --list" README.md`
Expected: commands appear in canonical order.

### Task 8: End-to-end validation and completion marker

**Files:**
- Modify: `spec/changes/add-repo-branding-for-skills-ranking/IMPLEMENTED`

**Step 1: Validate remote skill discovery**

Run: `npx -y skills add mverab/metaclaw --list`
Expected: one skill `metaclaw-setup-architect` is listed.

**Step 2: Save completion timestamp**

Run:
`echo "Implementation completed: $(date '+%Y-%m-%d %H:%M:%S %Z')" > spec/changes/add-repo-branding-for-skills-ranking/IMPLEMENTED`

**Step 3: Final sanity checks**

Run:
- `git status --short`
- `ls -la assets/branding`
- `ls -la assets/branding/generated/logo assets/branding/generated/banner assets/branding/generated/social`

