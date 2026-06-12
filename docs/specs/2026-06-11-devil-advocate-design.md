# ai-coworker-devil-advocate Design

Date: 2026-06-11

## Goal

Create a skill that stress-tests specs, design docs, and proposals through structured adversarial debate. Three AI agents (con, pro, judge) engage in multi-round debate, with a majority-vote fallback when consensus cannot be reached.

## Use Case

Primary: review spec/design docs to discover hidden assumptions, missing edge cases, and risks before implementation.

Trigger: user provides a spec, design doc, or proposal file. Pro stance defaults to "this document is reasonable" — no manual stance specification needed.

## Output

Terminal: round-by-round summary + final conclusion + key risk highlights.

Files:
```
{project-path}/docs/devil-advocate/YYYY-MM-DD-<topic>/
├── discussion.md    # Full debate record: per-round arguments, judge rulings, unresolved items
└── report.md        # Final summary: consensus items, key risks, actionable findings (human-readable)
```

## Architecture

Main-agent orchestrated pattern (follows skill-factory bootstrap Agent-A/B/C model). The driving agent maintains round state, unresolved issues, and termination conditions.

```
User provides spec/doc
  │
  ├── Phase 1: Prepare
  │     - Read document
  │     - Create output directory
  │     - Initialize discussion.md with metadata
  │
  ├── Phase 2: Debate (max 5 rounds)
  │     ┌── Per-round:
  │     ├── Con agent (Task subagent)
  │     │     Input: original doc + previous round unresolved items
  │     │     Output: structured arguments against the doc
  │     ├── Pro agent (Task subagent)
  │     │     Input: original doc + con arguments
  │     │     Output: counter-arguments + defense of the doc
  │     ├── Judge agent (Task subagent)
  │     │     Input: both sides' arguments
  │     │     Output: consensus items + rulings + unresolved items
  │     └── Unresolved > 0 and round < 5 → next round
  │
  ├── Phase 3: Vote (only if unresolved after 5 rounds)
  │     - 3 agents vote per unresolved item
  │     - Majority decides; tie → marked "unresolved"
  │
  └── Phase 4: Output
        - Append final vote results to discussion.md
        - Generate report.md (summary for humans)
        - Print key findings to terminal
```

### Con Agent

Stance: attacks the document. Challenges assumptions, completeness, feasibility, risks, and simpler alternatives.

Analysis dimensions:

| Dimension | Check |
|-----------|-------|
| Assumptions | What implicit assumptions does the doc make? Are they reliable? |
| Completeness | Missing scenarios, edge cases, error handling, failure modes? |
| Feasibility | Is the technical approach viable? Are dependencies stable? |
| Risks | Security, performance, maintainability concerns? |
| Alternatives | Are simpler solutions ignored? (YAGNI attack) |

Each argument must include:
- **Evidence**: quote doc line numbers, external sources, similar case studies
- **Impact**: severity rating (high/medium/low)

### Pro Agent

Stance: defends the document. Reads con's arguments, accepts valid criticism, refutes flawed arguments, supplements with supporting evidence.

Each response must include:
- **Accept/Refute**: clear stance per con argument
- **Counter-evidence**: new evidence gathered from files, web, or docs

### Judge Agent

Stance: neutral evaluator. Assesses argument quality, identifies consensus, rules on disputes.

Ruling criteria:

| Ruling | Condition |
|--------|-----------|
| Con wins | Argument has solid evidence, pro cannot effectively refute |
| Pro wins | Pro provides stronger counter-evidence |
| Deferred | Both sides' evidence is comparable, needs next round |

Output: structured ruling (consensus list + ruling list + unresolved list).

### Voting Phase (Phase 3)

Triggered only when 5 rounds complete with unresolved items.

1. Driving agent dispatches one Task subagent per unresolved item
2. Each subagent votes: Con / Pro / Abstain
3. Majority decides the ruling direction
4. Tie → marked "unresolved" in report
5. Results appended to discussion.md and report.md

## Skill Structure

File: `ai-coworker-skills/devil-advocate/SKILL.md`

Frontmatter:
```yaml
---
name: ai-coworker-devil-advocate
description: |
  Use when reviewing a spec, design doc, or proposal that needs
  adversarial stress-testing. Use when you want to find hidden
  assumptions, missing edge cases, or risks before implementation.
license: MIT
compatibility: opencode
metadata:
  triggers:
    - review spec
    - review design
    - devil advocate
    - stress test
    - adversarial review
    - 杠精
  when_to_use: |
    When a spec, design doc, or proposal needs rigorous adversarial
    review before implementation. When hidden assumptions, risks,
    or missing edge cases need to be discovered.
  when_not_to_use: |
    For simple changes that don't warrant structured debate. For
    reviews where all stakeholders are already aligned. For code
    reviews (use ai-coworker-issue-report instead).
---
```

Body sections:
- Overview + When to Use / When NOT to Use
- Process: Phase 1 (Prepare), Phase 2 (Debate rounds), Phase 3 (Vote), Phase 4 (Output)
- Agent prompts: Con dimensions, Pro response format, Judge ruling criteria
- Quality Gates
- Anti-Patterns

## Quality Gates

### MUST
- [ ] Frontmatter 5 fields complete
- [ ] name matches folder name (ai-coworker-devil-advocate)
- [ ] description starts with "Use when..."
- [ ] No workflow summary in description
- [ ] No references to non-existent skills or directories
- [ ] No concrete-context leaks
- [ ] No TBD/TODO placeholders
- [ ] Phase 2 round limit explicit (max 5)
- [ ] All 3 agent roles defined (con, pro, judge)
- [ ] Output path convention specified ({project-path}/docs/devil-advocate/)

### NICE
- [ ] Body < 150 lines
- [ ] Anti-Patterns section present
- [ ] Con analysis dimensions documented as a table
- [ ] Judge ruling criteria documented as a table
- [ ] Sources section present

## Sources

- User requirement: 3-agent debate with con/pro/judge roles, max 5 rounds, majority-vote fallback
- skill-factory/CONVENTIONS.md: project-wide skill conventions
- skill-factory bootstrap design: Agent-A/B/C multi-subagent pattern
- User-confirmed: auto-review mode, both terminal + file output, primary use case is spec/design review
