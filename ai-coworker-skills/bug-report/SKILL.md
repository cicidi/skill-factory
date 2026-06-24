---
name: bug-report
description: |
  Use when reporting a bug or problem with the AI coworker system itself
  to GitHub Issues. Use when the AI misbehaves, produces wrong output, or
  a skill fails consistently.
license: MIT
compatibility: opencode
metadata:
  triggers:
    - report coworker bug
    - something is wrong with the ai
    - file a coworker issue
---

# ai-coworker-issue-report

Report a bug or problem with the AI coworker system itself to GitHub Issues.

## When to Use

- User says "report this bug"
- AI produces consistently wrong output
- A skill consistently fails or behaves unexpectedly
- Coworker system misbehavior

## When NOT to Use

- Project-specific bugs -- use the project's issue tracker instead
- One-off AI mistakes -- use self-healing-trace instead

## Process

### 1. Describe the Problem

- What did AI do that was wrong?
- What was the expected behavior?
- Which skill or rule caused the issue?

### 2. Draft GitHub Issue

```
Title: [coworker] {short description}

## What happened
{description of incorrect AI behavior}

## Expected behavior
{what should have happened}

## Affected skill/rule
{skill name or CLAUDE.md section}

## Reproduction steps
1. ...
2. ...

## Suggested fix
{optional}
```

### 3. Create Issue via GitHub

- Repo: cicidi/ai-coworker
- Label: coworker-bug or coworker-improvement
- Assign to: project maintainer

### 4. Log Self-Healing Trace

If this was an AI mistake, run self-healing-trace to log the correction.

## Quality Gates

### MUST

- [ ] Issue includes reproduction steps
- [ ] Affected skill/component identified
- [ ] Appropriate label applied

### NICE

- [ ] Suggested fix included
- [ ] Self-healing trace logged if applicable

## Anti-Patterns

- Filing an issue without reproduction steps
- Using this for project-level bugs instead of coworker system bugs
- Not linking the issue to the affected skill

## Test Scenarios

### Scenario 1: Skill consistently fails
**Input:** "The code review skill keeps skipping the diff step"
**Expected:** Issue created with skill name, reproduction steps, and coworker-bug label

### Scenario 2: AI produces wrong output
**Input:** "The AI generated a wrong import path three times in a row"
**Expected:** Issue created, self-healing trace logged

### Scenario 3: Project bug misdirected
**Input:** User reports a bug in their application code
**Expected:** Redirected to project's issue tracker, not coworker system

### Scenario 4: Improvement suggestion
**Input:** "The setup script should detect more IDEs"
**Expected:** Issue created with coworker-improvement label

## Sources

- Original coworker-meta-report-issue skill: confidence high
