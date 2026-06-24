---
name: self-analyze
description: Scan project's .self-healing/traces/, find patterns, inject summary into CLAUDE.md
license: MIT
compatibility: claude-code,opencode
metadata:
  triggers:
    - self-analyze
    - analyze traces
    - self-improve
  when_to_use: When you need to scan correction traces for patterns and inject rules into CLAUDE.md.
  audience: ai-coworker
---

# Self-Analyze

Read project correction traces, find patterns, generate rules.

## When to Use

- After accumulating several correction traces in `.self-healing/traces/`
- When the AI keeps making the same mistake across sessions
- Periodically as part of the self-healing workflow

## When NOT to Use

- When no traces exist yet — nothing to analyze
- For one-off corrections that haven't repeated

## Process

### 1. Load Traces

```
→ Read all .self-healing/traces/*.yaml
→ Parse correction entries
→ Group by category
→ Count frequency per normalized correction
```

### 2. Find Patterns

A pattern = same correction occurring 2+ times:

| Category | Correction | Count |
|----------|-----------|-------|
| code-conventions | never use git add . | 3 |
| workflow | always confirm before deleting | 2 |

### 3. Generate Summary

```markdown
<!-- SELF-ANALYZE START -->
## Self-Healing Insights ({date})

**Analyzed:** {N} traces over {M} days

### Patterns Found

- **{correction}** ({count}×) — {context}

### Rules Added
- {rule} → {file}

<!-- SELF-ANALYZE END -->
```

### 4. Inject into CLAUDE.md

```
→ Read project CLAUDE.md
→ If SELF-ANALYZE block exists → replace
→ If not → append at end
→ Write CLAUDE.md
```

### 5. Report

```
Self-analyze complete:
  {N} traces analyzed
  {M} patterns found
  {K} rules injected into CLAUDE.md
  Summary in <!-- SELF-ANALYZE --> block
```
