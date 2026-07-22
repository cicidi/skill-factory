---
name: doc-organize
version: 0.1.0
description: Document organization skill — determines where to place docs, what to name them, and maintains INDEX.md. Covers 9 document types + evidence suffix with naming conventions and folder hierarchy. Use when creating, moving, or reorganizing documentation files.
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
| `prd` | 总策划 (Overall creative brief) | Video theme planning — target audience, tone, narrative framework, hook/CTA strategy, story bible |
| `spec` | 分镜/场景规划 (Storyboard / scene plan) | Scene-by-scene breakdown: count, time/location/characters/events, script, examples, plot line (情节), protagonist (主人公/主要事务), clues (线索), scene transitions (场景切换), per-scene details (细节/数据/景色/人物), dialogue |
| `design` | 架构设计 (Pipeline architecture) | `.hld.md` = system topology, model pipeline, data flow, service boundaries; `.lld.md` = API contracts, recipe internals, prompt assembly, schema details |
| `impl-plan` | 实现计划 (Implementation plan) | Which models (Gemini/Seedance/etc.), how to run (CLI flags, parallel config), which scripts to run, what gets generated, how things integrate |
| `test-plan` | 验收计划 (Acceptance plan) | Video review criteria: visual consistency, subtitle accuracy, duration check, scene transitions, character consistency, audio sync |
| `research` | 模型/工具调研 | Model comparisons (Gemini vs Claude, Seedance vs Veo), paper references, competitor analysis |
| `decision-history` | 技术决策记录 | Why this model/tool/schema was chosen, tradeoffs evaluated |
| `how-to` | 操作手册 | How to create a new video project, debug a failed scene, rerun specific steps, regenerate images |
| `state` | 工作状态 | Current progress on a video project — which scenes done/blocked, what's next |

### Initiative = Creative Theme

In a production project, **initiatives** are templates/projects, not code features:

```
docs/founder-story/               ← 创业者故事 initiative
├── spec/
│   └── six-scene-structure-spec.md
├── test-plan/
│   └── acceptance-test-plan.md
└── state/
    └── 2026-07-22-production-state.md

docs/comedy-skit/                 ← 搞笑反转 initiative
├── spec/
│   └── six-scene-structure-spec.md
└── test-plan/
    └── acceptance-test-plan.md

docs/pipeline/                    ← Pipeline 基建 initiative
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
**Naming rule**: `<topic>-<type>.md`. Always include both subject and type. `caching-layer-design.md` ✅, `caching-layer.md` ❌, `design.md` ❌.

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

## INDEX.md

Auto-maintained at `docs/INDEX.md`. Serves as full-text-searchable catalog + file map.

```markdown
# Document Index

Last updated: YYYY-MM-DD

## By Initiative

### <initiative-name>
| St | Type | File | What It Contains |
|----|------|------|-----------------|
| ✅ | prd | [dashboard-v1-prd.md](./analytics-listener/prd/dashboard-v1-prd.md) | Initial analytics dashboard requirements — user stories, KPIs, wireframes |
| 🚧 | spec | [profile-endpoint-spec.md](./user-profile-v2/spec/profile-endpoint-spec.md) | REST API contracts for profile service — request/response schemas, auth rules |
| 🔲 | tbd | (placeholder) | — |

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

## Document Lifecycle

6 stages. Tracked in INDEX.md only — NOT in filename.

| Stage | Icon | Meaning | When to advance |
|-------|------|---------|-----------------|
| `tbd` | 🔲 | Placeholder, not started | → draft: start writing |
| `draft` | 📝 | Rough outline, structure ready | → wip: serious writing begins |
| `wip` | 🚧 | Active development, content iterating | → review: author thinks it's done |
| `review` | 👀 | Awaiting peer/team review | → final: approved, OR → wip: changes requested |
| `final` | ✅ | Approved, no further changes expected | → archived: no longer relevant |
| `archived` | 📦 | Outdated, kept for reference | — end of life |

Rules:
- New docs start at `draft` by default. Use `tbd` for intentionally empty placeholders.
- Change stage in INDEX.md only — never rename the `.md` file.
- `review → wip` is the only allowed "backward" transition (rework after feedback).

---

## Workflow

### When user asks to create a doc

1. **Identify initiative** — Ask if unclear. Check existing initiatives in `docs/`.
2. **Determine type** — Match user's intent to one of the 9 types. Ask if ambiguous.
3. **Generate path** — `docs/<initiative>/<type>/YYYY-MM-DD-<specific-topic>.md`
4. **Create file** — Use `write-doc` conventions for content.
5. **Update INDEX.md** — Append new entry.

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
