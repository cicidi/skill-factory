---
name: ai-coworker-doc-merge
description: |
  Use when merging two versions of a markdown document after upstream sync
  conflicts. Use when reconciling doc versions or resolving merge conflicts
  in documentation.
license: MIT
compatibility: opencode
metadata:
  triggers:
    - merge docs
    - merge markdown conflict
    - reconcile doc versions
    - resolve doc merge conflict
---

# ai-coworker-doc-merge

Merge two versions of a markdown document, preserving PROTECTED blocks and
resolving conflicts intelligently.

## When to Use

- Merge conflicts in markdown documentation
- Reconciling two doc versions after upstream sync
- Need to preserve protected content during merge

## When NOT to Use

- Code merge conflicts -- use git merge tools instead
- Binary file conflicts

## Process

### 1. Identify Files

- Ask: "Which two files/versions to merge?"
- Read both versions
- Identify conflict markers (<<<<<<, =======, >>>>>>>)

### 2. Merge Strategy

- PROTECTED blocks -- always keep unchanged
- Headings -- preserve structure from the newer version
- New content -- add content that appears in one version but not the other
- Conflicting content -- show both options and ask user to choose
- Formatting -- normalize to consistent markdown style

### 3. Validate Result

- All headings have proper hierarchy (no skipped levels)
- All links are valid
- No duplicate sections
- PROTECTED blocks are intact

### 4. Output

- Write merged result to target file
- Show diff summary: "Added X sections, resolved Y conflicts, kept Z PROTECTED blocks"
- Do NOT auto-commit -- let user review first

## Quality Gates

### MUST

- [ ] All PROTECTED blocks remain unmodified
- [ ] No data loss -- all unique content from both versions is accounted for
- [ ] User reviews merged output before commit

### NICE

- [ ] Diff summary provided to user
- [ ] Heading hierarchy is valid

## Anti-Patterns

- Auto-committing without user review
- Losing content from either version without asking
- Modifying PROTECTED blocks during merge
- Using this for code merge conflicts

## Test Scenarios

### Scenario 1: Simple heading conflict
**Input:** Two versions with different headings added
**Expected:** Both headings present, no duplicates

### Scenario 2: Protected block conflict
**Input:** Both versions have the same protected block
**Expected:** Protected block preserved exactly, only non-protected content merged

### Scenario 3: New content in one version
**Input:** Version B has a new section not in A
**Expected:** New section included in merge

### Scenario 4: Conflicting edits to same section
**Input:** Same paragraph edited differently in both versions
**Expected:** Both versions shown, user asked to choose

## Sources

- Original coworker-meta-merge-docs skill: confidence high
