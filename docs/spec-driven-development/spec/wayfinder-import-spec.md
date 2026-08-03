---
state: final
final_date: 2026-08-02
---

# Wayfinder Import & Adaptation — Design Spec

> Import Matt Pocock's Wayfinder skill into skill-factory with key adaptations:
> brief terminology, pluggable skill interfaces, delivery review gate, and
> doc-review checkpoint before to-tickets.

## 1. Problem Statement

Matt Pocock's Wayfinder is a decision-mapping methodology for work too large
for one agent session. It charts a shared map on an issue tracker and resolves
decision tickets one at a time. We want to import it into skill-factory with
several adaptations to fit ai-coworker's ecosystem and clarify terminology.

## 2. Terminology Changes

Only one term changes:

| Matt Original | Adapted | Reason |
|---|---|---|
| `ticket` (decision ticket) | `brief` | Disambiguate from to-tickets' Jira build tickets |

All other terms preserved: map, destination, frontier, fog of war, claim,
blocking, chart the map, work the map, decisions so far, not yet specified,
out of scope.

## 3. Attribution

```yaml
metadata:
  source_author: mattpocock
  source_url: https://github.com/mattpocock/skills/blob/main/skills/engineering/wayfinder/SKILL.md
```

Format follows existing `import-skills/tdd/SKILL.md` convention.

## 4. Pluggable Skill Interfaces

Wayfinder depends on four capabilities. Each is an interface with a Matt
default and an optional ai-coworker replacement.

| Interface | Purpose | Matt Default | ai-coworker Replacement |
|---|---|---|---|
| **interview** | Grill user, write CONTEXT.md + ADRs | `grill-with-docs` + `domain-modeling` | None |
| **investigate** | Read docs/APIs, produce cited markdown | `research` | `ai-coworker-skills/research` ✅ |
| **prototype** | Build throwaway artifact | `prototype` | None |
| **tracker** | Issue CRUD (create, list, label, assign, close) | `gh` CLI (via generated `docs/agents/issue-tracker.md`) | None |

### Configuration mechanism

On first install, ask the user one question per interface:

> For `<interface>` (`<purpose>`), default is `<Matt default>`. Replace or keep?

Answers:
- **"keep" / "default"** → use Matt's skill
- **"use <name>"** → use named skill (must exist in skill-factory or ai-coworker)
- **"skip"** → that brief type is unavailable

Store choices where the skill can read them (e.g. wayfinder SKILL.md metadata
or a companion config file).

Our install: investigate → ai-coworker research, all others → Matt defaults.

## 5. Delivery Review Gate

Wayfinder's "Work the map" Step 4 (record resolution) gains a review checkpoint:

```
IF brief type is task AND deliverables were produced:
    → Determine deliverable type (.md or code)
    → Run review:
        .md files   → ai-coworker doc-review
        code files  → ai-coworker matt-code-review
        fallback    → Claude default review
    → Review passed?
        YES → continue to close brief
        NO  → fix issues, re-review
```

Research, grilling, and prototype briefs do NOT trigger this gate — their
output is knowledge/decisions, not deliverables.

## 6. Doc-Organize: MkDocs-Ready Guarantee

All documents produced during Wayfinder must be MkDocs-ready — deployable
as a GitHub Pages website without additional conversion.

**Standing requirement:** `doc-organize` runs as part of every document-producing
step to ensure:

- INDEX.md is maintained (new docs added, moved docs updated)
- File naming follows mkdocs conventions (kebab-case, no special chars)
- Directory structure matches mkdocs nav hierarchy
- `mkdocs.yml` nav is updated when new sections are added

This is NOT a separate checkpoint — it's an inline discipline. Every time a
document is created or moved, doc-organize runs to keep the site buildable.

## 7. Spec Creation & Doc-Review Checkpoint

After all briefs are resolved (map done), before to-tickets:

```
Wayfinder map done
       │
       ▼
    to-spec
       │
       ├── Creates Jira ticket for the spec itself (spec lives as an issue)
       │
       ▼
    doc-review
       │
       ├── Reviews: spec + all closed briefs + CONTEXT.md + ADRs
       ├── Checks: consistency, completeness, no contradictions
       │
       ▼
    Review passed?
       │
   YES ├── to-tickets → creates Jira build tickets
   NO  └── fix docs, re-review
```

Three checkpoints total:

| Checkpoint | When | Scope |
|---|---|---|
| Delivery review | Each task brief close | That brief's deliverables only |
| Doc-organize | Every doc create/move | INDEX.md + mkdocs nav + file naming |
| Doc-review | After to-spec, before to-tickets | All documents: content consistency + completeness + mkdocs-ready |

## 8. Complete Lifecycle

```
┌──────────────────────────────────────────────────────────────────┐
│ SESSION 1: Chart the Map                                          │
│                                                                   │
│ 1. Grill user → name Destination, fix scope                       │
│ 2. Map frontier breadth-first → surface open decisions            │
│ 3. Create map issue (label: wayfinder:map)                        │
│ 4. Create briefs → wire blocking edges in second pass             │
│ 5. Fire research briefs as parallel subagents                     │
│ 6. STOP                                                           │
└────────────────────────────┬─────────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────────┐
│ SESSION 2..N: Work the Map                                        │
│                                                                   │
│ For each session:                                                 │
│ 1. Load map at low resolution                                     │
│ 2. Pick first unblocked, unassigned brief → claim (assign)        │
│ 3. Resolve it:                                                    │
│    research  → /research subagent (AFK)                           │
│    grilling  → /grill-with-docs + /domain-modeling (HITL)         │
│    prototype → /prototype (HITL)                                  │
│    task      → do the work (HITL/AFK)                             │
│ 4. IF task brief + deliverables:                                  │
│       run delivery review gate → pass → continue                  │
│ 5. Record resolution: comment answer, close brief,                │
│    append to map Decisions-so-far                                 │
│ 6. Graduate fog → new briefs if specifiable                       │
│ 7. STOP (one brief per session, except research)                  │
│                                                                   │
│ Repeat until frontier is empty.                                   │
└────────────────────────────┬─────────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────────┐
│ Map Done: to-spec                                                 │
│                                                                   │
│ 1. Synthesize all brief conclusions → spec (PRD)                  │
│ 2. Create Jira ticket for spec itself                             │
└────────────────────────────┬─────────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────────┐
│ Doc-Review + Doc-Organize Checkpoint                              │
│                                                                   │
│ 1. doc-organize: INDEX.md, mkdocs nav, file naming                │
│ 2. doc-review: content consistency, completeness, no              │
│    contradictions, mkdocs-ready verified                          │
│                                                                   │
│ Pass → proceed to to-tickets                                      │
│ Fail → fix, re-review                                             │
└────────────────────────────┬─────────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────────┐
│ to-tickets                                                        │
│                                                                   │
│ Split spec into tracer-bullet Jira tickets with blocking edges    │
│ (These ARE build tickets — distinct from Wayfinder briefs)        │
└──────────────────────────────────────────────────────────────────┘
```

### Entity Relationships

```
N briefs (decisions) → 1 spec (PRD, a Jira ticket) → M Jira tickets (build)

  Map:      1 issue, label wayfinder:map
  Brief:    N child issues, label wayfinder:<type>
            (research | grilling | prototype | task)
  Spec:     1 issue, label ready-for-agent (created by to-spec)
  Tickets:  M issues, label ready-for-agent (created by to-tickets)
```

## 9. Testing Strategy

### 9.1 Test-First Discipline

Test plan MUST be written and reviewed **before** implementation plan. Implementation plan MUST reference test plan for verification steps.

### 9.2 Test Plan Scope

| Test Area | What to Verify |
|---|---|
| **Frontmatter compliance** | All 5 fields present, description starts with "Use when...", ≤1024 chars |
| **Convention compliance** | No prohibited sections, no TBD/TODO, no emoji, no context leaks |
| **Attribution** | `source_author: mattpocock` and `source_url` present on all 4 skills |
| **Terminology** | "ticket" only appears in to-tickets/Jira/build-ticket contexts; all decision tickets are "brief" |
| **Pluggable interfaces** | 4 interfaces documented, config mechanism present, research references ai-coworker |
| **Review gates** | Delivery review gate in Work the Map step 4; doc-review checkpoint after to-spec |
| **Body preservation** | grill-with-docs, domain-modeling, prototype: original body content intact, only frontmatter converted |
| **Deployment** | All 4 skills deployable to Claude Code + OpenCode |

### 9.3 Validation Gates

| Gate | When | Tool |
|---|---|---|
| **Smoke test** | After deploy | `/wayfinder` loads in new session, "brief" terminology in narration |
| **Doc-review** | Before commit | `doc-review` on all 4 SKILL.md files |
| **Convention scan** | Before commit | Manual check against CONVENTIONS.md checklist |

### 9.4 Test Deliverables

1. `docs/spec-driven-development/test-plan/wayfinder-import-test-plan.md` — written BEFORE impl plan
2. Test results recorded inline in impl plan tasks (pass/fail per step)

## 10. Files to Import

| Skill | Source | Destination |
|---|---|---|
| `wayfinder` | mattpocock/skills:engineering/wayfinder/SKILL.md | `import-skills/wayfinder/SKILL.md` (adapted) |
| `grill-with-docs` | mattpocock/skills:engineering/grill-with-docs/SKILL.md | `import-skills/grill-with-docs/SKILL.md` |
| `domain-modeling` | mattpocock/skills:engineering/domain-modeling/SKILL.md | `import-skills/domain-modeling/SKILL.md` |
| `prototype` | mattpocock/skills:engineering/prototype/SKILL.md | `import-skills/prototype/SKILL.md` |

research is NOT imported — ai-coworker's own research skill replaces it.

## 11. Out of Scope

- `setup-matt-pocock-skills` — use ai-coworker's init/project instead
- `to-spec`, `to-tickets`, `implement` — future imports
- Breaking Bad terminology rename — separate future map
- `triage` — not needed by wayfinder
