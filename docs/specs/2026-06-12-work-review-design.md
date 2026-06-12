# ai-coworker-work-review Design

Date: 2026-06-12

## Goal

A gatekeeper skill that reviews completed work against synthesized acceptance criteria.
Agent 1 collects docs and writes a test plan (no code). Agent 2 executes the test plan
(writing code if needed, running existing tests, running Playwright) and either signs off
or produces a rejection report for external workers to fix.

## Architecture

```
User provides: scope/design/PRD/plan paths + base branch
  │
  ├── Phase 1: Agent 1 (Collector) — Task subagent
  │     1. Read all docs
  │     2. Search GitHub issues (repo, keyword-filtered)
  │     3. Read git log (commits after base branch)
  │     4. Read test directory structure
  │     5. Synthesize → acceptance.md:
  │        - Acceptance Criteria (MUST/SHOULD/NICE) with source tracing
  │        - Test Plan (E2E/UT/FT/Manual, steps/assertions, no code)
  │        - Regression Guard (existing features that must not break)
  │
  └── Phase 2: Agent 2 (Reviewer) — Task subagent
        1. Read acceptance.md and original docs
        2. Execute Test Plan:
           - Existing tests (UT/FT): run dev's test suite
           - E2E: write Playwright scripts, start dev server, run
           - No tests: curl/httpie/script verification
        3. Check: git diff coverage, file changes, regression
        4. Outcome:
           - FAIL/MISSING/BREAK → write report.md (rejection)
           - ALL PASS → write report.md (signed), mark acceptance.md [SIGNED]
```

## Acceptance Criteria Synthesis

Agent 1 derives criteria from each source:

| Source | Derivation |
|--------|-----------|
| PRD | Functional requirements → MUST criteria |
| Design doc | Technical constraints, architecture → MUST/SHOULD criteria |
| Plan | Implementation steps → SHOULD criteria |
| GitHub issues | Related bugs/features → regression guard criteria |
| Git history | Recent changes in affected areas → regression guard |
| Test directory | Existing test coverage → baseline for test plan |

Each criterion includes: ID, description, source (doc + line), priority (MUST/SHOULD/NICE).

## Test Plan Structure

Agent 1 writes test scenarios without implementation code:

```markdown
## Test Plan

| # | Scenario | Type | Source | Steps / Expected Behavior |
|---|----------|------|--------|---------------------------|
| 1 | User login flow | E2E | PRD L5 | Open /login, enter credentials, verify redirect to /dashboard |
| 2 | API /users returns 200 | UT | Design L30 | Run `npm test -- users` |
| 3 | Empty form submission | FT | Plan L12 | POST /submit with empty body, expect 400 |
```

Types: E2E (Playwright), UT (unit test), FT (functional/integration test), Manual.

## Agent 2 Execution Logic

For each test scenario in the plan:

1. **UT/FT — existing tests**: Run the project's test command. Record pass/fail.
2. **E2E — no existing automation**: Write a Playwright script based on Steps/Expected Behavior, start dev server, execute, record pass/fail with screenshots on failure.
3. **No test coverage**: Use curl/httpie for API scenarios, or write minimal scripts. Record pass/fail.
4. **Manual scenarios**: Walk through steps by reading code paths, verify implementation exists.

Additionally:
- Inspect `git diff` for coverage of each acceptance criterion
- Check file change list for unexpected modifications
- Verify regression guard items by running relevant existing tests

## Output

Path: `{project-path}/docs/work-review/YYYY-MM-DD-<topic>/`

Files:
- `acceptance.md` — Agent 1 output: criteria + test plan + regression guard
- `report.md` — Agent 2 output: review conclusion

### Rejection report

```markdown
# Work Review: <topic>
## Status: REJECTED
## Failed
| # | Criteria | Status | Reason |
|---|----------|--------|--------|
| 3 | Login redirect | MISSING | No implementation found for redirect after login |
## Action Required
- Fix #3 in auth module, re-run work-review
```

### Acceptance report

```markdown
# Work Review: <topic>
## Status: ACCEPTED
## Signed
| # | Criteria | Status | Evidence |
|---|----------|--------|----------|
| 1 | Login flow | SIGNED | src/auth.ts:42, Playwright test passed |
```

Acceptance.md is appended with `[SIGNED]` next to each passed criterion.

## Skill Structure

File: `ai-coworker-skills/work-review/SKILL.md`

Frontmatter:
```yaml
---
name: ai-coworker-work-review
description: |
  Use when completed work needs acceptance review against scope,
  design, and PRD. Use when a feature branch is ready for sign-off
  and needs verification that all acceptance criteria are met with
  no regressions.
license: MIT
compatibility: opencode
metadata:
  triggers:
    - work review
    - acceptance review
    - sign off
    - verify work
    - check work
  when_to_use: |
    When a feature branch is complete and needs formal acceptance
    review. When all acceptance criteria must be verified against
    implementation before sign-off.
  when_not_to_use: |
    For pre-implementation design review (use devil-advocate).
    For code-level review of PRs. For work without defined
    scope/design/PRD documents.
---
```

## Quality Gates

### MUST
- [ ] Frontmatter 5 fields complete, name matches folder
- [ ] Agent 1 collects all specified document types
- [ ] Agent 1 produces acceptance.md with all 3 sections (criteria, test plan, regression guard)
- [ ] Test plan has no implementation code (scenarios only)
- [ ] Agent 2 executes test plan (existing + Playwright + scripts)
- [ ] Agent 2 checks git diff + file changes + regression
- [ ] report.md always generated (ACCEPTED or REJECTED)
- [ ] ACCEPTED report has SIGNED per criterion with evidence
- [ ] No TBD/TODO, no concrete-context leaks, no prohibited sections

### NICE
- [ ] Body < 150 lines
- [ ] Playwright scripts include screenshot on failure
- [ ] Each criterion cites source doc line number
- [ ] Regression guard items traced to git history or issues
