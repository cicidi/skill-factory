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

## Document Types (9 + evidence suffix)

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

### Suffixes (not standalone types)

**Evidence** — attach to any doc to provide supporting data:

```
docs/dashboard-v2/research/2026-07-02-competitor-analysis.md
docs/dashboard-v2/research/2026-07-02-competitor-analysis.evidence.md   ← benchmarks/screenshots
```

**Design detail** — attach to a design doc for HLD or LLD view:

```
docs/dashboard-v2/design/2026-07-05-caching-strategy.md                 ← main design doc
docs/dashboard-v2/design/2026-07-05-caching-strategy.hld.md             ← architecture overview
docs/dashboard-v2/design/2026-07-05-caching-strategy.lld.md             ← component detail
```

Rules for both:
- Same name prefix, same folder as parent
- INDEX.md only lists the parent doc
- Suffix files are optional — simple designs don't need them
- `.hld.md` = system topology, service boundaries, data flow
- `.lld.md` = class diagrams, API contracts, DB schema, module internals

---

## Directory Structure

```
project/
├── docs/
│   ├── INDEX.md                     ← Auto-generated directory + move log
│   ├── <initiative>/
│   │   └── <type>/
│   │       └── YYYY-MM-DD-<specific-topic>.md
│   └── shared/                      ← Cross-initiative docs
│       ├── glossary.md
│       └── conventions.md
│
└── knowledge-repo/  (optional, separate git repo)
    └── (same structure)
```

---

## File Naming Convention

Two styles depending on document type:

**Without date** (content evolves, git tracks history):
```
docs/<initiative>/<type>/<specific-topic>.md
```
Types: `prd`, `design`, `spec`, `impl-plan`, `test-plan`, `how-to`

**With date** (time-point matters):
```
docs/<initiative>/<type>/YYYY-MM-DD-<specific-topic>.md
```
Types: `decision-history`, `retro`, everything in `raw/`

**Suffix files** (attached to parent, same date rules as parent):
```
*.evidence.md
```

Rules:
- Topic: kebab-case, describes the specific problem — NOT the initiative name
- An initiative can be a product feature, env setup, team oncall, or anything
- Multiple files of same type in one initiative are normal

Examples:

```
# Product feature
docs/user-profile-v2/
├── raw/
│   └── 2026-07-01-agent-brainstorming.md      ← dated, AI discussion
├── prd/
│   └── user-profile-v2-requirements.md         ← no date
├── design/
│   ├── profile-service-architecture.md         ← no date
│   ├── profile-service-architecture.hld.md
│   └── profile-service-architecture.lld.md
├── spec/
│   └── profile-endpoint-contracts.md
├── impl-plan/
│   └── profile-migration-steps.md
├── test-plan/
│   └── profile-integration-tests.md
├── decision-history/
│   └── 2026-07-12-why-postgres-over-mongo.md    ← dated
└── retro/
    └── 2026-08-01-profile-v2-launch-review.md         ← dated

# Environment / Setup
docs/dev-env-setup/
├── prd/
│   └── dockerize-all-services.md
├── design/
│   └── container-orchestration-plan.md
├── impl-plan/
│   └── onboarding-scripts-and-docs.md
├── decision-history/
│   └── 2026-06-03-why-docker-compose-not-k8s.md
└── how-to/
    └── new-hire-setup-checklist.md

# Team Oncall
docs/team-oncall/
├── decision-history/
│   └── 2026-07-08-why-pagerduty-over-opsgenie.md
├── how-to/
│   ├── pagerduty-escalation-flow.md
│   └── database-incident-runbook.md
└── retro/
    └── 2026-07-15-july-oncall-handoff.md

# Refactoring / Migration
docs/payment-refactor/
├── design/
│   └── new-payment-provider-interface.md
├── impl-plan/
│   └── gradual-migration-phases.md
└── decision-history/
    └── 2026-07-06-why-big-bang-not-incremental.md
```

---

## Knowledge Repo vs Project Docs

| Scenario | Where |
|----------|-------|
| Small team, docs tightly coupled with code | `docs/` in project repo |
| Large team, docs merge independently of code | Separate `knowledge-repo/` |
| Cross-project shared knowledge | `knowledge-repo/` |
| Single project, active development | Project `docs/` |

**Default advice**: start with project `docs/`. Split to knowledge-repo when you notice doc PRs conflicting with code PRs frequently.

---

## INDEX.md

Auto-maintained at `docs/INDEX.md`:

```markdown
# Document Index

Last updated: YYYY-MM-DD

## By Initiative

### <initiative-name>
| St | Type | File | Created |
|----|------|------|---------|
| ✅ | prd | [description](./initiative/prd/date-name.md) | 2026-07-14 |
| 🚧 | spec | [description](./initiative/spec/date-name.md) | 2026-07-15 |
| 🔲 | tbd | (placeholder for future doc) | — |

## Move Log

| Date | File | From | To | Reason |
|------|------|------|----|--------|
| 2026-07-17 | dashboard-prd.md | analytics-listener/prd/ | analytics-v2/prd/ | Initiative rename |
```

Rules:
- Append on every doc creation or move
- Never delete entries — log moves instead

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
2. Propose moves before executing.
3. After each move: update INDEX.md Move Log.

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
