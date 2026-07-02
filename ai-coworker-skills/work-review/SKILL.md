---
name: work-review
description: |
  Use when completed work needs formal acceptance review against scope,
  design, and PRD. Use when a feature branch is ready for sign-off and
  needs verification that all acceptance criteria are met with no
  regressions. Use when user asks for work review, acceptance, or sign-off.
license: MIT
compatibility: opencode
metadata:
  triggers:
    - work review
    - acceptance review
    - sign off
    - verify work
    - check work
    - accept work
  when_to_use: |
    When a feature branch is complete and needs formal acceptance
    review. When all acceptance criteria must be verified against
    implementation before sign-off.
  when_not_to_use: |
    For pre-implementation design review (use ai-coworker-devil-advocate).
    For code-level PR review. For work without defined scope/design/PRD.
---

# ai-coworker-work-review

Gatekeeper skill for work acceptance. Agent 1 collects scope/design/PRD/plan
info and synthesizes a Work Acceptance document with acceptance criteria,
test plan, and regression guard. Agent 2 executes the test plan (running
existing tests, writing Playwright scripts, using curl/httpie) and either
signs off each criterion or produces a rejection report for external workers.

## When to Use

- Feature branch is complete and needs formal sign-off
- User provides scope/design/PRD/plan docs for acceptance review
- Need to verify implementation matches spec, with no regressions

## When NOT to Use

- Pre-implementation design review (use ai-coworker-devil-advocate)
- Code-level PR review
- No scope/design/PRD documents available
- Trivial changes not needing structured acceptance

## Process

### Phase 1: Agent 1 (Collector) — Task subagent

Collect all work context and synthesize the acceptance document.

**Input:** paths to scope, design, PRD, plan docs + base branch name.

**Collect:**
1. Read all provided documents
2. Search GitHub issues (repo, keyword-filtered by topic)
3. Read git log (commits after base branch)
4. Read test directory structure and existing test files

**Synthesize acceptance.md:**
```
{project-path}/docs/work-review/YYYY-MM-DD-<topic>/acceptance.md
```

Three sections:

**Acceptance Criteria** — derived from PRD (functional → MUST), design
(technical → MUST/SHOULD), plan (steps → SHOULD). Each with source doc +
line, priority (MUST/SHOULD/NICE).

**Test Plan** — scenarios with Type (E2E/UT/FT/Manual), Steps, Expected
Behavior. NO implementation code. Agent 1 describes WHAT to test, not HOW.

**Regression Guard** — existing features that must not break, traced to
git history or past issues. Each with corresponding test command.

### Phase 2: Agent 2 (Reviewer) — Task subagent

Execute the test plan and verify implementation.

**Input:** acceptance.md + original docs + base branch.

**Execute Test Plan:** UT/FT → run dev's test suite. E2E → write Playwright
script from Steps, start dev server, run, screenshot on fail. No tests → use
curl/httpie for APIs, scripts for behavior. Manual → walk code paths.

**Verify Implementation:** git diff coverage vs criteria, file change audit,
regression guard tests, no debug code/hardcoded secrets/console.log.

**Produce report.md:**

REJECTED (any FAIL/MISSING/BREAK): status + failed criteria table (#, criteria,
status, reason) + action items. ACCEPTED (all PASS): status + signed table
(#, criteria, status, evidence with file:line + test result).

On ACCEPTED, append `[SIGNED]` to each criterion in acceptance.md.

**Agent 2 Prompt (Task subagent):**
```
REVIEWER agent. Execute acceptance review.
1. Read acceptance.md and original docs
2. Execute each test scenario: run tests, write Playwright, use curl/httpie
3. Check git diff coverage vs criteria
4. Run regression guard tests, verify no breakage
5. Check no debug code, secrets, unexpected file changes
6. REJECTED: list FAIL/MISSING/BREAK with reason and fix target
   ACCEPTED: SIGNED each criterion with evidence (file:line, test result)
   On ACCEPTED, append [SIGNED] to acceptance.md criteria
```

**Agent 1 Prompt (Task subagent):**
```
COLLECTOR agent. Read docs, GitHub issues, git history, test directory.
Synthesize acceptance.md:
1. Acceptance Criteria from PRD/design/plan with source:line + MUST/SHOULD/NICE
2. Test Plan: scenarios with Type, Steps, Expected Behavior. NO code.
3. Regression Guard: existing features that must not break
```

## Quality Gates

### MUST (block)
- [ ] Agent 1 reads all docs, GitHub issues, git history, test directory
- [ ] acceptance.md: criteria + test plan + regression guard (all 3 sections)
- [ ] Test plan: scenarios only, no implementation code
- [ ] Agent 2 executes test plan (run existing + Playwright + curl/httpie)
- [ ] Agent 2 checks git diff, file changes, regression
- [ ] report.md always generated (ACCEPTED or REJECTED)
- [ ] ACCEPTED: SIGNED per criterion with file:line + test result evidence
- [ ] REJECTED: each failure listed with reason and fix target

### NICE (warn)
- [ ] Criteria include source doc line numbers
- [ ] Playwright failures include screenshots
- [ ] Test plan covers edge cases, not just happy path
- [ ] Regression guard items have test commands

## Anti-Patterns

| Pattern | Why wrong | Fix |
|---------|-----------|-----|
| Agent 1 writes test code | Test plan is spec, not implementation | Describe WHAT only, no Playwright/script code |
| Agent 2 skips execution | Code-reading is not testing | Every scenario must produce pass/fail from actual execution |
| Vague evidence | "Looks good" is not verification | SIGNED needs file:line + test result (count, screenshot) |
| Skipping regression | Breaks undo the work | Regression guard tests always run and must pass |

## Sources

- User requirement: 2-agent collector/reviewer gatekeeper pattern
- skill-factory/CONVENTIONS.md: structure and naming conventions
- User-confirmed: Agent 1 writes test plan (no code), Agent 2 executes
  (Playwright, existing tests, curl/httpie). Output at {project-path}/docs/work-review/.
  SIGNED per criterion on acceptance.
