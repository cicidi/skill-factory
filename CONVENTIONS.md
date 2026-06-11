# skill-factory Conventions

Project-wide rules for every skill in this repository.

## File Structure

```
ai-coworker-skills/<skill-folder>/SKILL.md      # Factory-native skills (required)
personal-skills/<skill-folder>/SKILL.md          # Personal custom skills (required)
import-skills/<skill-folder>/SKILL.md            # Externally imported skills (required)
```

Three directories serve different purposes:

| Directory | Purpose | Naming |
|-----------|---------|--------|
| `ai-coworker-skills/` | Factory-native skills | `name` MUST use `ai-coworker-` prefix |
| `personal-skills/` | User's personal skills | `name` MUST use `ai-coworker-` prefix |
| `import-skills/` | Externally imported skills | `name` MUST NOT use prefix (preserve original) |

- **SKILL.md** must be uppercase (opencode requirement)
- Each skill lives in its own folder under the appropriate directory
- One skill per folder
- Single version per skill (no `deploy/` concept)

## Frontmatter

Use opencode's 5 recognized fields:

```yaml
---
name: skill-name        # lowercase, kebab-case, ai-coworker- prefix for ai-coworker-skills/ and personal-skills/
description: |          # third person, "Use when...", ≤1024 chars, no workflow summary
  Use when ...
license: MIT            # SPDX identifier
compatibility: opencode # harness name(s), comma-separated
metadata:               # arbitrary string-to-string map for extensions
  key: value
---
```

### Description rules (per obra CSO)

- Start with "Use when..." to focus on triggering conditions
- Describe the problem, not the solution
- Do NOT summarize the skill's workflow in the description
- Third person only (not "I can help you...")
- ≤500 chars ideal, ≤1024 max

## Body Structure

| Section | Required? | Notes |
|---------|-----------|-------|
| `# <skill-name>` + overview | Required | 1-2 sentence core principle |
| `## When to Use` | Required | Bullets with symptoms |
| `## When NOT to Use` | Required | Anti-triggers |
| `## Skill Dependencies` | Optional | If the skill calls other skills |
| `## Process` | Required | Steps, decision points, fallbacks |
| `## Quality Gates` | Optional | MUST/NICE checklist |
| `## Anti-Patterns` | Optional | What to avoid |
| `## Test Scenarios` | Optional | Manual verification bullets |
| `## Sources` | Optional | Provenance per segment (confidence high/med/low) |

## Prohibited

- ❌ No `## Changelog` section in SKILL.md (use git log)
- ❌ No `## Convention Notes` section (use this file)
- ❌ No `scripts/` directory reference unless the script exists
- ❌ No `schemas/` directory reference unless the schema exists
- ❌ No `deploy/` concept (single version per skill)
- ❌ No concrete-context leaks (real org names, internal URLs, colleague handles)
- ❌ No decorative emoji (✅ ❌ 🚀 🔥) in body text
- ❌ No TBD/TODO placeholders
- ❌ No truncated sentences
- ❌ No OCR artifacts (`**>text<**` style markers)

## Skill Naming

- Format: `ai-coworker-{verb}-{object}` or `ai-coworker-{domain}-{action}` (for ai-coworker-skills/ and personal-skills/)
- Format: `{verb}-{object}` or `{domain}-{action}` (for import-skills/)
- Lowercase, kebab-case
- Examples: `ai-coworker-skill-create`, `ai-coworker-skill-edit`, `skill-import`, `tdd`
- Max 4-5 words (excluding prefix)

## Quality Gate Policy

Each skill's quality gates are self-contained in its own SKILL.md.

- **MUST gates** (in `## Quality Gates`): block commit until all pass
- **NICE gates** (in `## Quality Gates`): warn but don't block
