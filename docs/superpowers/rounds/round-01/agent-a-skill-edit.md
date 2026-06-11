# Agent-A: skill-edit Session Log

## Phase 0: Search and Reuse Audit
- Listed `ai-coworker-skills/`: only `skill-create/` exists
- Read skill-create frontmatter: name=skill-create, triggers don't match skill-edit (≥70% threshold)
- Result: Proceed to Phase 1

## Phase 1: Interview (simulated Q&A)

| # | Question | User Answer |
|---|----------|-------------|
| 1 | Intent: what should this skill enable the AI to do? | Safely edit existing skill files with full process enforcement |
| 2 | Triggers: what phrases activate it? | "edit a skill", "fix skill", "update skill", "modify skill", "change skill" |
| 3 | Target audience: who uses this? | Skill authors and maintainers |
| 4 | Success criteria: what does "good enough" look like? | Edit is correct, quality gates pass, no new files created |
| 5 | Failure modes: what if it can't solve the problem? | Non-existent skill → skill-create; complete rewrite → skill-create |
| 6 | Factor weights: accept defaults? | Yes: Accuracy 0.4, Edge cases 0.3, Readability 0.15, Speed 0.1, Tool integration 0.05 |

## Phase 2: Build
- Name: skill-edit (kebab-case, verb-object)
- Structure: 5-field opencode frontmatter + body per CONVENTIONS.md
- Process: 7-step pipeline (Audit → Load → Interview → Plan → Apply → Verify → Publish)
- Quality Gates: MUST (8 items) + NICE (3 items)
- Anti-Patterns: 5 patterns

## Phase 3: Verify
- All MUST quality gates pass
- Internal consistency: sections reference each other correctly
- Scope: focused on editing existing skills only
- No TBD/TODO, no concrete leaks, no emoji

## Output
- SKILL.md written to ai-coworker-skills/skill-edit/SKILL.md
