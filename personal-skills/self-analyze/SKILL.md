---
name: self-analyze
description: |
  Use when analyzing correction traces to find patterns of AI mistakes.
  Use after 2+ correction traces accumulate, for periodic self-improvement
  of the AI system.
license: MIT
compatibility: opencode
metadata:
  triggers:
    - analyze correction traces
    - self analyze
    - find correction patterns
    - generate new rules from traces
---

# ai-coworker-self-analyze

Reads all correction traces and generates actionable rules or new skills
from patterns. Self-improving loop for the AI coworker.

## When to Use

- User asks to analyze correction patterns
- 5+ traces have accumulated
- Periodic self-improvement of the AI system

## When NOT to Use

- Fewer than 2 correction traces exist -- patterns need volume to be reliable
- Individual one-off corrections that don't repeat

## Process

### 1. Load Traces

- Read all files in `~/.claude/self-healing/traces/`
- Parse YAML
- Group by category
- Sort by frequency descending

### 2. Find Patterns

A pattern = same correction occurring 2+ times:
- Group traces by (category + normalized correction text)
- Flag groups with frequency >= 2
- Show: "Found pattern: '{rule}' occurred {N} times"

### 3. Generate Rules

For each pattern, generate a rule:

- **code-conventions patterns** -- add to commit-code-conventions.md
- **workflow patterns** -- add to CLAUDE.md workflow section
- **security patterns** -- add to commit-guardrails.md
- **tool-use patterns** -- add to relevant mcp skill

Rule format:
```markdown
- **Never {bad behavior}** -- {reason from traces}
```

### 4. Suggest New Skill

If pattern is complex enough to warrant its own skill:
- "Pattern '{name}' is complex. Create a new skill? (y/n)"
- If yes: invoke skill-create with the pattern as the skill body

### 5. Create PR

- Create branch: fix/self-healing-{date}
- Add generated rules to appropriate files
- Commit: "self-healing: add rules from {N} correction patterns"
- Create PR for review

### 6. Archive Traces

After processing, mark traces as processed with date and generated rule reference.

## Quality Gates

### MUST

- [ ] At least 2 traces analyzed before generating rules
- [ ] Generated rules are specific and actionable
- [ ] Rules added to correct files based on category

### NICE

- [ ] Archives processed traces
- [ ] Creates PR for rule additions

## Anti-Patterns

- Generating rules from a single occurrence
- Adding vague rules ("be more careful")
- Modifying files without creating a reviewable PR

## Test Scenarios

### Scenario 1: Two occurrences of same mistake
**Input:** 2 traces of "AI used fully qualified names instead of imports"
**Expected:** Rule generated in code-conventions file

### Scenario 2: Complex pattern
**Input:** 3 traces of AI skipping a pipeline step
**Expected:** Suggests creating a new skill for the workflow

### Scenario 3: Single occurrence
**Input:** 1 trace of a formatting issue
**Expected:** Skipped -- not enough volume for a pattern

### Scenario 4: Multiple categories
**Input:** 2 code-conventions traces + 2 workflow traces
**Expected:** Rules generated for both categories separately

## Sources

- Original coworker-meta-self-analyze skill: confidence high
