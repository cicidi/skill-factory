# Skill Consolidation Test Plan

> **Spec:** docs/skill-factory/spec/skill-consolidation-spec.md
> **Date:** 2026-08-02

## Scope

Verify 38 walter-worker-skills → 10 merged skills correctly implemented.
- 10 new merged SKILL.md files created
- 35 old skill directories deleted
- 3 independent skills untouched (english-grammar-fix, multi-model-team, status)
- 9 personal-skills untouched
- 1 import-skills/tdd deleted (absorbed into auto-tdd)

---

## Layer 1: Conventions Compliance (3 tests per merged skill — 30 tests)

### T1.1 — Frontmatter fields
> For each new SKILL.md:
> - ✅ `name` is lowercase kebab-case, 1-5 words
> - ✅ `description` starts with "Use when...", ≤1024 chars, third person, describes trigger not workflow
> - ✅ `license: MIT` present
> - ✅ `compatibility` includes `claude-code,opencode`
> - ✅ No extra frontmatter fields beyond the 5 recognized

```bash
# Script: for each merged skill, parse frontmatter and validate
for skill in initiative dashboard project skill doc-review doc-organize bug knowledge auto-tdd research; do
  echo "=== $skill ==="
  # check name matches directory
  # check description starts with "Use when"
  # check description length ≤ 1024
  # check license field
  # check compatibility field
done
```

| Skill | Expected name | Expected description trigger |
|-------|--------------|------------------------------|
| initiative | `initiative` | Use when managing cross-project initiatives |
| dashboard | `dashboard` | Use when viewing analytics or managing dashboard |
| project | `project` | Use when managing the project catalog |
| skill | `skill` | Use when creating, editing, or listing skills |
| doc-review | `doc-review` | Use when reviewing a design, spec, proposal, or completed work |
| doc-organize | `doc-organize` | Use when organizing or merging documentation |
| bug | `bug` | Use when debugging, reporting bugs, or recording corrections |
| knowledge | `knowledge` | Use when extracting or querying session knowledge |
| auto-tdd | `auto-tdd` | Use when developing with test-driven methodology |
| research | `research` | Use when exploring unknowns or designing before implementation |

### T1.2 — Body structure
> For each new SKILL.md:
> - ✅ `# <skill-name>` heading + 1-2 sentence overview
> - ✅ `## When to Use` section
> - ✅ `## When NOT to Use` section
> - ✅ `## Process` section
> - ✅ No prohibited content (changelog, emoji, TBD, truncated sentences)

### T1.3 — Naming convention
> - ✅ Each directory name matches `{verb}-{object}` or `{domain}-{action}`
> - ✅ SKILL.md is uppercase
> - ✅ No filler words in names

---

## Layer 2: Structural Tests (10 tests)

### T2.1 — Old skills deleted
> 35 old directories must NOT exist:

```bash
# Category 3 — CRUD sets (22 removed)
test ! -d walter-worker-skills/initiative-create
test ! -d walter-worker-skills/initiative-edit
test ! -d walter-worker-skills/initiative-activate
test ! -d walter-worker-skills/initiative-deactivate
test ! -d walter-worker-skills/initiative-list
test ! -d walter-worker-skills/initiative-show
test ! -d walter-worker-skills/initiative-remove

test ! -d walter-worker-skills/analytics-create-db
test ! -d walter-worker-skills/analytics-daemon
test ! -d walter-worker-skills/analytics-dashboard
test ! -d walter-worker-skills/analytics-import
test ! -d walter-worker-skills/analytics-once

test ! -d walter-worker-skills/project-add
test ! -d walter-worker-skills/project-edit
test ! -d walter-worker-skills/project-remove
test ! -d walter-worker-skills/project-list
test ! -d walter-worker-skills/project-show
test ! -d walter-worker-skills/project-sync

test ! -d walter-worker-skills/skill-create
test ! -d walter-worker-skills/skill-edit
test ! -d walter-worker-skills/skill-import
test ! -d walter-worker-skills/skill-list

# Category 1/2 — merged skills (12 removed, doc-organize overwritten in-place)
test ! -d walter-worker-skills/devil-advocate
test ! -d walter-worker-skills/contrarian-review
test ! -d walter-worker-skills/work-review
test ! -d walter-worker-skills/bug-hunt
test ! -d walter-worker-skills/bug-report
test ! -d walter-worker-skills/self-analyze
test ! -d walter-worker-skills/self-heal
test ! -d walter-worker-skills/doc-merge
test ! -d walter-worker-skills/session-memory
test ! -d walter-worker-skills/knowledge-skill
test ! -d walter-worker-skills/find-my-unknown

# import-skills absorbed
test ! -d import-skills/tdd
```

### T2.2 — New skills exist
> 10 new directories must exist with SKILL.md:

```bash
for skill in initiative dashboard project skill doc-review doc-organize bug knowledge auto-tdd research; do
  test -f walter-worker-skills/$skill/SKILL.md || echo "MISSING: $skill"
done
```

### T2.3 — Independent skills untouched
> 3 skills must still exist unchanged:

```bash
test -f walter-worker-skills/english-grammar-fix/SKILL.md
test -f walter-worker-skills/multi-model-team/SKILL.md
test -f walter-worker-skills/status/SKILL.md
```

### T2.4 — Personal-skills untouched
> All 9 must still exist:

```bash
ls personal-skills/*/SKILL.md | wc -l  # must be 9
```

---

## Layer 3: Content Merge Quality Tests (20 tests)

### T3.1 — CRUD subcommand routing
> For `/initiative`, `/project`, `/skill`, `/dashboard`:

| Test | Description |
|------|-------------|
| T3.1.1 | No subcommand → lists current state + asks user what to do |
| T3.1.2 | Each subcommand has a clear one-line description |
| T3.1.3 | Invalid subcommand → suggests valid options |
| T3.1.4 | Each subcommand's process section references the CLI command it wraps |

### T3.2 — Conversation-branch routing
> For `/doc-review`, `/bug`, `/knowledge`, `/auto-tdd`, `/research`:

| Test | Description |
|------|-------------|
| T3.2.1 | Skill starts by asking ONE question to determine branch |
| T3.2.2 | Each branch has a self-contained `## Process` sub-section |
| T3.2.3 | Branches are mutually exclusive and collectively exhaustive |
| T3.2.4 | If user gives ambiguous answer, skill asks ONE clarifying follow-up |

### T3.3 — Merged logic: doc-review
| Test | Description |
|------|-------------|
| T3.3.1 | Design review branch includes adversarial questioning from devil-advocate |
| T3.3.2 | Design review branch includes alternative-searching from contrarian-review |
| T3.3.3 | Work completion branch includes acceptance criteria checking from work-review |
| T3.3.4 | Severity gate is explicitly defined (5-point scale, 3+ only discussed) |

### T3.4 — Merged logic: bug
| Test | Description |
|------|-------------|
| T3.4.1 | Hunt branch includes hypothesis→test→fix loop from bug-hunt |
| T3.4.2 | Report branch includes GitHub issue creation from bug-report |
| T3.4.3 | Heal branch includes trace recording from self-heal + pattern analysis from self-analyze |

### T3.5 — Merged logic: research
| Test | Description |
|------|-------------|
| T3.5.1 | Discover unknowns branch includes interview rules (one question, depth heuristic, stop condition) |
| T3.5.2 | Design spec branch includes explore→clarify→approaches→design→spec→write→review flow |
| T3.5.3 | After design spec completes, transitions to writing-plans |

---

## Layer 4: Deployment Tests (5 tests)

### T4.1 — coworker sync
```bash
coworker sync
```
> - ✅ No errors
> - ✅ All 10 new skills appear in `~/.claude/skills/` as SKILL.md files
> - ✅ Old skill directories removed from `~/.claude/skills/`

### T4.2 — Slash command availability
```bash
ls ~/.claude/skills/ | grep -E "^(initiative|dashboard|project|skill|doc-review|doc-organize|bug|knowledge|auto-tdd|research)$" | wc -l
# must be 10
```

### T4.3 — Old commands removed
```bash
ls ~/.claude/skills/ | grep -E "^(initiative-create|devil-advocate|bug-hunt|self-heal|find-my-unknown)$" | wc -l
# must be 0
```

### T4.4 — Config consistency
```bash
# skills in coworker.yaml match actual skill directories
coworker skill list
```
> - ✅ Count matches number of deployed skills (10 merged + 3 independent + ~20 other global skills)
> - ✅ No orphaned paths pointing to deleted skill directories

### T4.5 — coworker status still works
```bash
coworker status
```
> - ✅ Shows config table
> - ✅ Shows initiative progress if one is active

---

## Layer 5: Functional Regression (manual, via Claude Code)

### T5.1 — Each merged skill can be invoked
```
/initiative list
/dashboard start
/project list
/skill list
/doc-review          ← should ask "design or work review?"
/doc-organize
/bug                 ← should ask "hunt, report, or heal?"
/knowledge           ← should ask "obsidian vault or sqlite analytics?"
/auto-tdd            ← should ask "basic or auto?"
/research            ← should ask "discover unknowns or design spec?"
```

### T5.2 — Independent skills still work
```
/english-grammar-fix  ← should not break
/multi-model-team     ← should not break
/status               ← should run coworker status
```

---

## Summary

| Layer | Tests | Type |
|-------|-------|------|
| L1 — Conventions | 30 | Automated |
| L2 — Structural | 10 | Automated |
| L3 — Content | 20 | Manual review |
| L4 — Deployment | 5 | Shell |
| L5 — Functional | 12 | Manual (Claude Code) |
| **Total** | **77** | |

### Automation Priority

1. **L2 (10 tests)** — run first, pure shell, catches missing/extra directories immediately
2. **L4 (5 tests)** — run after `coworker sync`, verifies deployment
3. **L1 (30 tests)** — a script that parses SKILL.md frontmatter + validates sections
4. **L3 (20 tests)** — manual review of each merged SKILL.md body content
5. **L5 (12 tests)** — final smoke test in real Claude Code session
