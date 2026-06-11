---
name: skill-create
description: |
  Use when creating a new skill for the skill-factory project. Use when a
  reusable workflow needs to be captured as a self-contained SKILL.md with
  quality gates and reuse audit.
license: MIT
compatibility: opencode
metadata:
  triggers:
    - create a new skill
    - new skill
    - add skill
    - build a skill
    - design a skill
  when_to_use: |
    When the user wants to create a new skill file for any AI agent harness
    supported by the skill-factory project.
  when_not_to_use: |
    For editing an existing skill, use skill-edit (when available) or edit
    the file directly. For one-off workflows that won't be reused, write
    inline instead of creating a skill.
  phase_count: 4
  requires:
    - obra/superpowers:writing-skills
    - obra/superpowers:brainstorming
  audience:
    - skill-authors
---

# skill-create

Creates a new skill file following the 4-phase skill-factory pipeline:
search for prior art, interview for requirements, build the SKILL.md,
verify with quality gates, publish with git. All references to other
skills are optional — the core process runs standalone.

## When to Use

- You want to create a new skill for any AI agent harness
- You have a reusable workflow that needs to be captured as a skill
- You want the reuse audit (check if a similar skill already exists)
- You want structured quality gates before publishing

## When NOT to Use

- You want to edit an existing skill — use skill-edit (when available) for safe modifications
- It's a one-off solution that won't be reused — write inline
- The "skill" is < 10 lines of instructions — just paste it, don't create a file
- The workflow is already well-documented elsewhere — link, don't copy

## Skill Dependencies

> **Optional enhancements:** If `obra/superpowers:writing-skills` is available,
> its CSO (Claude Search Optimization) and anti-rationalization patterns can
> enhance Phase 2 and Phase 3. If `obra/superpowers:brainstorming` is available,
> it improves interview rhythm in Phase 1. Both are optional — the 4-phase
> process works without them.

## Process

### Phase 0: Search & Reuse Audit

**MUST:**
1. List existing skills: `ls ai-coworker-skills/` in the target project
2. Read each SKILL.md frontmatter (`name`, `description`, `metadata.triggers`)
3. If user-provided query matches any existing skill's triggers or description ≥70%:
   - **STOP** — tell user: "Found existing skill `X` at path Y. Edit it instead? Use skill-edit (if available) or edit the file directly following CONVENTIONS.md."
4. If no match, continue to Phase 1

**NICE:**
- Webfetch GitHub to find similar skills (optional, may be slow)
- Note promising patterns for Phase 2's Sources section

### Phase 1: Interview

**MUST:**
1. Ask **one question at a time** — don't overwhelm with lists
2. Capture:
   - Intent: what should this skill enable the AI to do?
   - Trigger: what phrases should activate it?
   - Success criteria: what does "good enough" look like?
   - Target audience: who will use this skill?
3. Ask about **failure modes**: what happens when the skill can't solve the problem?
4. Ask about **factor weights** (must sum to 1.0):
   - Accuracy of output
   - Speed to completion
   - Edge case coverage
   - Readability for audience
   - Tool integration depth
5. Default factor weights if user says "skip": Accuracy 0.4, Speed 0.2, Edge cases 0.2, Readability 0.1, Tool Integration 0.1

> **Optional obra enhancement:** Use `obra/superpowers:brainstorming` for interview
> rhythm. Its "one question at a time" and "multiple choice preferred" principles
> align with this phase.

**Sources (for Phase 2):**
- Phase 0 (Search): confidence high if local scan complete
- Phase 1 (Interview): confidence medium — based on user-stated needs

### Phase 2: Build

**MUST:**
1. **Naming:** Choose a name in `kebab-case` format, matching project conventions:
   - Format: `{verb}-{object}` or `{domain}-{action}`
   - Drop filler words (the, a, for, when, with, in, on, of)
   - Max 4-5 words
2. **Folder:** Create `ai-coworker-skills/<name>/` directory
3. **Frontmatter:** Write 5-field opencode format:
   ```yaml
   ---
   name: <skill-name>
   description: |
     Use when ...
   license: MIT
   compatibility: opencode
   metadata:
     triggers:
       - <trigger phrase>
     when_to_use: |
       <description>
     when_not_to_use: |
       <description>
   ---
   ```
4. **Description rules (per CSO):**
   - Start with "Use when..." (third person)
   - Describe triggering conditions, NOT the solution
   - No workflow summary in description
   - ≤500 chars ideal, ≤1024 max
   - No first person ("I can help you..." ❌)
5. **Body sections:**
   - `# <name>` + overview (1-2 sentences)
   - `## When to Use` (bullets with symptoms)
   - `## When NOT to Use` (anti-triggers)
   - `## Process` (numbering steps or phases)
   - Include fallback for each phase: what to do if it fails
6. **Sources:** Add a `## Sources` section at end, listing confidence per segment

> **Optional obra enhancements:**
> - Run CSO check on description: third person, "Use when...", no workflow summary
> - For discipline skills (rules/requirements), add anti-rationalization section
> - Use `obra/superpowers:writing-skills` for both of the above

**NICE:**
- If the skill is for a discipline (rules enforcement), add a "Common Rationalizations" table
- Include one excellent example (not multi-language)

### Phase 3: Verify

**MUST:**
1. Run the Quality Gates checklist (see `## Quality Gates` section below) — every MUST item must pass
2. Self-review:
   - Placeholder scan: any TBD, TODO, incomplete sections?
   - Internal consistency: do sections agree with each other?
   - Scope check: is this focused enough for a single skill?
   - Ambiguity check: could any requirement be interpreted two ways?
3. Present the complete skill to the user
4. Wait for user approval — do NOT proceed to Phase 4 without it
5. If user requests changes, iterate

**NICE:**
- Run the test scenarios (see `## Test Scenarios` section below)
- For discipline skills, run TDD-for-skills (per obra): RED baseline, GREEN write, REFACTOR close loopholes

> **Optional obra enhancements:**
> - Use `obra/superpowers:verification-before-completion` for systematic verify
> - Use `obra/superpowers:requesting-code-review` for structured review feedback
> - Use `obra/superpowers:test-driven-development` for discipline skills

### Phase 4: Publish

**MUST:**
1. Confirm only the new skill is changed: `git status`
2. Stage only the new skill: `git add ai-coworker-skills/<name>/`
3. Commit with conventional message: `skill: add <name> — <one-line description>`
4. Tell user: "Created at `ai-coworker-skills/<name>/SKILL.md`, committed as `<hash>`. Push? (y/n)"

**NICE:**
- If user says yes, run `git push`
- If user wants a PR, use `gh pr create` (if gh CLI is configured)

**Sources:**
- Phase 4 (Publish): confidence high — commit hash is ground truth

## Quality Gates

Before publishing, run these checks in order. **MUST** items block publish.
**NICE** items warn but don't block.

### MUST (block publish on failure)

- [ ] Frontmatter 5 fields complete: `name`, `description`, `license`, `compatibility`, `metadata`
- [ ] `name` matches folder name `ai-coworker-skills/<name>/`
- [ ] `description` ≤ 1024 characters
- [ ] `description` not in first person ("I can..." ❌)
- [ ] `description` does not summarize workflow
- [ ] No references to non-existent `scripts/` or `schemas/` directories
- [ ] No references to non-existent skills
- [ ] No `## Changelog` section (use git log)
- [ ] No `## Convention Notes` section (use project CONVENTIONS.md)
- [ ] No concrete-context leaks: real org names, Slack domains, GitHub orgs, colleague handles
- [ ] No invalid dates (e.g., "2024-04-32")
- [ ] No decorative emoji in body text (checkmarks, fire, rocket, etc.)
- [ ] No OCR artifacts (`**>text<**` style markers)
- [ ] No truncated sentences ending in "..."
- [ ] No TBD, TODO, or "to be determined" placeholders

### NICE (warn but don't block)

- [ ] `description` starts with "Use when..."
- [ ] Body < 500 lines
- [ ] Optional skill references marked as "optional enhancement"
- [ ] `## Sources` section present with confidence levels (high/med/low)
- [ ] At least 4 test scenarios
- [ ] Markdown table column names are clear
- [ ] Code examples are complete and runnable

## Anti-Patterns

Things that look productive but are wrong. Block publish and fix.

### 1. Concrete-context leak

**Symptom:** Examples cite real org names, internal Slack/GitHub URLs, GHA quota,
colleague handles.

**Why wrong:** Skills travel across teams and projects. Concrete content leaks to
public repos, confuses future readers into thinking the skill is scoped to one team.

**Detection:** Scan body for `*.slack.com`, `*.enterprise.slack.com`, real-looking
GitHub orgs, `@` usernames ≥12 chars, real ticket IDs.

**Fix:** Replace with neutral placeholders like `{source-system}`, `{team.slack.com / example.com}`.

### 2. One-off notes masquerading as skills

**Symptom:** description or body only makes sense for the one task that motivated creation.

**Why wrong:** A skill must be reusable across tasks. One-off notes belong in vault,
not in a skill library.

**Fix:** Either generalize to a class of tasks, or abandon (don't create a skill file).

### 3. Decorative emoji in body

**Symptom:** Checkmarks, fire, rocket emojis used for status emphasis.

**Why wrong:** Adds noise for text-only readers, encoding fragility, doesn't copy-paste well.

**Fix:** Use plain labels: `pass`, `fail`, `done`, `block`, `warn`.

### 4. Verbatim user prompt in test scenarios or examples

**Symptom:** Example section pastes the exact user prompt with file paths, project
names, ticket IDs.

**Why wrong:** Examples are highly visible and travel. Specifics leak.

**Fix:** Rewrite examples with neutral placeholders. Keep structural shape; replace specifics.

## Test Scenarios

Walk through each scenario manually when verifying a new skill.

### Scenario 1: Simple git helper skill
**Input:** "create a skill that helps me write good git commit messages"
**Expected:** Phase 0 finds no match — Phase 1 captures developer focus — Phase 2
produces `ai-coworker-skills/git-commit-helper/SKILL.md` < 100 lines — Phase 3 all MUST gates
pass — Phase 4 committed.

### Scenario 2: API caller skill
**Input:** "I need a skill to query the GitHub API for issue lists"
**Expected:** Phase 1 captures high tool integration weight (0.4) — Phase 2 includes
actual `gh` CLI commands — Phase 3 includes live test of commands.

### Scenario 3: PDF processor skill
**Input:** "skill for extracting text from PDF files"
**Expected:** Phase 1 captures high edge case weight (0.4) — Phase 2 references
`pypdf` — Phase 3 MUST pass.

### Scenario 4: Conflicting skill (reuse audit test)
**Input:** "I want a new git helper, similar to my existing one"
**Expected:** Phase 0 finds ≥70% match — **STOPS** with message about existing skill
and suggestion to use skill-edit instead.

## Sources

- Phase 0 (Search) design: confidence high — modeled on v1's reuse audit, adapted for flat skill structure
- Phase 1 (Interview) design: confidence high — based on v1's factor weight analysis + obra's brainstorming pattern
- Phase 2 (Build) design: confidence high — opencode 5-field frontmatter per official docs; CSO from obra's writing-skills
- Phase 3 (Verify) design: confidence high — skill-forge's MUST/NICE gates + obra's verification patterns
- Phase 4 (Publish) design: confidence high — conventional commits
- Anti-patterns: confidence high — cleaned from v1, self-violations removed
- Test scenarios: confidence medium — adequacy depends on usage data
