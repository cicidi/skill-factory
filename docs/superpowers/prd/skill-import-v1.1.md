# PRD: skill-import enhancements

**Version:** 1.1
**Date:** 2026-06-10

## Background

The initial `skill-import` skill was created in Round 01 of the skill-factory
bootstrap. It successfully imports external SKILL.md files and converts them
to opencode 5-field format, but lacks two important capabilities:

1. **No author preservation** — The original author and source URL are lost
   during conversion, breaking attribution.
2. **Flat import target** — All imported skills go directly under
   `ai-coworker-skills/`, mixing imported skills with factory-native skills
   (skill-create, skill-edit, skill-import).

## Requirements

### R1: Preserve original authorship

During import, `skill-import` must record:
- `metadata.source_author` — The original author or GitHub organization
- `metadata.source_url` — The original repository or file URL

These fields must be present before the import commit is created. Missing
authorship is a MUST-gate block.

### R2: Import skills into `import/` subdirectory

Imported skills must be written to `ai-coworker-skills/import/<name>/`
instead of `ai-coworker-skills/<name>/`. This separates:

| Directory | Purpose |
|-----------|---------|
| `ai-coworker-skills/` | Factory-native skills (skill-create, skill-edit, skill-import) |
| `ai-coworker-skills/import/` | Externally-imported skills (tdd, etc.) |

## Changes Applied

| # | File | Change |
|---|------|--------|
| 1 | skill-import/SKILL.md description | Added "import/ directory" and "preserving original authorship" |
| 2 | skill-import/SKILL.md when_to_use | Updated path reference |
| 3 | skill-import/SKILL.md when_not_to_use | Added `import/` to existence check |
| 4 | skill-import/SKILL.md ## When NOT to Use | Added `import/` to existence check |
| 5 | skill-import/SKILL.md Phase 0 | Scan both `ai-coworker-skills/` and `ai-coworker-skills/import/` |
| 6 | skill-import/SKILL.md Frontmatter Mapping | Added `source_author` and `source_url` rows |
| 7 | skill-import/SKILL.md Phase 3 | Changed target path to `ai-coworker-skills/import/<name>/` |
| 8 | skill-import/SKILL.md Quality Gates MUST | Added source_author and source_url checks |
| 9 | skill-import/SKILL.md Anti-Patterns | Added "Losing original authorship" (pattern 5) |

## Side Effect

The previously imported `tdd` skill was moved from `ai-coworker-skills/tdd/`
to `ai-coworker-skills/import/tdd/` and `metadata.source_author` and
`metadata.source_url` were added retroactively.
