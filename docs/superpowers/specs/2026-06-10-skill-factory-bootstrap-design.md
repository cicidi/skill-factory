# skill-factory Bootstrap Design

Date: 2026-06-10

## Goal

Bootstrap the skill-factory project with a self-improving iteration loop:

1. Fix `skill-create` (the meta skill for creating skills)
2. Use `skill-create` to build `skill-edit` and `skill-import`
3. Use `skill-import` to import mattpocock's TDD skill
4. Use `skill-edit` to optimize the imported TDD skill
5. If any skill is subpar, diagnose and fix `skill-create`, then re-create all downstream skills

## Project Structure

```
skill-factory/
├── .claude-plugin/          # Claude Code plugin registration
├── .opencode/               # OpenCode configuration
├── ai-coworker-skills/      # All production skills
│   ├── skill-create/        # Create new skills (fixed)
│   │   └── SKILL.md
│   ├── skill-edit/          # Edit existing skills (to be created)
│   │   └── SKILL.md
│   └── skill-import/        # Import skills from external sources (to be created)
│       └── SKILL.md
├── docs/superpowers/specs/  # Design documents
├── LICENSE                  # MIT
├── README.md
└── CONVENTIONS.md           # Project-wide skill conventions
```

### What gets removed

- `ai-worker-skills/` — empty test scaffolding, not needed for bootstrap

## Skill Format Standard

All skills use opencode 5-field frontmatter, with body style inspired by mattpocock/skills (philosophy-driven, anti-patterns, actionable checklists), under 150 lines.

```yaml
---
name: <kebab-case-name>
description: |
  Use when <triggering condition>. Describes the problem, NOT the solution.
  Third person only. No workflow summary. ≤500 chars ideal.
license: MIT
compatibility: opencode, claude-code
metadata:
  triggers:
    - <trigger phrase>
  when_to_use: |
    <description>
  when_not_to_use: |
    <description>
---
```

Body sections follow CONVENTIONS.md with mattpocock-style additions (philosophy-first, anti-patterns, per-phase checklists).

## Platform Support

- **OpenCode** — primary target, `.opencode/` config
- **Claude Code** — `.claude-plugin/` for plugin registration

## skill-create Fixes (Pre-bootstrap)

### Critical MUST-gate violations

1. **References non-existent `skill-edit`** (lines 6, 21, 47, 68) — Gate #7 violation. Replace with generic language ("edit the existing skill directly using skill-edit when it becomes available")
2. **Description contains workflow summary** (line 4) — Gate #5 violation. "Walks through search, interview, build, verify, and publish phases" is a workflow description. Remove, keep only triggering conditions.
3. **Description mixes when_not_to_use content** (line 6) — Remove from description; already in metadata.when_not_to_use.

### Other fixes

4. **Anti-Pattern 4 title** (line 253) — "Verbatim user prompt in Examples" — body structure has no `## Examples` section. Rename to match actual usage.

## Iteration Process

Run in current session. I (the driving agent) launch 3 Task subagents per round in sequence:

```
Round N:
  ┌── Task Agent-A: simulate user + skill-create
  │     1. Create skill-edit  (Phase 0→1→2→3→4)
  │     2. Create skill-import (Phase 0→1→2→3→4)
  │     Returns: both SKILL.md contents
  │
  ├── Task Agent-B: self-evaluation
  │     Evaluate both skills against CONVENTIONS.md + quality gates
  │     Returns: issue list
  │
  └── Task Agent-C: review + diagnose + fix
        1. Review both skills against all MUST/NICE gates
        2. Diagnose: if skills have issues, what's wrong with skill-create?
        3. Fix skill-create SKILL.md
        4. If skill-create changed → go to Round N+1
        5. If clean → iteration complete
```

Exit criterion: Agent-C finds zero MUST-gate violations in both skill-edit and skill-import.

## Final Verification

After iteration converges:

1. Use `skill-import` to import `mattpocock/skills/skills/engineering/tdd/SKILL.md` into `ai-coworker-skills/tdd/SKILL.md`
2. Use `skill-edit` to optimize the imported TDD skill (format compliance, quality gates)
3. All skills must pass their own quality gates

## skill-import Design

Converts external skills to opencode 5-field format.

**Workflow:**
1. Fetch source SKILL.md from URL
2. Auto-convert frontmatter (infer missing fields: license→MIT, compatibility→opencode, generate metadata.triggers from skill name)
3. Auto-adapt body to CONVENTIONS.md section structure
4. **Subagent asks user one question at a time** only when ambiguous (e.g., "Source has no license field. Default MIT ok?")
5. Write to `ai-coworker-skills/<name>/SKILL.md`
6. Commit

**Conversion rules:**
- mattpocock `name` → opencode `name`
- mattpocock `description` → opencode `description` (may need rewording to "Use when...")
- Missing `license` → "MIT"
- Missing `compatibility` → "opencode, claude-code"
- Infer `metadata.triggers` from skill name and description
- Body sections mapped: Philosophy→overview, Anti-Pattern→Anti-Patterns, Workflow→Process, Checklist→Quality Gates

## skill-edit Design

Safe, small edits to existing skills with full process enforcement.

**Workflow:**
1. Reuse audit — confirm the target skill exists, confirm no new skill creation is happening
2. Load target skill — read current SKILL.md
3. Interview — understand what change the user wants (one question at a time)
4. Plan changes — show diff summary, get approval
5. Apply changes — edit the SKILL.md
6. Verify — run quality gates (MUST pass), check no regressions
7. Commit

**Constraints:**
- Never create a new skill file (that's skill-create's job)
- Never duplicate into a new directory
- Every edit must pass MUST quality gates
- Output diff-style summary of what changed

## Quality Gates (shared across all new skills)

### MUST (block)
- [ ] Frontmatter 5 fields complete
- [ ] `name` matches folder name
- [ ] `description` ≤ 1024 chars, starts with "Use when..."
- [ ] No workflow summary in description
- [ ] No references to non-existent skills
- [ ] No concrete-context leaks
- [ ] No TBD/TODO placeholders

### NICE (warn)
- [ ] Body < 150 lines
- [ ] Anti-patterns section present
- [ ] Checklist per phase
- [ ] `## Sources` section present

## Documentation Convention

Every step writes to `docs/superpowers/` for full traceability:

```
docs/superpowers/
├── specs/                          # Design documents (static)
│   └── YYYY-MM-DD-<topic>-design.md
├── rounds/                         # Per-round logs (dynamic)
│   ├── round-01/
│   │   ├── agent-a-skill-edit.md   # Agent-A creates skill-edit
│   │   ├── agent-a-skill-import.md # Agent-A creates skill-import
│   │   ├── agent-b-eval.md         # Agent-B self-evaluation
│   │   └── agent-c-review.md       # Agent-C review + diagnosis
│   └── round-NN/
│       └── ...
├── final-verification/             # Final validation
│   ├── import-tdd.md               # skill-import imports TDD
│   └── edit-tdd.md                 # skill-edit optimizes TDD
└── summary.md                      # Final summary of all rounds
```

Each agent output document contains:
- Agent name and round number
- Input (what it was given)
- Process log (what it did step by step)
- Output (what it produced)
- Decision rationale (why choices were made)

## Sources

- mattpocock/skills (125k stars): SKILL.md raw content, repo structure, philosophy-driven style
- obra/superpowers (224k stars): opencode 5-field format, multi-platform plugin structure
- Current project: CONVENTIONS.md, skill-create/SKILL.md (baseline to fix)
