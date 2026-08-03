---
state: final
final_date: 2026-08-02
---

# Wayfinder Import — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Import 4 Matt Pocock skills (wayfinder, grill-with-docs, domain-modeling, prototype) into skill-factory's `import-skills/` with wayfinder adapted per spec.

**Architecture:** Fetch source SKILL.md files from GitHub, convert frontmatter to skill-factory conventions, adapt wayfinder (brief terminology, pluggable interfaces, review gates), write to `import-skills/`, validate conventions, doc-review, deploy.

**Tech Stack:** `curl` for fetch, YAML/markdown editing, `coworker skill` CLI, `doc-review` skill.

**Test Plan:** `docs/spec-driven-development/test-plan/wayfinder-import-test-plan.md`
— 12 test cases (TC-01 through TC-12). Each task below references which TCs it satisfies.

## Global Constraints

- All SKILL.md files go to `import-skills/<name>/SKILL.md`
- Frontmatter: 5 fields (name, description starting "Use when...", license: MIT, compatibility, metadata)
- metadata: triggers, when_to_use, when_not_to_use, audience, source_author (mattpocock), source_url
- No prohibited sections (Changelog, Convention Notes)
- No TBD/TODO, no decorative emoji, no concrete-context leaks
- research skill is NOT imported (ai-coworker has its own)
- All files must pass CONVENTIONS.md compliance before deploy

---

### Task 1: Fetch Source SKILL.md Files

**Files:**
- Create: `/tmp/wayfinder-import/wayfinder-original.md`
- Create: `/tmp/wayfinder-import/grill-with-docs-original.md`
- Create: `/tmp/wayfinder-import/domain-modeling-original.md`
- Create: `/tmp/wayfinder-import/prototype-original.md`

**Produces:** 4 raw SKILL.md files downloaded from GitHub.
**Verifies:** (pre-condition for all downstream tasks)

- [ ] **Step 1: Fetch wayfinder SKILL.md**

```bash
mkdir -p /tmp/wayfinder-import
curl -sL https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/wayfinder/SKILL.md \
  -o /tmp/wayfinder-import/wayfinder-original.md
```

Expected: file exists, contains `name: wayfinder`

- [ ] **Step 2: Fetch grill-with-docs SKILL.md**

```bash
curl -sL https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/grill-with-docs/SKILL.md \
  -o /tmp/wayfinder-import/grill-with-docs-original.md
```

Expected: file exists, contains `name: grill-with-docs`

- [ ] **Step 3: Fetch domain-modeling SKILL.md**

```bash
curl -sL https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/domain-modeling/SKILL.md \
  -o /tmp/wayfinder-import/domain-modeling-original.md
```

Expected: file exists, contains `name: domain-modeling`

- [ ] **Step 4: Fetch prototype SKILL.md**

```bash
curl -sL https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/prototype/SKILL.md \
  -o /tmp/wayfinder-import/prototype-original.md
```

Expected: file exists, contains `name: prototype`

- [ ] **Step 5: Fetch domain-modeling reference files (CONTEXT-FORMAT.md, ADR-FORMAT.md)**

```bash
curl -sL https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/domain-modeling/CONTEXT-FORMAT.md \
  -o /tmp/wayfinder-import/CONTEXT-FORMAT.md
curl -sL https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/domain-modeling/ADR-FORMAT.md \
  -o /tmp/wayfinder-import/ADR-FORMAT.md
```

Expected: both files exist and contain markdown.

- [ ] **Step 6: Verify all files fetched**

```bash
wc -l /tmp/wayfinder-import/*.md
```

Expected: all files have content (>10 lines each).

---

### Task 2: Process grill-with-docs (Frontmatter Conversion)

**Files:**
- Create: `import-skills/grill-with-docs/SKILL.md`

**Consumes:** `/tmp/wayfinder-import/grill-with-docs-original.md`
**Produces:** `import-skills/grill-with-docs/SKILL.md`
**Verifies:** TC-01, TC-02, TC-03, TC-05

- [ ] **Step 1: Create directory**

```bash
mkdir -p /home/cicidi/project/skill-factory/import-skills/grill-with-docs
```

- [ ] **Step 2: Write SKILL.md with converted frontmatter**

```markdown
---
name: grill-with-docs
description: |
  Use when you need a relentless interview to sharpen a plan or design. Writes
  ADRs and glossary (CONTEXT.md) inline as terminology crystallizes. Composes
  /grilling and /domain-modeling into one session.
license: MIT
compatibility: claude-code,opencode
metadata:
  triggers:
    - grill with docs
    - sharpen plan
    - grilling session
    - domain interview
  when_to_use: |
    When a plan or design is fuzzy and needs relentless questioning to become
    sharp. When domain terminology must be captured and written to CONTEXT.md
    and ADRs during the conversation.
  when_not_to_use: |
    When requirements are already crystal clear. When the user just wants a
    quick answer, not a full interview session.
  audience:
    - developers
    - architects
  source_author: mattpocock
  source_url: https://github.com/mattpocock/skills/blob/main/skills/engineering/grill-with-docs/SKILL.md
---

# grill-with-docs

Run a `/grilling` session, using the `/domain-modeling` skill.
```

- [ ] **Step 3: Verify frontmatter**

```bash
head -30 /home/cicidi/project/skill-factory/import-skills/grill-with-docs/SKILL.md
```

Expected: all 5 frontmatter fields present, description starts with "Use when".

---

### Task 3: Process domain-modeling (Frontmatter Conversion)

**Files:**
- Create: `import-skills/domain-modeling/SKILL.md`
- Create: `import-skills/domain-modeling/CONTEXT-FORMAT.md`
- Create: `import-skills/domain-modeling/ADR-FORMAT.md`

**Consumes:** `/tmp/wayfinder-import/domain-modeling-original.md`, `/tmp/wayfinder-import/CONTEXT-FORMAT.md`, `/tmp/wayfinder-import/ADR-FORMAT.md`
**Produces:** `import-skills/domain-modeling/SKILL.md` + reference files
**Verifies:** TC-01, TC-02, TC-03, TC-05, TC-09

- [ ] **Step 1: Create directory**

```bash
mkdir -p /home/cicidi/project/skill-factory/import-skills/domain-modeling
```

- [ ] **Step 2: Write SKILL.md with converted frontmatter + original body**

The body is kept as-is from the source (all the "Challenge against the glossary", "Sharpen fuzzy language", etc. sections). Only frontmatter is converted:

```yaml
---
name: domain-modeling
description: |
  Use when building or sharpening a project's domain model. Challenges fuzzy
  terminology, stress-tests with scenarios, writes CONTEXT.md glossary and
  ADRs inline. Use when terms need pinning down or another skill needs to
  maintain the domain model.
license: MIT
compatibility: claude-code,opencode
metadata:
  triggers:
    - domain model
    - glossary
    - ubiquitous language
    - terminology
    - ADR
    - architectural decision
  when_to_use: |
    When domain terminology is fuzzy or overloaded. When a project glossary
    needs to be created or maintained. When an architectural decision must
    be recorded as an ADR.
  when_not_to_use: |
    When just reading existing terminology (that's a one-line habit). When
    no domain changes are being made.
  audience:
    - developers
    - architects
  source_author: mattpocock
  source_url: https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/SKILL.md
---
```

- [ ] **Step 3: Copy reference files**

```bash
cp /tmp/wayfinder-import/CONTEXT-FORMAT.md /home/cicidi/project/skill-factory/import-skills/domain-modeling/
cp /tmp/wayfinder-import/ADR-FORMAT.md /home/cicidi/project/skill-factory/import-skills/domain-modeling/
```

- [ ] **Step 4: Verify**

```bash
ls -la /home/cicidi/project/skill-factory/import-skills/domain-modeling/
wc -l /home/cicidi/project/skill-factory/import-skills/domain-modeling/SKILL.md
```

Expected: 3 files, SKILL.md has all body sections preserved.

---

### Task 4: Process prototype (Frontmatter Conversion)

**Files:**
- Create: `import-skills/prototype/SKILL.md`

**Consumes:** `/tmp/wayfinder-import/prototype-original.md`
**Produces:** `import-skills/prototype/SKILL.md`
**Verifies:** TC-01, TC-02, TC-03, TC-05

- [ ] **Step 1: Create directory**

```bash
mkdir -p /home/cicidi/project/skill-factory/import-skills/prototype
```

- [ ] **Step 2: Write SKILL.md with converted frontmatter + original body**

```yaml
---
name: prototype
description: |
  Use when building a throwaway prototype to answer a design question.
  Two branches: logic/state-model terminal app, or UI variations on a
  single route. Use when sanity-checking whether a state model feels
  right, or exploring what a UI should look like.
license: MIT
compatibility: claude-code,opencode
metadata:
  triggers:
    - prototype
    - throwaway
    - state model
    - UI exploration
    - sanity check
  when_to_use: |
    When a design question is best answered by a concrete artifact. When
    "how should it look" or "how should it behave" needs a visual or
    interactive answer.
  when_not_to_use: |
    When the answer is already clear from documentation. When building
    production code directly is faster than prototyping.
  audience:
    - developers
    - designers
  source_author: mattpocock
  source_url: https://github.com/mattpocock/skills/blob/main/skills/engineering/prototype/SKILL.md
---
```

- [ ] **Step 3: Verify**

```bash
head -30 /home/cicidi/project/skill-factory/import-skills/prototype/SKILL.md
```

---

### Task 5: Adapt wayfinder — Core Rewrite

**Files:**
- Create: `import-skills/wayfinder/SKILL.md`

**Consumes:** `/tmp/wayfinder-import/wayfinder-original.md`
**Produces:** `import-skills/wayfinder/SKILL.md` with all adaptations applied.
**Verifies:** TC-01, TC-02, TC-03, TC-04, TC-06, TC-07, TC-08

Adaptations to apply:
1. **Terminology:** ticket → brief everywhere
2. **Attribution:** source_author + source_url in metadata
3. **Pluggable interfaces:** interview/investigate/prototype/tracker sections with config mechanism
4. **Delivery review gate:** in Work the Map step 4
5. **Doc-organize:** inline discipline for mkdocs-ready
6. **Doc-review checkpoint:** after to-spec, before to-tickets
7. **Frontmatter:** skill-factory 5-field format

- [ ] **Step 1: Create directory**

```bash
mkdir -p /home/cicidi/project/skill-factory/import-skills/wayfinder
```

- [ ] **Step 2: Write adapted SKILL.md**

Write the full adapted file (see Task 5 appendix below).

- [ ] **Step 3: Verify ticket → brief replacement**

```bash
grep -c "brief" /home/cicidi/project/skill-factory/import-skills/wayfinder/SKILL.md
grep "\bticket\b" /home/cicidi/project/skill-factory/import-skills/wayfinder/SKILL.md | grep -v "to-tickets" | grep -v "Jira ticket" | grep -v "build ticket"
```

Expected: `ticket` only appears in "to-tickets", "Jira ticket", or "build ticket" contexts. All decision tickets are "brief".

- [ ] **Step 4: Verify all 5 frontmatter fields**

```bash
grep -E "^name:|^description:|^license:|^compatibility:|^metadata:" /home/cicidi/project/skill-factory/import-skills/wayfinder/SKILL.md
```

Expected: all 5 present.

- [ ] **Step 5: Verify pluggable interfaces section exists**

```bash
grep -A 30 "Pluggable Skill Interfaces" /home/cicidi/project/skill-factory/import-skills/wayfinder/SKILL.md
```

- [ ] **Step 6: Verify review gate exists**

```bash
grep -A 15 "Delivery Review Gate" /home/cicidi/project/skill-factory/import-skills/wayfinder/SKILL.md
```

- [ ] **Step 7: Verify doc-review checkpoint exists**

```bash
grep -A 15 "Spec Creation & Doc-Review Checkpoint" /home/cicidi/project/skill-factory/import-skills/wayfinder/SKILL.md
```

---

### Task 6: Convention Compliance Check

**Files:**
- Modify: `import-skills/wayfinder/SKILL.md` (if issues found)
- Modify: `import-skills/grill-with-docs/SKILL.md` (if issues found)
- Modify: `import-skills/domain-modeling/SKILL.md` (if issues found)
- Modify: `import-skills/prototype/SKILL.md` (if issues found)

**Consumes:** All 4 SKILL.md files from Tasks 2-5.
**Verifies:** TC-01, TC-02 (re-runs all static checks as final gate before commit)

- [ ] **Step 1: Check all files against CONVENTIONS.md**

Read `/home/cicidi/project/skill-factory/CONVENTIONS.md` and verify each SKILL.md:
- [ ] `import-skills/wayfinder/SKILL.md`
- [ ] `import-skills/grill-with-docs/SKILL.md`
- [ ] `import-skills/domain-modeling/SKILL.md`
- [ ] `import-skills/prototype/SKILL.md`

Checklist per file:
- [ ] No prohibited sections (Changelog, Convention Notes)
- [ ] No TBD/TODO/truncated sentences
- [ ] No decorative emoji in body
- [ ] No concrete-context leaks
- [ ] description ≤ 1024 chars, starts with "Use when", third person
- [ ] name matches folder name
- [ ] source_author and source_url present

- [ ] **Step 2: Fix any violations**

If any check fails, edit the file to fix it. Re-run the check.

---

### Task 7: Run Doc-Review on All Skill Files

**Files:**
- Read: `import-skills/wayfinder/SKILL.md`
- Read: `import-skills/grill-with-docs/SKILL.md`
- Read: `import-skills/domain-modeling/SKILL.md`
- Read: `import-skills/prototype/SKILL.md`
**Verifies:** TC-12

- [ ] **Step 1: Invoke doc-review on wayfinder SKILL.md**

Review against spec:
- [ ] brief terminology applied consistently
- [ ] pluggable interfaces fully described
- [ ] review gates present in Work the Map step 4
- [ ] doc-organize + doc-review checkpoints present
- [ ] no regression in original Wayfinder logic

- [ ] **Step 2: Invoke doc-review on grill-with-docs SKILL.md**

- [ ] frontmatter conversion correct, body preserved, source attribution present

- [ ] **Step 3: Invoke doc-review on domain-modeling SKILL.md**

- [ ] frontmatter conversion correct, body preserved, reference files included

- [ ] **Step 4: Invoke doc-review on prototype SKILL.md**

- [ ] frontmatter conversion correct, body preserved

- [ ] **Step 5: Fix any issues found**

---

### Task 8: Deploy Skills

**Files:**
- Deploy to: `~/.config/opencode/skills/skill-factory/import-skills/wayfinder/`
- Deploy to: `~/.config/opencode/skills/skill-factory/import-skills/grill-with-docs/`
- Deploy to: `~/.config/opencode/skills/skill-factory/import-skills/domain-modeling/`
- Deploy to: `~/.config/opencode/skills/skill-factory/import-skills/prototype/`
- Deploy to: `~/.claude/commands/wayfinder.md`
- Deploy to: `~/.claude/commands/grill-with-docs.md`
- Deploy to: `~/.claude/commands/domain-modeling.md`
- Deploy to: `~/.claude/commands/prototype.md`
**Verifies:** TC-10

- [ ] **Step 1: Commit to git**

```bash
cd /home/cicidi/project/skill-factory
git add import-skills/
git commit -m "skill: import wayfinder + 3 dependencies from mattpocock/skills

Import wayfinder (adapted: brief terminology, pluggable interfaces,
review gates), grill-with-docs, domain-modeling, prototype.
Research not imported — ai-coworker has its own.

Co-Authored-By: Claude <noreply@anthropic.com>"
```

- [ ] **Step 2: Push to remote**

```bash
cd /home/cicidi/project/skill-factory && git push origin master
```

- [ ] **Step 3: Sync to OpenCode config**

```bash
git -C ~/.config/opencode/skills/skill-factory/ pull --ff-only origin master 2>/dev/null || \
  (mkdir -p ~/.config/opencode/skills/skill-factory/import-skills && \
   cp -r /home/cicidi/project/skill-factory/import-skills/* ~/.config/opencode/skills/skill-factory/import-skills/)
```

- [ ] **Step 4: Deploy to Claude Code commands (flat .md)**

```bash
for skill in wayfinder grill-with-docs domain-modeling prototype; do
  cp /home/cicidi/project/skill-factory/import-skills/$skill/SKILL.md ~/.claude/commands/$skill.md
done
```

- [ ] **Step 5: Deploy to OpenCode instructions (flat .md)**

```bash
for skill in wayfinder grill-with-docs domain-modeling prototype; do
  mkdir -p ~/.opencode/instructions/
  cp /home/cicidi/project/skill-factory/import-skills/$skill/SKILL.md ~/.opencode/instructions/$skill.md
done
```

- [ ] **Step 6: Verify deployment**

```bash
ls ~/.claude/commands/wayfinder.md ~/.claude/commands/grill-with-docs.md ~/.claude/commands/domain-modeling.md ~/.claude/commands/prototype.md
coworker skill list | grep -E "wayfinder|grill-with-docs|domain-modeling|prototype"
```

Expected: all 4 files exist, skills appear in skill list.

---

### Task 9: Smoke Test

**Verifies:** TC-11

- [ ] **Step 1: Test slash command availability**

In a new Claude session, type `/wayfinder` — expected: skill loads.

- [ ] **Step 2: Test chart-the-map mode**

```bash
# In a test repo with GitHub Issues
/wayfinder "Test: build a todo app"
# Expected: grills user for destination, creates map issue with label wayfinder:map
```

- [ ] **Step 3: Verify brief terminology in output**

Check Claude's narration: should refer to "brief" not "ticket".

- [ ] **Step 4: Verify research brief uses ai-coworker research**

Create a research brief — Claude should invoke ai-coworker's `/research` not Matt's.

---

## Task 5 Appendix: Adapted wayfinder SKILL.md

The adapted SKILL.md has these structural changes from the original:

### Frontmatter (new)
```yaml
---
name: wayfinder
description: |
  Use when planning work too large for one agent session. Charts a shared map
  of decision briefs on the issue tracker, resolves them one at a time until
  the route to the destination is clear.
license: MIT
compatibility: claude-code,opencode
metadata:
  triggers:
    - wayfinder
    - chart map
    - decision mapping
    - plan large work
  when_to_use: |
    When work is too big for one session and the path from here to the
    destination isn't visible. When decisions need shared, persistent tracking
    across multiple sessions.
  when_not_to_use: |
    When the work fits in one session. When requirements are already fully
    specified with tickets ready to implement. When you just need a quick
    spec — use to-spec instead.
  audience:
    - developers
    - architects
    - tech leads
  source_author: mattpocock
  source_url: https://github.com/mattpocock/skills/blob/main/skills/engineering/wayfinder/SKILL.md
---
```

### Body changes (from original)

1. **"decision tickets" → "decision briefs"** everywhere
2. **Add "Pluggable Skill Interfaces" section** after Ticket Types
3. **Add "Delivery Review Gate" in Work the Map step 4**
4. **Add "Doc-Organize: MkDocs-Ready" as inline discipline**
5. **Add "Spec Creation & Doc-Review Checkpoint" section** after Fog of War
6. **Replace `/research` reference** with ai-coworker research in interface config
7. **Remove `setup-matt-pocock-skills` reference** — use ai-coworker init/project
