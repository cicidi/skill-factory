# skill-factory Bootstrap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bootstrap skill-factory with a self-improving iteration loop: fix skill-create, use it to build skill-edit and skill-import via subagent-driven iteration, then import mattpocock's TDD skill and verify end-to-end.

**Architecture:** Three Task subagents per round (Agent-A creates two skills, Agent-B self-evaluates, Agent-C reviews and diagnoses skill-create). Iterative — if skill-create has bugs, fix it and re-run. Exit when Agent-C finds zero MUST violations. Final verification imports and edits TDD skill.

**Tech Stack:** Markdown (SKILL.md files), opencode 5-field frontmatter format, bash/git for file ops, Task subagents for parallel work.

---

### Task 1: Pre-bootstrap — delete ai-worker-skills/

**Files:**
- Delete: `ai-worker-skills/test-flat/.claude-plugin/` (empty dir)
- Delete: `ai-worker-skills/test-flat/` (empty dir)
- Delete: `ai-worker-skills/test-nested/skills/nested-test/` (empty dir)
- Delete: `ai-worker-skills/test-nested/.claude-plugin/` (empty dir)
- Delete: `ai-worker-skills/test-nested/` (empty dir)
- Delete: `ai-worker-skills/` (now empty)

- [ ] **Step 1: Remove empty scaffold directories**

```bash
rm -rf ai-worker-skills/
```

- [ ] **Step 2: Verify removal**

```bash
ls ai-worker-skills/ 2>&1
```
Expected: `ls: cannot access 'ai-worker-skills/': No such file or directory`

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "chore: remove empty ai-worker-skills scaffold"
```

---

### Task 2: Pre-bootstrap — fix skill-create SKILL.md

**Files:**
- Modify: `ai-coworker-skills/skill-create/SKILL.md`

**Issues to fix:**
1. Description contains workflow summary ("Walks through search, interview, build, verify, and publish phases")
2. Description announces `skill-edit` (non-existent skill) — gate violation
3. Description mixes `when_not_to_use` content (line 6)
4. Anti-Pattern 4 title references non-existent "Examples" section

- [ ] **Step 1: Fix description — remove workflow summary and skill-edit reference**

```yaml
# OLD (lines 3-7):
# description: |
#   Use when creating a new skill for the skill-factory project. Walks through
#   search, interview, build, verify, and publish phases with reuse audit and
#   quality gates. For editing existing skills, use a separate skill-edit
#   workflow instead.

# NEW:
description: |
  Use when creating a new skill for the skill-factory project. Use when a
  reusable workflow needs to be captured as a self-contained SKILL.md with
  quality gates. For editing an existing skill, use skill-edit instead.
```

Edit file `ai-coworker-skills/skill-create/SKILL.md`:
- Replace old description with new description

- [ ] **Step 2: Fix When NOT to Use — remove skill-edit reference on line 47, add generic fallback**

Edit line 47 of `ai-coworker-skills/skill-create/SKILL.md`:
```
# OLD:
- You want to edit an existing skill — use skill-edit instead

# NEW:
- You want to edit an existing skill — use skill-edit for safe modifications
```

Also update line 68 (Phase 0 step 3):
```
# OLD:
- **STOP** — tell user: "Found existing skill `X` at path Y. Edit it instead? Use skill-edit."

# NEW:
- **STOP** — tell user: "Found existing skill `X` at path Y. Edit it instead? Use skill-edit (if available) or edit the file directly following CONVENTIONS.md."
```

Also update line 21 (`when_not_to_use` in metadata):
```
# OLD:
For editing an existing skill, use skill-edit. For one-off workflows

# NEW:
For editing an existing skill, use skill-edit (when available). For one-off workflows
```

- [ ] **Step 3: Fix Anti-Pattern 4 title (line 253)**

Edit line 253 of `ai-coworker-skills/skill-create/SKILL.md`:
```
# OLD:
### 4. Verbatim user prompt in Examples

# NEW:
### 4. Verbatim user prompt in test scenarios or examples
```

- [ ] **Step 4: Verify fix — run quality gates on skill-create**

```bash
wc -c < ai-coworker-skills/skill-create/SKILL.md
```
Expected: description section updated, no new violations.

Read the file and manually check:
- description does NOT contain "Walks through", "phases"
- description does NOT reference skill-edit
- Anti-Pattern 4 title no longer says "in Examples"
- All `skill-edit` references now include "(when available)" or "(if available)"

- [ ] **Step 5: Commit**

```bash
git add ai-coworker-skills/skill-create/SKILL.md
git commit -m "fix: remove skill-edit refs and workflow summary from skill-create description"
```

---

### Task 3: Iteration Round — setup docs/rounds/ directory

**Files:**
- Create: `docs/superpowers/rounds/round-01/` (directory)

- [ ] **Step 1: Create round documentation directory**

```bash
mkdir -p docs/superpowers/rounds/round-01
```

- [ ] **Step 2: Create round tracker file**

Write `docs/superpowers/rounds/round-01/status.md`:
```markdown
# Round 01 Status

**Started:** 2026-06-10

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| 1 | Agent-A (skill-edit) | pending | - |
| 2 | Agent-A (skill-import) | pending | - |
| 3 | Agent-B (eval) | pending | - |
| 4 | Agent-C (review) | pending | - |

**Round outcome:** TBD
**skill-create changed?** TBD
```

- [ ] **Step 3: Commit**

```bash
git add docs/superpowers/rounds/round-01/status.md
git commit -m "docs: initialize round-01 tracking"
```

---

### Task 4: Agent-A — create skill-edit

Launch a Task subagent to simulate a user interacting with skill-create to produce skill-edit.

- [ ] **Step 1: Launch Agent-A for skill-edit**

Use the `task` tool with subagent_type=`general`:

**Agent-A prompt:**

```
You are simulating two roles in a skill creation session:
1. A USER who wants to create a skill called "skill-edit" for the skill-factory project
2. An AI following the skill-create process to build it

The project is at /home/cicidi/project/skill-factory. The skill-create SKILL.md is at ai-coworker-skills/skill-create/SKILL.md.

IMPORTANT: Follow the skill-create process EXACTLY (Phase 0 → Phase 1 → Phase 2 → Phase 3). The USER role should simulate reasonable answers to the AI's questions.

SKILL-EDIT REQUIREMENTS (what the USER wants):
- Name: skill-edit
- Purpose: Safely edit existing skills in skill-factory with full process enforcement
- Triggers: "edit a skill", "fix skill", "update skill", "modify skill", "change skill"
- Workflow:
  1. Reuse audit — confirm target skill exists, confirm this is NOT creating a new skill
  2. Load target skill — read current SKILL.md fully
  3. Interview — understand what change the user wants (one question at a time)
  4. Plan changes — show diff summary, get user approval before editing
  5. Apply changes — edit the SKILL.md file
  6. Verify — run quality gates (MUST pass), check no regressions
  7. Publish — commit with conventional message
- Constraints:
  - NEVER create a new skill file (that's skill-create's job)
  - NEVER duplicate into a new directory
  - Every edit must pass MUST quality gates before commit
  - Output diff-style summary of what changed
- When NOT to use: When creating a new skill from scratch, when the change is a complete rewrite
- Success criteria: Accuracy 0.4, Edge case coverage 0.3, Readability 0.15, Speed 0.1, Tool integration 0.05

Follow the skill-create process:
- Phase 0: Search for existing skills in ai-coworker-skills/ (list them, read frontmatter). "skill-edit" doesn't exist yet, so proceed.
- Phase 1: Interview (use the requirements above as USER answers). Ask one question at a time.
- Phase 2: Build the SKILL.md following opencode 5-field frontmatter format and CONVENTIONS.md body structure. Target < 150 lines. Include anti-patterns section, philosophy-driven approach. Quality gates section that block if violated.
- Phase 3: Verify — run quality gates, self-review for TBD/TODO placeholders, internal consistency, scope, ambiguity. 
- Phase 4: Present complete skill to USER for approval. After approval, output the FINAL SKILL.md content.

DO NOT actually commit to git — just output the final SKILL.md content between ``` markers.

Save your session log to: docs/superpowers/rounds/round-01/agent-a-skill-edit.md with format:
- Process steps taken
- User answers given
- Final SKILL.md content
```

- [ ] **Step 2: Save Agent-A skill-edit output**

When Agent-A completes, save its output to `docs/superpowers/rounds/round-01/agent-a-skill-edit.md`.

- [ ] **Step 3: Write skill-edit to disk**

```bash
mkdir -p ai-coworker-skills/skill-edit
# Write the SKILL.md content from Agent-A output to ai-coworker-skills/skill-edit/SKILL.md
```

- [ ] **Step 4: Commit**

```bash
git add ai-coworker-skills/skill-edit/SKILL.md docs/superpowers/rounds/round-01/agent-a-skill-edit.md
git commit -m "skill: add skill-edit — safe editing of existing skills"
```

---

### Task 5: Agent-A — create skill-import

Launch a second Task subagent to produce skill-import.

- [ ] **Step 1: Launch Agent-A for skill-import**

Use the `task` tool with subagent_type=`general`:

**Agent-A prompt:**

```
You are simulating two roles in a skill creation session:
1. A USER who wants to create a skill called "skill-import" for the skill-factory project
2. An AI following the skill-create process to build it

The project is at /home/cicidi/project/skill-factory. The skill-create SKILL.md is at ai-coworker-skills/skill-create/SKILL.md.

IMPORTANT: Follow the skill-create process EXACTLY (Phase 0 → Phase 1 → Phase 2 → Phase 3). The USER role should simulate reasonable answers.

SKILL-IMPORT REQUIREMENTS (what the USER wants):
- Name: skill-import
- Purpose: Import external skills (from GitHub URLs, other repos) into skill-factory, converting them to opencode 5-field frontmatter format
- Triggers: "import a skill", "import skill", "add skill from", "convert skill", "pull skill"
- Workflow:
  1. Receive URL to external SKILL.md
  2. Fetch source SKILL.md content (use webfetch or curl)
  3. Auto-convert frontmatter:
     - Map source `name` → opencode `name`
     - Map source `description` → opencode `description` (rewrite to start with "Use when...")
     - Missing `license` → "MIT"
     - Missing `compatibility` → "opencode, claude-code"
     - Infer `metadata.triggers` from skill name and description
     - Infer `metadata.when_to_use` / `metadata.when_not_to_use`
  4. Auto-adapt body sections to CONVENTIONS.md structure:
     - Philosophy sections → overview in heading
     - Anti-Pattern sections → `## Anti-Patterns`
     - Workflow sections → `## Process`
     - Checklist sections → `## Quality Gates`
  5. Subagent asks user ONE QUESTION AT A TIME only when ambiguous:
     - Source has no license field → "Default MIT ok? (y/n)"
     - Cannot infer triggers → "What trigger phrases should activate this skill?"
     - Source body structure is unclear → ask how to map specific sections
  6. Write converted skill to `ai-coworker-skills/<name>/SKILL.md`
  7. Commit with conventional message: `skill: import <name> from <source-repo>`
- When NOT to use: When skill already exists in skill-factory, when source is not a valid SKILL.md, when the conversion requires content rewriting beyond format mapping
- Success criteria: Accuracy 0.4, Tool integration 0.25, Edge case coverage 0.2, Readability 0.1, Speed 0.05
- Factor weights: Accuracy 0.4, Tool integration 0.25, Edge cases 0.2, Readability 0.1, Speed 0.05

Follow the skill-create process:
- Phase 0: Search existing skills. "skill-import" doesn't exist yet, proceed. Note: skill-edit and skill-create already exist in ai-coworker-skills/.
- Phase 1: Interview (use the requirements above as USER answers). Ask one question at a time.
- Phase 2: Build the SKILL.md following opencode 5-field frontmatter and CONVENTIONS.md body structure. Target < 150 lines. Include detailed conversion rules table. Include philosophy-driven approach. Quality gates section.
- Phase 3: Verify — run quality gates, self-review.
- Phase 4: Present complete skill. After USER approval, output FINAL SKILL.md content between ``` markers.

DO NOT commit — just output the SKILL.md content.

Save session log to: docs/superpowers/rounds/round-01/agent-a-skill-import.md
```

- [ ] **Step 2: Save Agent-A skill-import output**

When Agent-A completes, save output to `docs/superpowers/rounds/round-01/agent-a-skill-import.md`.

- [ ] **Step 3: Write skill-import to disk**

```bash
mkdir -p ai-coworker-skills/skill-import
# Write the SKILL.md content from Agent-A output to ai-coworker-skills/skill-import/SKILL.md
```

- [ ] **Step 4: Commit**

```bash
git add ai-coworker-skills/skill-import/SKILL.md docs/superpowers/rounds/round-01/agent-a-skill-import.md
git commit -m "skill: add skill-import — import external skills with format conversion"
```

---

### Task 6: Agent-B — self-evaluate both skills

Launch agent to evaluate skill-edit and skill-import against CONVENTIONS.md + quality gates.

- [ ] **Step 1: Launch Agent-B**

**Agent-B prompt:**

```
You are a skill quality evaluator. Evaluate TWO newly created skills against the project conventions.

Project: /home/cicidi/project/skill-factory
Skills to evaluate:
  1. ai-coworker-skills/skill-edit/SKILL.md
  2. ai-coworker-skills/skill-import/SKILL.md

Evaluation criteria (from CONVENTIONS.md):
  MUST:
    - Frontmatter 5 fields complete: name, description, license, compatibility, metadata
    - name matches folder name
    - description ≤ 1024 chars, starts with "Use when...", no workflow summary, no first person
    - No references to non-existent skills or scripts/schemas
    - No Changelog, Convention Notes, concrete-context leaks
    - No decorative emoji, OCR artifacts, TBD/TODO, truncated sentences
  NICE:
    - Body < 150 lines (stretch: < 500 lines from original CONVENTIONS)
    - ## Sources section present with confidence levels
    - ## Anti-Patterns section present
    - Checklist per phase

For each skill, produce:
  1. MUST violations (blocking) — list each with line reference
  2. NICE warnings (non-blocking) — list each
  3. Overall score: PASS (zero MUST violations) / FAIL (MUST violations present)
  4. Recommendations for improvement

Format output as markdown table with clear pass/fail.

Save to: docs/superpowers/rounds/round-01/agent-b-eval.md
```

- [ ] **Step 2: Save Agent-B output**

Save to `docs/superpowers/rounds/round-01/agent-b-eval.md`.

- [ ] **Step 3: Commit**

```bash
git add docs/superpowers/rounds/round-01/agent-b-eval.md
git commit -m "docs: round-01 agent-B self-evaluation of skill-edit and skill-import"
```

---

### Task 7: Agent-C — review + diagnose skill-create

Launch agent to review the two skills, diagnose root cause in skill-create, and fix it if needed.

- [ ] **Step 1: Launch Agent-C**

**Agent-C prompt:**

```
You are a skill quality auditor. Your job:

1. REVIEW both skill-edit and skill-import SKILL.md files (read them fully):
   - ai-coworker-skills/skill-edit/SKILL.md
   - ai-coworker-skills/skill-import/SKILL.md
   Read Agent-B's evaluation: docs/superpowers/rounds/round-01/agent-b-eval.md
   
   For each skill, check ALL quality gates (MUST and NICE). Find any issues Agent-B missed.

2. DIAGNOSE skill-create (read it fully):
   - ai-coworker-skills/skill-create/SKILL.md
   
   If skill-edit or skill-import has issues, trace them back to skill-create:
   - Did skill-create miss a quality gate that allowed the defect?
   - Is skill-create's Phase 2 (Build) instruction incomplete?
   - Is skill-create's Phase 3 (Verify) not catching issues?
   - Is skill-create missing important anti-patterns?
   
   Specific checks:
   - Does skill-create enforce body < 150 lines? (Current NICE gate says < 500 lines — too loose)
   - Does skill-create require anti-patterns section?
   - Does skill-create check description starts with "Use when..."?
   - Does skill-create's quality gates match CONVENTIONS.md?

3. FIX skill-create if it has defects:
   - Edit ai-coworker-skills/skill-create/SKILL.md to fix any issues found
   - Common fixes:
     - Tighten line count NICE from < 500 to < 150
     - Add anti-patterns section as NICE requirement
     - Add checklist-per-phase as NICE requirement
     - Fix any ambiguity in Phase 2 instructions

4. OUTPUT:
   ```
   ## Agent-C Review Report

   ### skill-edit Issues
   - (list or "none")

   ### skill-import Issues
   - (list or "none")

   ### skill-create Diagnosis
   - (root cause analysis)

   ### skill-create Changes Made
   - (list of edits, or "no changes needed")

   ### Round Outcome
   - MUST violations remaining: N
   - skill-create changed: yes/no
   - Next action: (iterate / proceed to final verification)
   ```

5. SAVE: Write this report to docs/superpowers/rounds/round-01/agent-c-review.md

IMPORTANT: If you make changes to skill-create, you MUST commit them:
```bash
git add ai-coworker-skills/skill-create/SKILL.md docs/superpowers/rounds/round-01/agent-c-review.md
git commit -m "fix: skill-create quality gate improvements from round-01 review"
```

DO NOT delete or recreate skill-edit or skill-import — only fix skill-create.
```

- [ ] **Step 2: Check Agent-C output**

Read `docs/superpowers/rounds/round-01/agent-c-review.md` to determine:
- If `skill-create changed: yes` → go back to Task 4 with round-02
- If `skill-create changed: no` AND `MUST violations remaining: 0` → proceed to Task 8
- If `skill-create changed: no` BUT `MUST violations remaining > 0` → manual decision needed

---

### Task 8: [Conditional] Fix remaining MUST violations in skill-edit/skill-import

If Agent-C finds MUST violations that are NOT caused by skill-create defects (e.g., Agent-A execution errors), fix them directly.

- [ ] **Step 1: Read Agent-C's issue list for each skill**

- [ ] **Step 2: Apply targeted fixes to skill-edit/SKILL.md or skill-import/SKILL.md**

- [ ] **Step 3: Commit**

```bash
git add ai-coworker-skills/skill-edit/SKILL.md ai-coworker-skills/skill-import/SKILL.md
git commit -m "fix: address MUST gate violations from round-NN review"
```

---

### Task 9: Final Verification — import mattpocock TDD skill

Use skill-import to import the TDD skill.

- [ ] **Step 1: Fetch source TDD SKILL.md**

The skill-import process says: fetch URL, convert format. We can do this directly following skill-import's workflow.

The source URL: https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/SKILL.md

Read the raw source and apply conversion rules:
- name: tdd → tdd
- description: rewrite to "Use when..."
- license: MIT
- compatibility: opencode, claude-code
- Infer triggers from description

- [ ] **Step 2: Create converted TDD skill**

```bash
mkdir -p ai-coworker-skills/tdd
```

Write `ai-coworker-skills/tdd/SKILL.md` with converted content.

- [ ] **Step 3: Commit**

```bash
git add ai-coworker-skills/tdd/SKILL.md
git commit -m "skill: import tdd from mattpocock/skills"
```

- [ ] **Step 4: Document**

Save import log to `docs/superpowers/final-verification/import-tdd.md`:
```markdown
# TDD Skill Import

**Source:** mattpocock/skills/skills/engineering/tdd/SKILL.md
**Date:** 2026-06-10
**Conversion changes:**
- (list of changes made during conversion)
```

- [ ] **Step 5: Commit documentation**

```bash
git add docs/superpowers/final-verification/import-tdd.md
git commit -m "docs: TDD skill import log"
```

---

### Task 10: Final Verification — optimize TDD skill with skill-edit

Use skill-edit to review and improve the imported TDD skill.

- [ ] **Step 1: Run skill-edit on TDD skill**

Following skill-edit's workflow:
1. Load `ai-coworker-skills/tdd/SKILL.md`
2. Verify it passes MUST quality gates from CONVENTIONS.md
3. If issues found, apply fixes:
   - Ensure description starts with "Use when..."
   - Ensure no workflow summary in description
   - Check for concrete-context leaks
   - Verify all body sections follow CONVENTIONS.md structure

- [ ] **Step 2: Apply optimizations**

Common TDD skill optimizations:
- Add `## When to Use` / `## When NOT to Use` (inferred from body)
- Add `## Quality Gates` section (extracted from "Checklist Per Cycle")
- Add `## Sources` section
- Ensure no references to non-existent companion files (tests.md, mocking.md, etc. — these don't exist in skill-factory)

- [ ] **Step 3: Verify with quality gates**

Check all MUST and NICE gates pass for the edited TDD skill.

- [ ] **Step 4: Commit**

```bash
git add ai-coworker-skills/tdd/SKILL.md
git commit -m "fix: optimize imported tdd skill for skill-factory conventions"
```

- [ ] **Step 5: Document**

Save to `docs/superpowers/final-verification/edit-tdd.md`:
```markdown
# TDD Skill Optimization

**Date:** 2026-06-10
**Changes made:**
- (list of optimizations)
**Quality gate result:** PASS (N MUST violations, M NICE warnings)
```

- [ ] **Step 6: Commit documentation**

```bash
git add docs/superpowers/final-verification/edit-tdd.md
git commit -m "docs: TDD skill optimization log"
```

---

### Task 11: Write final summary

- [ ] **Step 1: Create summary document**

Write `docs/superpowers/summary.md`:
```markdown
# skill-factory Bootstrap Summary

**Date:** 2026-06-10
**Total rounds:** N
**Final state:**

| Skill | Status | MUST violations | Lines |
|-------|--------|-----------------|-------|
| skill-create | fixed | 0 | ... |
| skill-edit | created | 0 | ... |
| skill-import | created | 0 | ... |
| tdd | imported + optimized | 0 | ... |

## Final Verification Results
- skill-import successfully imported TDD from mattpocock/skills: PASS
- skill-edit successfully optimized TDD skill: PASS

## Iteration History
- Round 01: ...
- Round 02: ...

## Architecture
(See spec for full design)
```

- [ ] **Step 2: Commit**

```bash
git add docs/superpowers/summary.md
git commit -m "docs: bootstrap summary"
```

- [ ] **Step 3: Final status check**

```bash
git log --oneline -20
```
