# Spec Delta: Skills Ranking

This file contains specification changes for `spec/specs/skills-ranking/spec.md`.

## ADDED Requirements

### Requirement: Repository Branding Asset Set
WHEN preparing a public release of the MetaClaw skill,
the system SHALL provide one approved logo, one approved repository banner, and one approved social preview image.

#### Scenario: Asset set is complete
GIVEN a release candidate is ready
WHEN branding validation is executed
THEN the release includes exactly one selected logo
AND one selected banner
AND one selected social preview image.

#### Scenario: Asset is unreadable
GIVEN a generated asset with low text contrast
WHEN visual quality review is executed
THEN the asset is rejected
AND a replacement asset is generated before release.

### Requirement: Lightweight Niche Positioning in README
WHEN a user visits the public README,
the system SHALL present a concise niche section with no more than three niche profiles and one concrete outcome per niche.

#### Scenario: Niche section is concise
GIVEN a README update for a public release
WHEN documentation review is executed
THEN the README includes three or fewer niche profiles
AND each profile states one explicit user outcome.

#### Scenario: Niche copy is generic
GIVEN a niche profile without a measurable or concrete outcome
WHEN documentation review is executed
THEN the profile is flagged
AND the release is blocked until the outcome is made specific.

### Requirement: Simple Install Command Path
WHEN a new user follows installation instructions,
the system SHALL present commands in this order: GitHub install first, verification second, local development third.

#### Scenario: Correct command order
GIVEN the Quick Start install section
WHEN a user reads the first command block
THEN the first command is `npx skills add mverab/metaclaw --skill metaclaw-setup-architect`
AND the verification command appears immediately after.

#### Scenario: Command order regression
GIVEN a README change that places local path commands before GitHub install
WHEN documentation QA is executed
THEN the change is flagged as a regression
AND requires correction before publishing.
