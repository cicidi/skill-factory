---
name: self-heal
description: |
  Use when logging a correction trace after AI makes a mistake. Use every
  time the user corrects the AI. Feeds into self-analyze for pattern
  detection.
license: MIT
compatibility: opencode
metadata:
  triggers:
    - log correction
    - trace this mistake
    - you did that wrong
    - record this error
---

# ai-coworker-self-healing-trace

Log a correction trace when AI makes a mistake. Stores in YAML for pattern
analysis. Called every time the user corrects the AI.

## When to Use

- Every time the user corrects the AI
- User says "you did X wrong" or similar correction
- Auto-detected trigger signals: "no", "don't", "stop", "wrong", "not like that", "never do"

## When NOT to Use

- General feedback that isn't a correction of AI behavior
- Positive feedback

## Process

### 1. Capture

On correction signal detected:
- Note: what was AI doing? What did user say?
- Infer the rule: "AI should never... / AI should always..."

### 2. Write Trace

Append to `~/.claude/self-healing/traces/{date}.yaml`:

```yaml
- id: {uuid}
  timestamp: {ISO8601}
  trigger: user_correction
  context: "{what AI did}"
  correction: "{what user said}"
  category: {code-conventions|workflow|communication|security|architecture|tool-use}
  project: {project name}
  frequency: 1
```

### 3. Acknowledge

"Got it -- logged correction: '{rule}'. I'll avoid this in future."

### Categories

- `code-conventions` -- style, formatting, imports, naming
- `workflow` -- pipeline steps, commit messages, PR process
- `communication` -- message format, tone, channel choice
- `security` -- OWASP violations, secret handling
- `architecture` -- design patterns, structure decisions
- `tool-use` -- wrong tool, wrong MCP, wrong command

## Quality Gates

### MUST

- [ ] Trace written to YAML file with all required fields
- [ ] Category correctly assigned
- [ ] Rule inferred from correction

### NICE

- [ ] User receives acknowledgment
- [ ] Trace directory exists and is writable

## Anti-Patterns

- Skipping the trace when user corrects -- this defeats the self-healing loop
- Logging without inferring a specific rule
- Using wrong category that won't feed analyze correctly

## Test Scenarios

### Scenario 1: Code convention correction
**Input:** User says "don't use fully qualified class names"
**Expected:** Trace logged with category code-conventions, rule inferred

### Scenario 2: Workflow correction
**Input:** User says "you skipped the review checkpoint"
**Expected:** Trace logged with category workflow

### Scenario 3: Security correction
**Input:** User says "never commit secrets"
**Expected:** Trace logged with category security

### Scenario 4: Auto-detection
**Input:** User message contains "no, that's wrong"
**Expected:** Correction signal detected, trace captured

## Sources

- Original coworker-meta-self-healing-trace skill: confidence high
