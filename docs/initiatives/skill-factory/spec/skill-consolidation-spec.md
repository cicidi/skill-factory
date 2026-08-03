# Skill Consolidation Spec

> **Status:** design approved, pending implementation
> **Date:** 2026-08-02

## Goal

Reduce walter-worker-skills from 38 to 13 by merging skills that are near-duplicates,
complementary, or naturally grouped. Each merged skill uses conversation-driven
branching (Option A pattern): ask clarifying questions upfront, then route to the
right logic path.

## Principles

1. **Merge logic, don't just stack** — genuinely fuse the workflows; when they
   differ, branch on parameters/conditions.
2. **Ask first** — every merged skill starts by asking what the user wants,
   presents options, then branches.
3. **Severity gate for reviews** — `doc-review` uses a 5-point severity scale;
   only level 3+ issues are discussed. Level 1-2 issues are skipped to avoid
   bikeshedding and over-engineering.
4. **Simple subcommands for CRUD sets** — `/initiative`, `/project`, `/skill`,
   `/dashboard` accept subcommands directly (like git).

## Merge Map

### Category 3 — Natural CRUD Sets (subcommand-driven)

| # | Merged Name | Subcommands | Absorbed | Reduction |
|---|-------------|------------|----------|-----------|
| 1 | **`/initiative`** | `create`, `edit`, `activate`, `deactivate`, `list`, `show`, `delete` | initiative-create, initiative-edit, initiative-activate, initiative-deactivate, initiative-list, initiative-show, initiative-remove (7) | -6 |
| 2 | **`/dashboard`** | `start [--daemon]`, `import [--files]`, `stop` | analytics-create-db, analytics-daemon, analytics-dashboard, analytics-import, analytics-once (5) | -4 |
| 3 | **`/project`** | `add`, `edit`, `remove`, `list`, `show`, `sync` | project-add, project-edit, project-remove, project-list, project-show, project-sync (6) | -5 |
| 4 | **`/skill`** | `create`, `edit`, `import`, `list` | skill-create, skill-edit, skill-import, skill-list (4) | -3 |

### Category 1 — Near-Duplicates (conversation-branch)

| # | Merged Name | Branches | Absorbed | Reduction |
|---|-------------|----------|----------|-----------|
| 5 | **`/doc-review`** | `design review` (adversarial stress-test for specs/designs) / `work completion review` (acceptance check against PRD/design) | devil-advocate, contrarian-review, work-review (3) | -2 |
| 6 | **`/bug`** | `hunt` (scientific debug: hypothesis→test→fix) / `report` (file GitHub issue) / `heal` (record correction → analyze patterns → generate prevention rules) | bug-hunt, bug-report, self-analyze, self-heal (4) | -3 |

### Category 2 — Complementary (auto-detect + branch)

| # | Merged Name | Branches | Absorbed | Reduction |
|---|-------------|----------|----------|-----------|
| 7 | **`/doc-organize`** | `organize` (decide placement/naming/maintain INDEX.md) / `merge` (resolve upstream sync conflicts with protected blocks) | doc-merge, doc-organize (2) | -1 |
| 8 | **`/knowledge`** | `obsidian vault` (extract memory cards from sessions → Obsidian) / `sqlite analytics` (LLM analysis → session_summaries + knowledge cards → analytics.db) | session-memory, knowledge-skill (2) | -1 |
| 9 | **`/auto-tdd`** | `basic` (red-green-refactor from imported tdd) / `auto` (multi-agent continuous TDD loop with arbiter + quality judge) | auto-tdd, tdd (import) (2) | -1 |
| 10 | **`/research`** | `discover unknowns` (interview-style, surface blind spots before coding) / `design spec` (brainstorming → design → spec → transition to plan) | find-my-unknown, superpowers:brainstorming (2) | -1 |

### Independent — No Merge

| Skill | Reason |
|-------|--------|
| `english-grammar-fix` | Pure utility, no overlap with anything |
| `multi-model-team` | Unique multi-model architecture, distinct workflow |
| `status` | Simple CLI passthrough, just runs `coworker status` |

## Internal Structure (Option A Pattern)

Each merged SKILL.md follows this structure (illustrative — not the actual content):

```markdown
---
name: example-skill
description: Use when the user wants to ... (describe trigger, not workflow)
---
...

## Dashboard Merge Detail

5 → 1: `/dashboard [start|import|stop]`

| Subcommand | Behavior |
|------------|----------|
| `start` (default) | Launch web dashboard on localhost:8080. DB auto-created if missing. `--daemon` flag enables background auto-import |
| `import` | One-shot scan and import. `--files <paths>` for specific files |
| `stop` | Stop the daemon if running |

`analytics-create-db` is removed — DB creation happens automatically on first use.
`analytics-once` and `analytics-import` are merged — `import` without `--files` does a full scan.

## Files Changed

| File | Change |
|------|--------|
| `walter-worker-skills/initiative/SKILL.md` | New merged skill (replaces 7) |
| `walter-worker-skills/dashboard/SKILL.md` | New merged skill (replaces 5) |
| `walter-worker-skills/project/SKILL.md` | New merged skill (replaces 6) |
| `walter-worker-skills/skill/SKILL.md` | New merged skill (replaces 4) |
| `walter-worker-skills/doc-review/SKILL.md` | New merged skill (replaces 3) |
| `walter-worker-skills/doc-organize/SKILL.md` | Merged skill (replaces 2) |
| `walter-worker-skills/bug/SKILL.md` | New merged skill (replaces 4) |
| `walter-worker-skills/knowledge/SKILL.md` | Merged skill (replaces 2) |
| `walter-worker-skills/auto-tdd/SKILL.md` | Merged skill (replaces 2) |
| `walter-worker-skills/research/SKILL.md` | New merged skill (replaces 2) |

Old skill directories to delete: 35 total (38 - 3 independents kept + import-skills/tdd).

## Out of Scope (personal-skills)

`personal-skills/` consolidation is deferred to a separate round. The two YouTube skills
(`youtube-research-pipeline` + `youtube-summarize` → `/youtube`) are noted but not
touched in this round.
