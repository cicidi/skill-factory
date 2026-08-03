# Wayfinder Import — Test Plan

> Covers 4 imported skills: wayfinder (adapted), grill-with-docs, domain-modeling, prototype.
> Written BEFORE implementation plan per testing strategy (spec §9.1).

## Test Cases

### TC-01: Frontmatter Compliance — All 5 Fields Present

**Scope:** All 4 SKILL.md files

| Check | Expected |
|---|---|
| `name` matches folder name | `import-skills/wayfinder/SKILL.md` → `name: wayfinder` |
| `description` starts with "Use when" | `grep "^description: \| Use when"` returns match |
| `description` ≤ 1024 chars | `grep -A2 "^description:" SKILL.md \| wc -c` < 1024 |
| `license: MIT` present | `grep "^license: MIT"` |
| `compatibility` includes `claude-code` and `opencode` | `grep "^compatibility:" \| grep claude-code \| grep opencode` |

- [ ] wayfinder/SKILL.md
- [ ] grill-with-docs/SKILL.md
- [ ] domain-modeling/SKILL.md
- [ ] prototype/SKILL.md

### TC-02: Convention Compliance — No Prohibited Content

**Scope:** All 4 SKILL.md files

| Check | Command |
|---|---|
| No "Changelog" section | `grep -i "^## Changelog"` returns nothing |
| No "Convention Notes" section | `grep -i "^## Convention Notes"` returns nothing |
| No TBD/TODO | `grep -i "TBD\|TODO"` returns nothing |
| No decorative emoji in body | `grep -P "[\x{1F300}-\x{1F9FF}]"` returns nothing (after frontmatter) |
| No "..." / truncated sentences | `grep "\.\.\." SKILL.md` returns nothing |

- [ ] wayfinder/SKILL.md
- [ ] grill-with-docs/SKILL.md
- [ ] domain-modeling/SKILL.md
- [ ] prototype/SKILL.md

### TC-03: Attribution — source_author + source_url

**Scope:** All 4 SKILL.md files

```
grep "source_author: mattpocock" SKILL.md    → 1 match
grep "source_url: https://github.com/mattpocock/skills" SKILL.md → 1 match
```

- [ ] wayfinder/SKILL.md
- [ ] grill-with-docs/SKILL.md
- [ ] domain-modeling/SKILL.md
- [ ] prototype/SKILL.md

### TC-04: Terminology — ticket → brief (wayfinder only)

**Scope:** `import-skills/wayfinder/SKILL.md`

| Check | Expected |
|---|---|
| "brief" count | ≥ 20 (pervasive replacement) |
| "ticket" only in approved contexts | `grep "\bticket\b"` returns ONLY lines containing "to-tickets", "Jira ticket", or "build ticket" |
| "decision brief" phrase exists | At least once, establishing the term |

- [ ] "brief" appears throughout
- [ ] "ticket" only in to-tickets/Jira/build-ticket contexts
- [ ] "decision brief" defined early

### TC-05: Terminology — No Changes to Unadapted Skills

**Scope:** grill-with-docs, domain-modeling, prototype SKILL.md files

| Check | Expected |
|---|---|
| Original body content preserved | Diff against source shows only frontmatter changes |
| No "brief" introduced | These skills don't use Wayfinder terminology |

- [ ] grill-with-docs: body unchanged from source
- [ ] domain-modeling: body unchanged from source
- [ ] prototype: body unchanged from source

### TC-06: Pluggable Interfaces Documented (wayfinder only)

**Scope:** `import-skills/wayfinder/SKILL.md`

| Check | Expected |
|---|---|
| Section "Pluggable Skill Interfaces" exists | `grep "^## Pluggable Skill Interfaces"` |
| 4 interfaces listed: interview, investigate, prototype, tracker | Each has its own subsection or table row |
| Config mechanism described | User prompts shown ("For `<interface>`, default is...") |
| research points to ai-coworker | `grep "ai-coworker.*research"` returns match |

- [ ] Section exists
- [ ] All 4 interfaces documented
- [ ] Config prompts present
- [ ] ai-coworker research referenced

### TC-07: Delivery Review Gate (wayfinder only)

**Scope:** `import-skills/wayfinder/SKILL.md`

| Check | Expected |
|---|---|
| Review gate in "Work the map" step 4 | `grep -A10 "Delivery Review"` shows logic |
| Gate triggers on task brief + deliverables | Pseudocode shows IF brief type is task |
| doc-review for .md | `grep "doc-review"` in gate context |
| code-review for code | `grep "code-review\|matt-code-review"` in gate context |
| Claude default as fallback | `grep "fallback"` in gate context |

- [ ] Gate present in Step 4
- [ ] Task brief trigger
- [ ] .md → doc-review
- [ ] code → code-review
- [ ] Fallback documented

### TC-08: Doc-Organize + Doc-Review Checkpoint (wayfinder only)

**Scope:** `import-skills/wayfinder/SKILL.md`

| Check | Expected |
|---|---|
| Doc-organize inline discipline | `grep "doc-organize"` references MkDocs-ready guarantee |
| Doc-review checkpoint after to-spec | `grep -A10 "Doc-Review"` shows checkpoint |
| Checkpoint covers all documents | Mentions spec + briefs + CONTEXT.md + ADRs |
| doc-review happens BEFORE to-tickets | Order: map done → to-spec → doc-review checkpoint → to-tickets |

- [ ] doc-organize inline discipline present
- [ ] doc-review checkpoint present
- [ ] Scope covers all documents
- [ ] Correct ordering in lifecycle

### TC-09: Domain-Modeling Reference Files Included

**Scope:** `import-skills/domain-modeling/`

```
ls import-skills/domain-modeling/
→ SKILL.md
→ CONTEXT-FORMAT.md
→ ADR-FORMAT.md
```

- [ ] 3 files in directory
- [ ] CONTEXT-FORMAT.md is non-empty markdown
- [ ] ADR-FORMAT.md is non-empty markdown

### TC-10: Deployment — All 4 Skills Deployable

**Scope:** Post-deploy verification

| Check | Command |
|---|---|
| Claude Code commands exist | `ls ~/.claude/commands/wayfinder.md ~/.claude/commands/grill-with-docs.md ~/.claude/commands/domain-modeling.md ~/.claude/commands/prototype.md` |
| OpenCode instructions exist | `ls ~/.opencode/instructions/wayfinder.md ~/.opencode/instructions/grill-with-docs.md ~/.opencode/instructions/domain-modeling.md ~/.opencode/instructions/prototype.md` |
| Skills appear in list | `coworker skill list \| grep -E "wayfinder\|grill-with-docs\|domain-modeling\|prototype"` returns 4 lines |

- [ ] Claude Code commands deployed
- [ ] OpenCode instructions deployed
- [ ] Skill list includes all 4

### TC-11: Smoke Test — Slash Command Loads

**Scope:** Runtime behavior

| Check | Expected |
|---|---|
| `/wayfinder` loads | Skill name appears in slash-command list, frontmatter parsed correctly |
| `/grill-with-docs` loads | Same |
| `/domain-modeling` loads (if model-invoked or user-invoked) | Same |
| `/prototype` loads (if model-invoked or user-invoked) | Same |

- [ ] /wayfinder loads without errors
- [ ] /grill-with-docs loads without errors
- [ ] /domain-modeling loads without errors
- [ ] /prototype loads without errors

### TC-12: Doc-Review Pass (Gate)

**Before commit**, run `doc-review` on all 4 files. All findings must be resolved.

- [ ] wayfinder/SKILL.md passes doc-review
- [ ] grill-with-docs/SKILL.md passes doc-review
- [ ] domain-modeling/SKILL.md passes doc-review
- [ ] prototype/SKILL.md passes doc-review

## Test Execution Order

```
TC-01 (frontmatter)  ──┐
TC-02 (conventions)  ──┤
TC-03 (attribution)  ──┤ Run first — static checks on all 4 files
TC-04 (terminology)  ──┤
TC-05 (body preserved)─┘

TC-06 (interfaces)   ──┐
TC-07 (review gate)  ──┤ Run second — wayfinder-specific content
TC-08 (doc-checkpoint)─┘

TC-09 (ref files)    ──  Run any time — domain-modeling only

TC-12 (doc-review)   ──  Run before commit — gate

TC-10 (deployment)   ──  Run after commit + push
TC-11 (smoke test)   ──  Run last
```

## Expected Pass Threshold

- **TC-01 through TC-09, TC-12**: MUST pass before commit
- **TC-10, TC-11**: MUST pass after deploy
- Any failure → fix, re-run that TC
