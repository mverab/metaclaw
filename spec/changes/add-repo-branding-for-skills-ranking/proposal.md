# Proposal: Improve MetaClaw Public Repo Branding for Skills Ranking

## Why

The repo is functional, but first impression and install conversion can improve with clear branded assets. The immediate goal is to increase trust and click-to-install behavior without adding complex systems.

**Context**:
- `skills.sh` ranking is influenced by real installs.
- Visual identity (logo/banner/social card) is currently not standardized for distribution.
- README already has install commands, but positioning can be tightened around niche outcomes.

**Current state**: Installable repo with limited visual branding assets.

**Desired state**: A lightweight, consistent public presentation that improves conversion and supports ranking growth.

## What Changes

- Create a minimal branding kit using AI image generation: logo, repo banner, and social preview image.
- Add one concise “Who this is for” section with 3 niche profiles and outcomes.
- Keep Quick Start command path simple and prominent (GitHub install first).
- Add a short asset guideline so future updates stay consistent.

## Impact

### Affected Specifications
- `spec/specs/skills-ranking/spec.md` - New lightweight requirements for branding and conversion.

### Affected Code
- `README.md` - Niche framing + CTA clarity.
- New assets folder (proposed): `assets/branding/`.

### User Impact
- Faster trust and understanding for first-time visitors.
- Better clarity on whether the skill fits their use case.

### API Changes
- None.

### Migration Required
- [ ] Database migration
- [ ] API version bump
- [ ] User communication needed
- [x] Documentation updates

## Timeline Estimate

Small (1-2 focused days).

## Risks

- Branding over-style may reduce readability; mitigate with a strict readability check.
- Niche copy could become too generic; mitigate by tying each niche to a concrete outcome.
