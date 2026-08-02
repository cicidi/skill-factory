---
name: doc-organize
version: 0.1.0
description: Use when creating, moving, or reorganizing documentation files — determines where to place docs, what to name them, and maintains INDEX.md. Covers 10 document types, initiative-to-book consolidation, and MkDocs+Cinder documentation site generation.
triggers:
- organize docs
- where to put this doc
- create a doc
- move doc
- doc structure
- file naming
- what type of doc
- document type
- index docs
- initiative to book
- initiative-to-book
- update book
- doc state
when-to-use: When writing a new document and need to know where to place it and what to name it. When reorganizing existing docs. When user asks about document structure or naming conventions. This skill is about doc PLACEMENT and NAMING — write-doc handles content (Change Log).
license: MIT
compatibility: claude-code,opencode
user-invocable: true
---
# Doc Organize

Determine the correct **location**, **file name**, and **document type** for any documentation.  
Works alongside `write-doc` — this skill handles placement, write-doc handles Change Log.

---

## Document Types (10 + evidence/detail suffixes)

| Type | Purpose | Write When |
|------|---------|------------|
| `prd` | Product Requirements Document | Project kickoff |
| `research` | Investigation + comparison of options | Before making a decision |
| `design` | Technical design — one type, two optional suffixes (`.hld.md` for architecture, `.lld.md` for module detail) | Choosing architecture, before implementation |
| `spec` | Detailed technical specification | Formalizing interfaces |
| `impl-plan` | Implementation plan with milestones | Breaking down tasks |
| `test-plan` | Testing strategy and cases | Before QA phase |
| `decision-history` | Architecture Decision Record (ADR). Covers Context → Options → Decision → Why this option → Consequences | Making key decisions, defending a choice |
| `retro` | Retrospective / post-mortem | End of phase/milestone |
| `how-to` | Operational guide / runbook | Documenting repeatable processes |
| `state` | Progress tracker — current status, blockers, next steps. Dated, no Change Log | Daily/iterative status snapshots |

---

## Domain Adaptation — Video/Audio Production

When this skill is used in a **video/audio/multimedia production** project (e.g., short-form video generator, podcast producer, animation pipeline), the generic doc types map to production concepts differently:

### Mapping

| Doc Type | Video Production Meaning | Description |
|----------|------------------------|-------------|
| `prd` | Creative Brief | Video theme planning — target audience, tone, narrative framework, hook/CTA strategy, story bible |
| `spec` | Storyboard / Scene Plan | Scene-by-scene breakdown: count, time/location/characters/events, script, examples, plot line, protagonist, clues, scene transitions, per-scene details (details/data/scenery/characters), dialogue |
| `design` | Pipeline Architecture | `.hld.md` = system topology, model pipeline, data flow, service boundaries; `.lld.md` = API contracts, recipe internals, prompt assembly, schema details |
| `impl-plan` | Implementation Plan | Which models (Gemini/Seedance/etc.), how to run (CLI flags, parallel config), which scripts to run, what gets generated, how things integrate |
| `test-plan` | Acceptance Plan | Video review criteria: visual consistency, subtitle accuracy, duration check, scene transitions, character consistency, audio sync |
| `research` | Model/Tool Research | Model comparisons (Gemini vs Claude, Seedance vs Veo), paper references, competitor analysis |
| `decision-history` | Technical Decision Record | Why this model/tool/schema was chosen, tradeoffs evaluated |
| `how-to` | Operations Manual | How to create a new video project, debug a failed scene, rerun specific steps, regenerate images |
| `state` | Work Status | Current progress on a video project — which scenes done/blocked, what's next |

### Initiative = Creative Theme

In a production project, **initiatives** are templates/projects, not code features:

```
docs/founder-story/               <- Founder Story initiative
├── spec/
│   └── six-scene-structure-spec.md
├── test-plan/
│   └── acceptance-test-plan.md
└── state/
    └── 2026-07-22-production-state.md

docs/comedy-skit/                 <- Comedy Skit initiative
├── spec/
│   └── six-scene-structure-spec.md
└── test-plan/
    └── acceptance-test-plan.md

docs/pipeline/                    <- Pipeline Infrastructure initiative
├── prd/
│   └── video-gen-pipeline-prd.md
├── design/
│   ├── metadata-design.md
│   └── workflow-architecture.hld.md
└── how-to/
    └── create-new-video-how-to.md
```

When the user says "write a PRD" in a video production project, generate path as `docs/<template-name>/prd/<template-name>-prd.md`.
When the user says "write a spec for scene X", generate path as `docs/<initiative>/spec/<scene-topic>-spec.md`.

### design vs spec — How to tell them apart

| | design | spec |
|---|---|---|
| **What goes in** | Architecture diagrams + explanation | Structured contract definitions |
| **Answers** | Why this design? How do components connect? | What does the interface look like? What are the fields? |
| **Typical content** | UML/flowcharts/sequence diagrams/state machines, architecture decisions, data flow | API endpoint definitions, DB DDL/schema, message formats |
| **Reading style** | Read to understand (prose) | Look up to implement (reference) |
| **Subtypes** | `.hld.md` (system topology), `.lld.md` (class diagrams/module details) | None |

**One-liner**: design draws the skeleton and explains reasoning; spec defines the interface contract.

**Example**:

```
docs/payment-v2/design/
├── payment-flow-design.md              <- prose + embedded Mermaid diagrams
├── payment-flow-design.hld.md          <- system topology, service relationships, data flow
└── payment-flow-design.lld.md          <- class diagrams, sequence diagrams, state machines

docs/payment-v2/spec/
├── payment-api-spec.md                 <- REST endpoints, request/response formats, auth rules
├── payment-db-schema-spec.md           <- table structures, field types, indexes, constraints
└── payment-event-spec.md               <- Kafka message schema, topic definitions
```

---

### Suffixes (not standalone types)

**Evidence** — attach to any doc to provide supporting data:

```
docs/dashboard-v2/design/caching-strategy-design.md
docs/dashboard-v2/design/caching-strategy-design.evidence.md   ← benchmarks/screenshots
```

**Design detail** — attach to a design doc for HLD or LLD view:

```
docs/dashboard-v2/design/caching-strategy-design.md                 ← main design doc
docs/dashboard-v2/design/caching-strategy-design.hld.md             ← architecture overview
docs/dashboard-v2/design/caching-strategy-design.lld.md             ← component detail
```

Rules for both:
- Same name prefix, same folder as parent
- INDEX.md only lists the parent doc
- Suffix files are optional — simple designs don't need them
- `.hld.md` = system topology, service boundaries, data flow
- `.lld.md` = class diagrams, API contracts, DB schema, module internals

---

## Directory Structure

Project docs live in the project repo. Knowledge-repo is a **separate git repo** at a different path.

```
~/project/<project-name>/
├── docs/
│   ├── INDEX.md                     ← Auto-generated directory + move log
│   ├── <initiative>/
│   │   ├── raw/                     ← Temporary AI context dumps
│   │   ├── prd/
│   │   ├── design/
│   │   ├── spec/
│   │   ├── impl-plan/
│   │   ├── test-plan/
│   │   ├── decision-history/
│   │   ├── retro/
│   │   ├── how-to/
│   │   └── state/
│   └── shared/                      ← Cross-initiative docs
│       ├── glossary.md
│       └── conventions.md
│   ├── book/                         <- Project-level doc site (MkDocs + Cinder)
│   │   ├── mkdocs.yml                <- MkDocs config
│   │   ├── cinder/                   <- Cinder theme directory (from GitHub)
│   │   └── docs/
│   │       ├── index.md              <- Home page / project overview
│   │       ├── prd/                  <- PRD summaries from each initiative
│   │       ├── design/               <- Architecture/design summaries
│   │       ├── spec/                 <- API contract summaries
│   │       └── how-to/               <- Operations guide summaries
│   │       # Note: only the 4 type dirs above. Other types (research/impl-plan/test-plan/
│   │       #    decision-history/retro/state) do NOT go into book

~/project/<name>-knowledge-repo/     ← Separate repo, NOT under project/
└── docs/
    ├── INDEX.md
    └── (same 10-type structure)
```

---

## File Naming Convention

**Without date** (has Change Log, git tracks history):
```
docs/<initiative>/<type>/<specific-topic>.md
```
All 8 main types: `prd`, `design`, `spec`, `impl-plan`, `test-plan`, `decision-history`, `retro`, `how-to`
Date is in the file's Change Log — no need to repeat in filename.
**Naming rule**: `<topic>-<type>.md`. Always include both subject and type. `caching-layer-design.md` (good), `caching-layer.md` (bad), `design.md` (bad).

**With date** (point-in-time captures, no Change Log):
```
docs/<initiative>/<type>/YYYY-MM-DD-<specific-topic>.md
```
`state/` files (progress snapshots), `raw/` files, `*.evidence.md`, `*.research.md`

### state/ rules

- One file per checkpoint — dated, no Change Log
- **Overwrite in-place**, never append. Like a whiteboard: erase and rewrite.
- Content: current status, blockers, next steps, decisions made today
- Old snapshots stay as separate files (don't delete — git tracks history)

Examples:

```
# Product feature
docs/user-profile-v2/
├── raw/
│   └── 2026-07-01-agent-brainstorming.md      ← dated, AI discussion
├── prd/
│   └── user-profile-v2-prd.md         ← no date
├── design/
│   ├── profile-service-design.md         ← no date
│   ├── profile-service-architecture.hld.md
│   └── profile-service-architecture.lld.md
├── spec/
│   └── profile-endpoint-spec.md
├── impl-plan/
│   └── profile-migration-impl-plan.md
├── test-plan/
│   └── profile-integration-test-plan.md
├── decision-history/
│   └── 2026-07-12-why-postgres-over-mongo.md    ← dated
└── retro/
    └── 2026-08-01-profile-v2-launch-retro.md         ← dated

# Environment / Setup
docs/dev-env-setup/
├── prd/
│   └── dockerize-all-services-prd.md
├── design/
│   └── container-orchestration-design.md
├── impl-plan/
│   └── onboarding-impl-plan.md
├── decision-history/
│   └── 2026-06-03-why-docker-compose-not-k8s-decision.md
└── how-to/
    └── new-hire-setup-how-to.md

# Team Oncall
docs/team-oncall/
├── decision-history/
│   └── 2026-07-08-why-pagerduty-over-opsgenie-decision.md
├── how-to/
│   ├── pagerduty-escalation-how-to.md
│   └── database-incident-how-to.md
└── retro/
    └── 2026-07-15-july-oncall-handoff-retro.md

# Refactoring / Migration
docs/payment-refactor/
├── design/
│   └── new-payment-provider-design.md
├── impl-plan/
│   └── gradual-migration-impl-plan.md
└── decision-history/
    └── 2026-07-06-why-big-bang-not-incremental-decision.md
```

---

## Knowledge Repo vs Project Docs

**knowledge-repo is a separate git repo from the project repo.**

| Scenario | Where | How AI Finds It |
|----------|-------|-----------------|
| Docs tightly coupled with code | Project `docs/` | ai-coworker reads `docs/` directly |
| Docs shared across projects | Separate `knowledge-repo/` | Referenced in project's `CLAUDE.md` |
| Large team, doc PRs conflict with code PRs | Separate `knowledge-repo/` | Referenced in `CLAUDE.md` |

**Setup**: If using a knowledge-repo, add this to project's `CLAUDE.md`:
```markdown
## Knowledge Repo
- Path: `~/project/<name>-knowledge-repo/`
- Index: `~/project/<name>-knowledge-repo/docs/INDEX.md`
- When writing docs, prefer knowledge-repo. Read INDEX.md first to find existing docs.
```

**Default advice**: start with project `docs/`. Split to knowledge-repo when doc PRs conflict with code PRs frequently.

---

## Book Mode — Project Documentation Site

When a project matures, distill all initiatives into a **browsable documentation website** for onboarding, quick reference, and project overview.

### Two-Layer Structure

| Layer | Location | Content | Use when |
|-------|----------|---------|----------|
| **Source docs** | `docs/<initiative>/` | Full PRD/spec/design/how-to, unmodified | Tracing details, understanding why decisions were made |
| **Book** | `docs/book/` built to HTML | Condensed: only prd/design/spec/how-to, distilled highlights | Onboarding, quick reference, project overview |

### Book Content Principles

- Include: PRD summaries, design highlights, spec essentials, how-to key steps
- Include: decision-history condensed summaries (merged into design files)
- Include: `-> Source: docs/<initiative>/` links at end of each chapter when consolidating from initiatives
- Exclude: full source text, raw/ content, state snapshots, research/impl-plan/test-plan/retro full text

**Source docs remain in place** — Book is a distillation pointing back to source docs, not a replacement.

### Tech Stack: MkDocs + Cinder Theme

[Cinder](https://github.com/chrissimpkins/cinder) is a clean, responsive MkDocs theme built on Bootstrap 3, with highlight.js syntax highlighting, FontAwesome icons, and built-in search.

| Requirement | Cinder Support |
|------|------------|
| Markdown to HTML | Native MkDocs |
| Mermaid diagrams | pymdownx.superfences |
| Table of contents (TOC) | Auto sidebar, tree navigation |
| Full-text search | Built-in, shortcut `s` to open search |
| GitHub Pages | `mkdocs gh-deploy --force` |
| GitHub Enterprise | Confirm GHE has Pages enabled |
| Code highlighting | highlight.js, 90+ color schemes |
| Dark mode | Not supported by default, customizable via `extra_css` |

**Directory structure**:

```
docs/book/
├── mkdocs.yml                <- MkDocs config
├── cinder/                   <- Cinder theme (download from GitHub Releases)
├── docs/
│   ├── index.md              <- Home page / project overview
│   ├── prd/                  <- PRD summaries from each initiative
│   │   └── <initiative>-prd.md
│   ├── design/               <- Architecture/design summaries
│   │   └── <initiative>-design.md
│   ├── spec/                 <- API contract summaries
│   │   └── <initiative>-spec.md
│   └── how-to/               <- Operations guide summaries
│       └── <initiative>-how-to.md
└── site/                     <- Build output (gitignore)
```

**mkdocs.yml configuration**:

```yaml
site_name: <Project Name> Docs
site_url: https://<org>.github.io/<repo>/   # Required for sitemap

theme:
  name: null
  custom_dir: cinder

extra_css:
  - css/extra.css              # Optional: custom styles (dark mode, etc.)

markdown_extensions:
  - pymdownx.superfences:
      custom_fences:
        - name: mermaid
          class: mermaid
          format: !!python/name:pymdownx.superfences.fence_code_format
  - admonition
  - toc:
      permalink: true

plugins:
  - search

# Cinder-specific config
highlightjs: true
hljs_style: github             # 90+ schemes: github, monokai, dracula, ...
shortcuts:
  search: s                    # s to open search
  next: n                      # n for next page
  previous: p                  # p for previous page

# Navigation (auto-maintained by initiative-to-book)
nav:
  - Home: index.md
  - Requirements: {}
  - Architecture: {}
  - API Contracts: {}
  - How-To Guides: {}
```

**Workflow**:

```bash
# Install Cinder theme
# Download from https://github.com/chrissimpkins/cinder/releases
# Extract to docs/book/cinder/

# Install dependencies
pip install mkdocs pymdown-extensions

# Local preview
cd docs/book && mkdocs serve

# Deploy to GitHub Pages
mkdocs gh-deploy --force

# GHE users: ensure git remote points to GHE, mkdocs handles the rest
```

**GitHub Actions auto-deploy** (`.github/workflows/docs.yml`):

```yaml
name: Deploy Docs
on:
  push:
    branches: [master]
    paths:
      - 'docs/book/**'
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0        # mkdocs gh-deploy needs git history
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - run: pip install mkdocs pymdown-extensions
      - run: cd docs/book && mkdocs gh-deploy --force
```

### When to Create a Book

- 2+ initiatives have reached `state: final`
- New team members need onboarding
- Need to present the project overview to the team

### Book and Source Doc Sync

- Book is a **snapshot**, not real-time synced. Update via `initiative-to-book` after each major milestone.
- Source docs are always authoritative — when in doubt, check source docs, not the Book.
- The `-> Source` link at the end of each Book chapter jumps back to source.
- Only `state: final` initiative docs enter the book.

---

## INDEX.md

Auto-maintained at `docs/INDEX.md`. Serves as full-text-searchable catalog + file map.

```markdown
# Document Index

Last updated: YYYY-MM-DD

## By Initiative

### <initiative-name>
| St | Type | File | What It Contains |
|----|------|------|-----------------|
| [final] | prd | [dashboard-v1-prd.md](./analytics-listener/prd/dashboard-v1-prd.md) | Initial analytics dashboard requirements — user stories, KPIs, wireframes |
| [final] | spec | [profile-endpoint-spec.md](./user-profile-v2/spec/profile-endpoint-spec.md) | REST API contracts for profile service — request/response schemas, auth rules |
| [draft] | design | [payment-flow-design.md](./payment-refactor/design/payment-flow-design.md) | Payment flow architecture — sequence diagrams, data model |

## Move Log

| Date | File | From | To | Reason |
|------|------|------|----|--------|
| 2026-07-17 | dashboard-prd.md | analytics-listener/prd/ | analytics-v2/prd/ | Initiative rename |
```

Rules:
- **Full path in File column** — links are clickable, paths are searchable
- **What It Contains** — 1-2 sentence summary of the file's actual content. Generated by reading the file (first heading + first paragraph).
- Append on every doc creation or move
- Never delete entries — log moves instead

### Generating / Regenerating INDEX

When user asks to "index docs" or INDEX.md is missing/outdated:

1. Walk `docs/` tree — find all `.md` files (skip `raw/`, skip `INDEX.md` itself)
2. For each file: Read first heading + first paragraph to extract content summary
3. Detect type from parent folder, stage from existing INDEX entry (default: `draft`)
4. Write/update INDEX.md with all entries

---

## Document State

Every document file must declare its state. State is written in the file **frontmatter**:

```yaml
---
state: draft       # draft or final
final_date:        # required when state: final, format YYYY-MM-DD
---
```

### Two States

| State | Icon | Meaning | Source of Truth |
|-------|------|---------|-----------------|
| `draft` | Draft | Doc written, code not yet fully implemented | **Doc** (design draft, may differ from code) |
| `final` | Final | Code implemented and verified | **Code** (code is the single source of truth, doc may lag) |

### Rules

- New docs default to `state: draft`, `final_date` left empty
- **Validate state before every doc operation** — check frontmatter for `state` field, auto-add `state: draft` if missing
- When state changes to `final`, must fill `final_date: YYYY-MM-DD`
- For `final` docs, if code changes, docs can stay as-is (code is source of truth). Recommend adding `> Warning: this doc may be out of date; code is authoritative` at top
- State validation scope: **initiative docs + book docs**
- State changes are synced in INDEX.md

**Example**:

```markdown
---
state: final
final_date: 2026-08-01
---

# Payment API Spec

...
```

---

## Workflow

### State Validation (Pre-step for all operations)

**Before every doc operation** (create, move, consolidate to book), validate state:

1. Read the target doc's frontmatter
2. Check for `state` field -> if missing, add `state: draft`
3. If `state: final`, check for `final_date` -> if missing, infer from git log or ask user
4. Book docs validated the same way

### When user asks to create a doc

1. **Identify initiative** — Ask if unclear. Check existing initiatives in `docs/`.
2. **Determine type** — Match user's intent to one of the 10 types. Ask if ambiguous.
3. **Generate path** — `docs/<initiative>/<type>/<topic>-<type>.md`
4. **Add state frontmatter** — `state: draft` (default for new docs)
5. **Create file** — Use `write-doc` conventions for content.
6. **Update INDEX.md** — Append new entry.

### When user asks to reorganize docs

1. Scan `docs/` for misplaced files (wrong type dir, wrong naming).
2. **Scan for orphaned project folders** — Check for top-level directories that were part of old flat layouts and are now orphaned after migration:
   - Common orphans in video/media projects: `pic/`, `video/`, `jobs/`, `projects/`, `tasks.json`, `metadata.json`
   - Common orphans in general projects: `node_modules/`, `.env`, `.idea/`, `__pycache__/`
   - Verify each is gitignored or unused before deleting
3. Propose moves + deletions before executing.
4. After each move: update INDEX.md Move Log.
5. After deletions: add orphan folder names to `.gitignore` if not already present.

### When user asks where to put something

1. Identify or ask initiative and doc type.
2. Output the exact path.
3. Offer to create it.

### initiative-to-book — Consolidate initiative into project Book

Trigger: `"initiative-to-book"` / `"update book"` / (or user says "consolidate <initiative> into book")

**Step 1: Scan initiative source docs**

Read all non-raw/ `.md` files under `<initiative>/`, extract:
- Title (first `#`)
- Summary (first paragraph or TL;DR)
- Current state (frontmatter)

Only consolidate **state: final** docs. Skip draft docs (code not yet implemented).

**Step 2: Map types to book**

```
initiative <type> dir         ->  book docs/<type>/ target file
─────────────────────────────────────────────────────
<initiative>/prd/*.md        ->  docs/book/docs/prd/<initiative>-prd.md
<initiative>/design/*.md     ->  docs/book/docs/design/<initiative>-design.md
<initiative>/spec/*.md       ->  docs/book/docs/spec/<initiative>-spec.md
<initiative>/how-to/*.md     ->  docs/book/docs/how-to/<initiative>-how-to.md
```

Note: only these 4 types enter book. Other types (research/impl-plan/test-plan/decision-history/retro/state) are excluded.

**Step 3: Distill content**

Each book file contains:

```markdown
---
state: final
final_date: <latest final_date from source docs>
---

# <Initiative Name> — <Type>

## Overview
<2-3 paragraph distillation from initiative PRD + design>

## Key Design Decisions
<extracted from decision-history, 2-3 sentences each>

## API/Interface Highlights
<extracted from spec — core API/DB schema highlights>

## How-To
<extracted from how-to — key steps>

---

-> Source: [docs/<initiative>/](../<initiative>/)
```

**Step 4: Update mkdocs.yml**

Add/update the corresponding entry in `mkdocs.yml` `nav`.

**Step 5: Update INDEX.md**

Record book file changes in INDEX.md.

**Step 6: State validation**

Verify the newly written book file frontmatter — ensure state and final_date are correct.

### mkdocs.yml Maintenance

After every book doc addition/deletion/move, auto-update `docs/book/mkdocs.yml` `nav` config.

Keep nav structure consistent with `docs/book/docs/` directory structure:

```yaml
nav:
  - Home: index.md
  - Requirements:
    - <initiative>-prd: prd/<initiative>-prd.md
  - Architecture:
    - <initiative>-design: design/<initiative>-design.md
  - API Contracts:
    - <initiative>-spec: spec/<initiative>-spec.md
  - How-To Guides:
    - <initiative>-how-to: how-to/<initiative>-how-to.md
```

---

## Initiative Raw Context Folder

Each initiative has a `raw/` folder for unrefined, high-volume AI context:

```
docs/<initiative>/
├── raw/                        ← Temporary, unrefined dumps
│   ├── agent-discussion.md     ← Advocate agent transcripts
│   ├── error-logs.md           ← Raw error output
│   └── brainstorming.md        ← Unsorted ideas
├── prd/
├── design/
└── ...
```

Rules:
- `raw/` content is NOT indexed by type/stage — it's ephemeral context
- These files are for AI consumption, not human readers
- Never refine raw content in-place — extract to a typed doc when ready
- Can be deleted once the typed docs are written

---

## Integration with write-doc

CRITICAL: `write-doc` MUST invoke `doc-organize` before creating any file in `docs/`.

1. **write-doc** handles: Change Log entries in file content
2. **doc-organize** handles: where the file goes, what it's named, INDEX.md

When user says "write a PRD":
1. → doc-organize determines path + filename
2. → write-doc creates the file with proper Change Log header
