---
name: skill-edit
description: |
  Use when modifying, fixing, or updating an existing skill in the
  skill-factory project. Use when you need to change a skill's
  instructions, workflow, quality gates, or frontmatter.
license: MIT
compatibility: opencode
metadata:
  triggers:
    - edit a skill
    - fix skill
    - update skill
    - modify skill
    - change skill
  when_to_use: |
    When modifying an existing skill's instructions, workflow, quality
    gates, or frontmatter — any targeted change that does not replace
    the entire file.
  when_not_to_use: |
    When creating a new skill from scratch (use skill-create). When the
    change is a complete rewrite replacing ≥80% of the file (use
    skill-create instead). When editing non-skill files.
  phase_count: 6
  requires: []
  audience:
    - skill-authors
    - skill-maintainers
---

# skill-edit

Safely edits existing skill files in the skill-factory project with full
process enforcement. Every edit goes through audit, plan, apply, verify,
and publish — no changes are committed without quality gate verification.

## When to Use

- You want to modify an existing skill's workflow steps
- You need to update quality gates or add new ones
- You found a bug in a skill's instructions
- You want to add or remove trigger phrases
- You need to improve a skill's anti-patterns or edge case handling

## When NOT to Use

- Creating a new skill from scratch — use skill-create
- The change replaces ≥80% of the file — use skill-create for a fresh start
- Editing non-skill files (source code, docs, configs)
- The target skill file doesn't exist — point user to skill-create

## Process

### Step 1: Reuse Audit

Confirm the target skill exists at `ai-coworker-skills/<name>/SKILL.md`.
Read its frontmatter to verify identity. If the file doesn't exist, STOP
and direct the user to skill-create.

### Step 2: Load Target Skill

Read the full SKILL.md. Note its current structure: sections, quality
gates, process steps, and line numbers for reference.

### Step 3: Interview

Ask one question at a time:
1. What change do you want to make to `<skill-name>`?
2. Is this a targeted edit or does it touch multiple sections?
3. Does this change affect the skill's core behavior or surface details?

If the user describes a complete rewrite (≥80% of the file would change),
STOP and redirect to skill-create.

### Step 4: Plan Changes

Present a diff-style summary of proposed changes:
- Lines to add, remove, and modify
- Sections affected

Get explicit user approval before touching any files. If rejected, return
to Step 3 to clarify.

### Step 5: Apply Changes

Use the Edit tool for targeted changes. Never use Write on the entire
file. Never create a new file or duplicate to a new directory. If an edit
fails (oldString not found), re-read the file and retry.

### Step 6: Verify

Run quality gates in order:
1. The target skill's own quality gates (if present)
2. skill-factory's universal quality gates (from CONVENTIONS.md)
3. Regression check: does the skill still cover its original use case?

All MUST gates must pass before proceeding. Fix failures and re-verify.

### Step 7: Publish

Confirm only the edited file is changed (`git status`). Stage and commit:

```
git add ai-coworker-skills/<name>/SKILL.md
git commit -m "skill(<name>): <imperative verb> <description>"
```

Tell the user the commit hash and ask whether to push.

## Quality Gates

### MUST (block publish on failure)

- [ ] Target skill file exists and was fully read before editing
- [ ] No new files or directories were created
- [ ] No duplicate content was written to a new location
- [ ] Edit was applied to the target skill only
- [ ] Target skill's own quality gates pass (if present)
- [ ] skill-factory universal quality gates pass (per CONVENTIONS.md)
- [ ] No regressions: skill still handles its original use cases
- [ ] Only the edited file appears in `git status`

### NICE (warn but don't block)

- [ ] Diff summary was presented and approved before editing
- [ ] Change is < 50% of the total file
- [ ] No changes to the `name` field unless intentional rename

## Anti-Patterns

### 1. Complete rewrite disguised as edit

**Symptom:** User says "update" but describes changes affecting most
sections.

**Why wrong:** A rewrite should use skill-create to ensure the full
audit, interview, and quality gate pipeline runs.

**Fix:** Estimate % of file changed. If ≥80%, redirect to skill-create.

### 2. Creating a new file instead of editing

**Symptom:** Copying content to a new directory or creating a new
SKILL.md.

**Why wrong:** This is skill-create's job and bypasses the reuse audit.

**Fix:** Use Edit tool on the existing file only.

### 3. Skipping the full file read

**Symptom:** Editing after only reading frontmatter or partial content.

**Why wrong:** You may miss context that makes the edit incorrect.

**Fix:** Always read the complete file in Step 2 before any editing.

### 4. Bypassing quality gates

**Symptom:** Committing after editing without running quality gates.

**Why wrong:** The edit may introduce anti-patterns or regressions.

**Fix:** Run Step 6 (Verify) before Step 7 (Publish). MUST gates block
commit.

### 5. Editing non-existent or wrong skill

**Symptom:** Proceeding with edits when the target file isn't found.

**Why wrong:** May create a file in the wrong location or edit the wrong
skill.

**Fix:** Step 1 blocks if the file doesn't exist.

## Sources

- Process design: confidence high — mirrors skill-create's pipeline
  adapted for edit workflow with diff-then-apply pattern
- Quality gates: confidence high — derived from skill-factory
  CONVENTIONS.md and skill-create's quality gates
- Anti-patterns: confidence high — observed in practice, prevents
  common editing mistakes
- Factor weights: confidence high — user-specified: accuracy 0.4,
  edge case coverage 0.3, readability 0.15, speed 0.1, tool
  integration 0.05
