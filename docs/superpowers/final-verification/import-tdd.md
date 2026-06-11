# TDD Skill Import

**Source:** mattpocock/skills/skills/engineering/tdd/SKILL.md
**URL:** https://github.com/mattpocock/skills/blob/main/skills/engineering/tdd/SKILL.md
**Date:** 2026-06-10

## Conversion Changes

| Original | Converted | Reason |
|----------|-----------|--------|
| frontmatter: name, description only | 5-field opencode (name, description, license, compatibility, metadata) | skill-factory format requirement |
| license: missing | MIT | default per skill-import rules |
| compatibility: missing | opencode, claude-code | default per skill-import rules |
| triggers: none | inferred 6 triggers | from description and body |
| Body: Philosophy section | merged into `# tdd` overview heading | CONVENTIONS.md body structure |
| Body: Anti-Pattern: Horizontal Slices | `## Anti-Patterns` section | CONVENTIONS.md optional section |
| Body: Workflow (4 subsections) | `## Process` with 4 phases | CONVENTIONS.md required section |
| Body: Checklist Per Cycle | `## Quality Gates` with MUST/NICE | CONVENTIONS.md optional section |
| Companion file references (tests.md, mocking.md, etc.) | Removed | Files don't exist in skill-factory |
| When to Use / When NOT to Use | Added | CONVENTIONS.md required sections |
| Sources | Added with confidence levels | CONVENTIONS.md optional section |

## Quality Gate Result
- MUST violations: 0
- NICE warnings: 0
- Result: PASS
