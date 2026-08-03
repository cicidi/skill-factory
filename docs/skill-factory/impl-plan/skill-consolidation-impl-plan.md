# Skill Consolidation Implementation Plan

> **Spec:** docs/skill-factory/spec/skill-consolidation-spec.md
> **Test Plan:** docs/skill-factory/test-plan/skill-consolidation-test-plan.md
> **Date:** 2026-08-02

## Overview

38 walter-worker-skills → 10 merged + 3 independent = 13 total.
Implementation is phased: create new merged SKILL.md files, verify with tests,
then delete old directories.

---

## Phase 1: Create Merged Skills (10 files)

Write each new SKILL.md from scratch, fusing the logic of absorbed skills.
Do NOT delete old directories yet.

### P1.1 — CRUD Sets (subcommand-driven, simpler — do first)

| # | Create | Absorbs |
|---|--------|---------|
| 1 | `walter-worker-skills/initiative/SKILL.md` | 7 initiative-* |
| 2 | `walter-worker-skills/dashboard/SKILL.md` | 5 analytics-* |
| 3 | `walter-worker-skills/project/SKILL.md` | 6 project-* |
| 4 | `walter-worker-skills/skill/SKILL.md` | 4 skill-* |

These are thin wrappers — each subcommand maps to the existing CLI command.
Structure:

```markdown
---
name: initiative
description: Use when managing cross-project initiatives — create, edit, activate,
  deactivate, list, show, or delete
license: MIT
compatibility: claude-code,opencode
---

# initiative

Manage cross-project initiatives.

## When to Use

- Creating, editing, or removing an initiative
- Activating or deactivating the current initiative context
- Listing or viewing initiative details

## When NOT to Use

- Managing projects in the catalog → use /project
- General task tracking → use /status

## Process

### No subcommand given
If the user doesn't specify a subcommand, list current initiatives and ask what
they want to do.

### Subcommands

| Subcommand | CLI equivalent | Description |
|------------|---------------|-------------|
| create | `coworker initiative create <name>` | Create a new initiative |
| edit | `coworker initiative edit <name>` | Modify an existing initiative |
| activate | `coworker initiative activate <name>` | Activate an initiative as current context |
| deactivate | `coworker initiative deactivate` | Deactivate the current initiative |
| list | `coworker initiative list` | List all initiatives |
| show | `coworker initiative show <name>` | Show full initiative details |
| delete | `coworker initiative remove <name>` | Permanently remove an initiative |
```

### P1.2 — Conversation-Branch Skills (fuse logic — do second)

| # | Create | Absorbs |
|---|--------|---------|
| 5 | `walter-worker-skills/doc-review/SKILL.md` | devil-advocate + contrarian-review + work-review |
| 6 | `walter-worker-skills/bug/SKILL.md` | bug-hunt + bug-report + self-heal + self-analyze |
| 7 | `walter-worker-skills/knowledge/SKILL.md` | session-memory + knowledge-skill |
| 8 | `walter-worker-skills/auto-tdd/SKILL.md` | auto-tdd + import-skills/tdd |
| 9 | `walter-worker-skills/research/SKILL.md` | find-my-unknown + superpowers:brainstorming |
| 10 | `walter-worker-skills/doc-organize/SKILL.md` | doc-merge + doc-organize（逻辑互补，自动判断支） |

**For each:** Read the absorbed SKILL.md files in full. Understand the logic,
then write a single fused SKILL.md that:

1. Starts by asking ONE question to determine the mode/branch
2. Each branch has a self-contained process section
3. Old logic is genuinely merged — not copy-pasted side by side

---

## Phase 2: Test L1 + L2 + L3

### Step 2.1 — L2 Structural Tests (automated)

```bash
cd ~/project/skill-factory

# 35 old directories must NOT exist
for dir in \
  initiative-create initiative-edit initiative-activate initiative-deactivate \
  initiative-list initiative-show initiative-remove \
  analytics-create-db analytics-daemon analytics-dashboard analytics-import analytics-once \
  project-add project-edit project-remove project-list project-show project-sync \
  skill-create skill-edit skill-import skill-list \
  devil-advocate contrarian-review work-review \
  bug-hunt bug-report self-analyze self-heal \
  doc-merge doc-organize \
  session-memory knowledge-skill \
  find-my-unknown; do
  if [ -d "walter-worker-skills/$dir" ]; then
    echo "FAIL: walter-worker-skills/$dir still exists"
  else
    echo "PASS: walter-worker-skills/$dir removed"
  fi
done

# import-skills/tdd must NOT exist
if [ -d "import-skills/tdd" ]; then
  echo "FAIL: import-skills/tdd still exists"
else
  echo "PASS: import-skills/tdd removed"
fi

# 10 new directories must exist
for skill in initiative dashboard project skill doc-review doc-organize bug knowledge auto-tdd research; do
  if [ -f "walter-worker-skills/$skill/SKILL.md" ]; then
    echo "PASS: walter-worker-skills/$skill/SKILL.md exists"
  else
    echo "FAIL: walter-worker-skills/$skill/SKILL.md missing"
  fi
done

# 3 independent skills must exist
for skill in english-grammar-fix multi-model-team status; do
  if [ -f "walter-worker-skills/$skill/SKILL.md" ]; then
    echo "PASS: independent skill $skill exists"
  else
    echo "FAIL: independent skill $skill missing"
  fi
done

# 9 personal-skills must exist
count=$(ls personal-skills/*/SKILL.md 2>/dev/null | wc -l)
if [ "$count" -eq 9 ]; then
  echo "PASS: personal-skills count = $count"
else
  echo "FAIL: personal-skills count = $count (expected 9)"
fi
```

### Step 2.2 — L1 Conventions Tests (automated)

```bash
cd ~/project/skill-factory

for skill in initiative dashboard project skill doc-review doc-organize bug knowledge auto-tdd research; do
  file="walter-worker-skills/$skill/SKILL.md"
  echo "=== $skill ==="

  # name field matches directory
  name=$(sed -n '/^---$/,/^---$/p' "$file" | grep '^name:' | sed 's/name: *//')
  if [ "$name" = "$skill" ]; then
    echo "  PASS: name matches directory"
  else
    echo "  FAIL: name='$name' expected='$skill'"
  fi

  # description starts with "Use when"
  desc=$(sed -n '/^---$/,/^---$/p' "$file" | grep '^description:' | head -1)
  if echo "$desc" | grep -q "Use when"; then
    echo "  PASS: description starts with 'Use when'"
  else
    echo "  FAIL: description does not start with 'Use when'"
  fi

  # description ≤ 1024 chars
  desc_len=$(echo "$desc" | wc -c)
  if [ "$desc_len" -le 1024 ]; then
    echo "  PASS: description length = $desc_len (≤1024)"
  else
    echo "  FAIL: description length = $desc_len (>1024)"
  fi

  # license present
  if grep -q '^license:' "$file"; then
    echo "  PASS: license field present"
  else
    echo "  FAIL: license field missing"
  fi

  # required sections
  for section in "# $skill" "## When to Use" "## When NOT to Use" "## Process"; do
    if grep -q "$section" "$file"; then
      echo "  PASS: section '$section' present"
    else
      echo "  FAIL: section '$section' missing"
    fi
  done

  # prohibited content
  if grep -qi 'TODO\|TBD\|changelog' "$file"; then
    echo "  FAIL: prohibited content found (TODO/TBD/changelog)"
  else
    echo "  PASS: no prohibited content"
  fi

  echo ""
done
```

### Step 2.3 — L3 Content Review (manual, use the prompt below)

See the L3 Review Prompt section below. Run this with another model or as a
separate review pass.

---

## Phase 3: Fix Issues + L4 Deployment Test

### Step 3.1 — Fix issues from L1/L2/L3

Address all FAIL items.

### Step 3.2 — Update coworker.yaml

Register the 10 new skills in `~/.coworker/coworker.yaml`, remove old 35 entries.

### Step 3.3 — Sync

```bash
coworker sync
```

### Step 3.4 — L4 Deployment Tests

```bash
# 10 new skills deployed
cmd_count=$(ls ~/.claude/skills/ | grep -E "^(initiative|dashboard|project|skill|doc-review|doc-organize|bug|knowledge|auto-tdd|research)$" | wc -l)
echo "New skills deployed: $cmd_count (expected 10)"

# Old skills removed
old_count=$(ls ~/.claude/skills/ | grep -E "^(initiative-create|initiative-edit|devil-advocate|contrarian-review|bug-hunt|self-heal|find-my-unknown|analytics-dashboard|analytics-import|project-add|skill-create|doc-merge|session-memory)$" | wc -l)
echo "Old skills remaining: $old_count (expected 0)"

# coworker status still works
coworker status
```

---

## Phase 4: Delete Old Directories

Only after all tests pass:

```bash
cd ~/project/skill-factory

# Category 3 — CRUD sets
rm -rf walter-worker-skills/initiative-{create,edit,activate,deactivate,list,show,remove}
rm -rf walter-worker-skills/analytics-{create-db,daemon,dashboard,import,once}
rm -rf walter-worker-skills/project-{add,edit,remove,list,show,sync}
rm -rf walter-worker-skills/skill-{create,edit,import,list}

# Category 1/2 — merged
rm -rf walter-worker-skills/{devil-advocate,contrarian-review,work-review}
rm -rf walter-worker-skills/{bug-hunt,bug-report,self-analyze,self-heal}
rm -rf walter-worker-skills/{doc-merge,doc-organize}
rm -rf walter-worker-skills/{session-memory,knowledge-skill}
rm -rf walter-worker-skills/find-my-unknown
rm -rf import-skills/tdd
```

---

## Phase 5: L5 Functional Smoke Test

In a Claude Code session, invoke each merged skill:

```
/initiative list
/dashboard start
/project list
/skill list
/doc-review          ← should ask "design review or work completion?"
/doc-organize        ← should auto-detect or ask
/bug                 ← should ask "hunt, report, or heal?"
/knowledge           ← should ask "obsidian vault or sqlite analytics?"
/auto-tdd            ← should ask "basic or auto?"
/research            ← should ask "discover unknowns or design spec?"
/english-grammar-fix
/multi-model-team
/status
```

---

## L3 Content Review Prompt

Use this prompt with another model (or as a separate review pass) to verify
that each merged skill correctly fuses the logic of its absorbed skills.

```
You are reviewing merged SKILL.md files in a skill-factory project. Each merged
skill absorbs 2-7 previously-independent skills. Your job: verify that the
merged version faithfully preserves the core logic of each absorbed skill
without losing anything essential.

## Review Rules

For each merged skill, check:

1. **Completeness** — Every absorbed skill's core workflow/process is
   represented in at least one branch of the merged skill.
2. **Fusion quality** — Logic is genuinely fused, not copy-pasted side by side.
   If two absorbed skills share similar steps, those steps should appear once,
   not twice.
3. **Branch clarity** — The merged skill starts by asking ONE clear question.
   Each branch is self-contained and has a clear purpose.
4. **No phantom references** — The merged skill must NOT reference old skill
   names that no longer exist (e.g. no "delegate to devil-advocate" or
   "run bug-hunt").
5. **Severity gate** — For doc-review only: a 5-point severity scale must be
   defined, with explicit instruction that level 1-2 issues are skipped.
6. **When to Use / When NOT to Use** — Covers the union of triggers from all
   absorbed skills, not just one of them.
7. **Conventions compliance** — No TBD/TODO, no decorative emoji in body,
   description is third-person and starts with "Use when".

## Directory Layout

All files are under `walter-worker-skills/`:

### To review (merged skills):

| Merged skill | Absorbed skills (read these OLD files for reference) |
|---|---|
| `initiative/SKILL.md` | initiative-create, initiative-edit, initiative-activate, initiative-deactivate, initiative-list, initiative-show, initiative-remove |
| `dashboard/SKILL.md` | analytics-create-db, analytics-daemon, analytics-dashboard, analytics-import, analytics-once |
| `project/SKILL.md` | project-add, project-edit, project-remove, project-list, project-show, project-sync |
| `skill/SKILL.md` | skill-create, skill-edit, skill-import, skill-list |
| `doc-review/SKILL.md` | devil-advocate, contrarian-review, work-review |
| `doc-organize/SKILL.md` | doc-merge, doc-organize |
| `bug/SKILL.md` | bug-hunt, bug-report, self-heal, self-analyze |
| `knowledge/SKILL.md` | session-memory, knowledge-skill |
| `auto-tdd/SKILL.md` | auto-tdd, ../import-skills/tdd |
| `research/SKILL.md` | find-my-unknown, superpowers:brainstorming |

### To verify unchanged (must NOT be modified):

- english-grammar-fix/SKILL.md
- multi-model-team/SKILL.md
- status/SKILL.md

## Process

For each merged skill:
1. Read the merged SKILL.md
2. Read ALL the absorbed old SKILL.md files
3. Compare: is every core workflow preserved? Is anything lost?
4. Rate: PASS (all 7 rules pass) / MINOR (small issues) / FAIL (missing logic)

## Output Format

For each merged skill, output:

```
### <skill-name>
- Completeness: PASS/MINOR/FAIL — <one sentence why>
- Fusion quality: PASS/MINOR/FAIL — <one sentence why>
- Branch clarity: PASS/MINOR/FAIL — <one sentence why>
- No phantom refs: PASS/FAIL — <list any phantom references found>
- Severity gate (doc-review only): PASS/FAIL
- When/When NOT: PASS/FAIL — <what's missing>
- Conventions: PASS/FAIL — <list violations>
- Overall: PASS/MINOR/FAIL
```

Then list any specific issues that need fixing.

## Independent skills check

Run a separate pass: read english-grammar-fix/SKILL.md, multi-model-team/SKILL.md,
status/SKILL.md — confirm they have NOT been modified from git HEAD.
```

---

## Execution Order Summary

```
Phase 1: Create 10 merged SKILL.md (don't delete old yet)
   ↓
Phase 2: Test L1 (conventions) + L2 (structural) + L3 (content review)
   ↓
Phase 3: Fix issues from tests + L4 (deployment test)
   ↓
Phase 4: Delete 35 old directories
   ↓
Phase 5: L5 (functional smoke test in Claude Code)
   ↓
Commit + push
```
