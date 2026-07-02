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
    - edit ai-coworker skill
    - fix ai-coworker skill
  when_to_use: |
    When modifying an existing skill's instructions, workflow, quality
    gates, or frontmatter — any targeted change that does not replace
    the entire file.
  when_not_to_use: |
    When creating a new skill from scratch (use ai-coworker-skill-create). When the
    change is a complete rewrite replacing ≥80% of the file (use
    ai-coworker-skill-create instead). When editing non-skill files.
  phase_count: 8
  requires: []
  audience:
    - skill-authors
    - skill-maintainers
---

# ai-coworker-skill-edit

Safely edits existing skill files in the skill-factory source code
repository with full process enforcement. Every edit goes through audit,
plan, apply, verify, publish, and deploy — no changes are deployed to
IDE config directories without going through the source repo first.

## When to Use

- You want to modify an existing skill's workflow steps
- You need to update quality gates or add new ones
- You found a bug in a skill's instructions
- You want to add or remove trigger phrases
- You need to improve a skill's anti-patterns or edge case handling

## When NOT to Use

- Creating a new skill from scratch — use ai-coworker-skill-create
- The change replaces ≥80% of the file — use ai-coworker-skill-create for a fresh start
- Editing non-skill files (source code, docs, configs)
- The target skill file doesn't exist — point user to ai-coworker-skill-create

## Source Repo

This skill MUST operate on the source code repository, NOT on deployed
copies. The source repo is the canonical location for skill files.

**Detect the source repo path:**
1. Check env var `SKILL_FACTORY_SOURCE` — if set, use it.
2. Check `~/project/skill-factory/` — if it exists and has `.git`, use it.
3. If neither exists, ask the user: "Where is the skill-factory source repo?"
4. If source repo not found, STOP — do not edit deployed copies directly.

Store the path as `$SOURCE_REPO` and use it throughout all steps.

## Process

### Step 1: Reuse Audit

Confirm the target skill exists at `$SOURCE_REPO/ai-coworker-skills/<name>/SKILL.md`
(or `$SOURCE_REPO/personal-skills/<name>/SKILL.md`, or `$SOURCE_REPO/import-skills/<name>/SKILL.md`).
Read its frontmatter to verify identity.

If the file doesn't exist in the source repo but does exist in the deployed copy
(`~/.config/opencode/skills/skill-factory/`), WARN the user: "Skill exists in
deployed copy but not in source repo. It was likely created directly in the
deployed copy. Backport it to the source repo first, then edit."

If the file doesn't exist anywhere, STOP and direct the user to ai-coworker-skill-create.

### Step 2: Load Target Skill

Read the full SKILL.md from the source repo. Note its current structure: sections,
quality gates, process steps, and line numbers for reference.

### Step 3: Interview

Ask one question at a time:
1. What change do you want to make to `<skill-name>`?
2. Is this a targeted edit or does it touch multiple sections?
3. Does this change affect the skill's core behavior or surface details?

If the user describes a complete rewrite (≥80% of the file would change),
STOP and redirect to ai-coworker-skill-create.

### Step 4: Plan Changes

Present a diff-style summary of proposed changes:
- Lines to add, remove, and modify
- Sections affected

Get explicit user approval before touching any files. If rejected, return
to Step 3 to clarify.

### Step 5: Apply Changes

Use the Edit tool for targeted changes in the source repo. Never use Write
on the entire file. Never create a new file or duplicate to a new directory.
If an edit fails (oldString not found), re-read the file and retry.

If the edit changes the skill's `name` field (rename), check that the new
name doesn't already exist in the source repo. If it does, STOP — report
duplicate and ask user to choose a different name or merge.

### Step 6: Verify

Run quality gates in order:
1. The target skill's own quality gates (if present)
2. skill-factory's universal quality gates (from CONVENTIONS.md)
3. Regression check: does the skill still cover its original use case?

All MUST gates must pass before proceeding. Fix failures and re-verify.

### Step 7: Publish

Publish to the source code repo's git history.

Confirm only the edited file is changed:
```bash
git -C "$SOURCE_REPO" status
```

Stage and commit:
```bash
git -C "$SOURCE_REPO" add ai-coworker-skills/<name>/SKILL.md
git -C "$SOURCE_REPO" commit -m "skill(<name>): <imperative verb> <description>"
git -C "$SOURCE_REPO" push origin master
```

Tell the user the commit hash.

### Step 8: Deploy

Sync the edited skill from source repo to deployed copies and IDE configs.

1. **Sync deployed OpenCode copy:**
   ```bash
   git -C ~/.config/opencode/skills/skill-factory/ pull --ff-only origin master
   ```
   If pull fails, copy the specific file:
   ```bash
   cp "$SOURCE_REPO/ai-coworker-skills/<name>/SKILL.md" ~/.config/opencode/skills/skill-factory/ai-coworker-skills/<name>/SKILL.md
   ```

2. **Deploy to Claude Code:**
   ```bash
   cp "$SOURCE_REPO/ai-coworker-skills/<name>/SKILL.md" ~/.claude/commands/<name>.md
   ```

3. **Deploy to OpenCode instructions:**
   ```bash
   cp "$SOURCE_REPO/ai-coworker-skills/<name>/SKILL.md" ~/.opencode/instructions/<name>.md
   ```

4. Verify each destination file was updated.

## Quality Gates

### MUST (block publish on failure)

- [ ] Source repo detected and verified (`$SOURCE_REPO` exists and is a git repo)
- [ ] Target skill file exists in source repo and was fully read before editing
- [ ] No new files or directories were created
- [ ] No duplicate content was written to a new location
- [ ] Edit was applied to the source repo, not deployed copy or IDE config
- [ ] Target skill's own quality gates pass (if present)
- [ ] skill-factory universal quality gates pass (per CONVENTIONS.md)
- [ ] No regressions: skill still handles its original use cases
- [ ] Only the edited file appears in `git -C "$SOURCE_REPO" status`
- [ ] If name was changed, no existing skill with the new name
- [ ] Step 8 deploy completed: skill synced to OpenCode + Claude Code config dirs

### NICE (warn but don't block)

- [ ] Diff summary was presented and approved before editing
- [ ] Change is < 50% of the total file
- [ ] No changes to the `name` field unless intentional rename

## Anti-Patterns

### 1. Editing deployed copies directly

**Symptom:** Changes made to `~/.config/opencode/skills/skill-factory/`,
`~/.claude/commands/`, or `~/.opencode/instructions/` instead of the source repo.

**Why wrong:** Deployed copies get overwritten by install/sync. Edits to deployed
copies are lost on next install. Source repo is canonical.

**Fix:** Always edit in `$SOURCE_REPO`. Deploy only after commit and push.

### 2. Complete rewrite disguised as edit

**Symptom:** User says "update" but describes changes affecting most
sections.

**Why wrong:** A rewrite should use ai-coworker-skill-create to ensure the full
audit, interview, and quality gate pipeline runs.

**Fix:** Estimate % of file changed. If ≥80%, redirect to ai-coworker-skill-create.

### 3. Creating a new file instead of editing

**Symptom:** Copying content to a new directory or creating a new
SKILL.md.

**Why wrong:** This is ai-coworker-skill-create's job and bypasses the reuse audit.

**Fix:** Use Edit tool on the existing file only.

### 4. Skipping the full file read

**Symptom:** Editing after only reading frontmatter or partial content.

**Why wrong:** You may miss context that makes the edit incorrect.

**Fix:** Always read the complete file in Step 2 before any editing.

### 5. Bypassing quality gates

**Symptom:** Committing after editing without running quality gates.

**Why wrong:** The edit may introduce anti-patterns or regressions.

**Fix:** Run Step 6 (Verify) before Step 7 (Publish). MUST gates block
commit.

### 6. Editing non-existent or wrong skill

**Symptom:** Proceeding with edits when the target file isn't found.

**Why wrong:** May create a file in the wrong location or edit the wrong
skill.

**Fix:** Step 1 blocks if the file doesn't exist.

### 7. Skipping deploy phase

**Symptom:** Skill committed and pushed but not deployed to IDE configs.

**Why wrong:** The edited skill won't take effect until deployed.

**Fix:** Run Step 8 (Deploy) after Step 7 (Publish).

## Sources

- Process design: confidence high — mirrors ai-coworker-skill-create's pipeline
  adapted for edit workflow with diff-then-apply pattern, source repo enforcement
- Quality gates: confidence high — derived from skill-factory
  CONVENTIONS.md and ai-coworker-skill-create's quality gates
- Anti-patterns: confidence high — observed in practice, prevents
  common editing mistakes including deployed-copy editing
- Deploy step: confidence high — mirrors install.sh deployment paths
