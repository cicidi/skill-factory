---
name: ai-coworker-doc-protect
description: |
  Use when the user wants to protect a section of a document from AI edits.
  Use when user says "never change this" or "lock this section".
license: MIT
compatibility: opencode
metadata:
  triggers:
    - protect this section
    - add protected block
    - lock this content
    - never edit this block
---

# ai-coworker-doc-protect

Manage PROTECTED blocks in documents. AI must never modify content inside
blocks marked with PROTECTED and END PROTECTED tags.

## When to Use

- User wants to protect a section of a document from AI edits
- User says "never change this" or "lock this section"
- Adding protection markers to critical content

## When NOT to Use

- Content that should be freely editable by AI
- Temporary notes that don't need long-term protection

## Process

### Adding Protection

1. Ask: "Which section should be protected?"
2. Add `<!-- PROTECTED -->` before and `<!-- END PROTECTED -->` after
3. Commit with message: "docs: protect {section name}"

### Removing Protection

Only the human can remove protection:
1. User explicitly says "unprotect this section"
2. Remove the markers
3. Commit with message: "docs: unprotect {section name}"

### PROTECTED Block Format

```html
<!-- PROTECTED -->
Content that AI must never modify, move, remove, or reformat.
<!-- END PROTECTED -->
```

## Rules

- AI MUST NOT modify, move, remove, or reformat content between markers
- AI CAN read protected content for context
- AI CAN suggest adding protection to critical sections
- AI CAN add new content outside protected blocks

## Quality Gates

### MUST

- [ ] Protected blocks remain unmodified after any file edit
- [ ] Protection markers are properly paired (open and close)

### NICE

- [ ] Good candidates identified: PRD requirements, architecture decisions, legal language, security policies

## Anti-Patterns

- Removing protection markers without explicit user instruction
- Modifying content within protected blocks even for formatting
- Adding protection to content the user didn't request

## Test Scenarios

### Scenario 1: Basic protection
**Input:** "Protect the architecture decisions section"
**Expected:** Markers added around the section, no content modified

### Scenario 2: Edit with protected block
**Input:** Edit a file that has a protected block
**Expected:** Only content outside protected blocks is modified

### Scenario 3: Remove protection
**Input:** "Unprotect the architecture decisions section"
**Expected:** Markers removed, content unchanged

### Scenario 4: Suggest protection
**Input:** User adds critical business rules to a doc
**Expected:** AI suggests protecting the new section

## Sources

- Original coworker-meta-doc-protection skill: confidence high
