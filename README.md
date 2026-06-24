# skill-factory

A curated collection of AI agent skills (SKILL.md format), framework-agnostic, opencode-native.

## What's a skill?

A **skill** is a self-contained directory with a `SKILL.md` file. It packages "how to do X" in a way any SKILL.md-aware agent can execute. Copy it, fork it, move it between projects — it just works.

## Available Skills

### Factory-Native Skills (`ai-coworker-skills/`)

| Skill | Description |
|-------|-------------|
| [auto-tdd](ai-coworker-skills/auto-tdd/) | Continuous multi-agent TDD loop with Agent-A (impl), Agent-B (test), Agent-C (arbitration), Agent-D (quality) |
| [bug-hunt](ai-coworker-skills/bug-hunt/) | Scientific debugging — hypothesis → test → confirm → fix |
| [bug-report](ai-coworker-skills/bug-report/) | Report bugs or problems with the AI coworker system to GitHub Issues |
| [contrarian-review](ai-coworker-skills/contrarian-review/) | Multi-agent adversarial document review with structured debate and judged resolution |
| [devil-advocate](ai-coworker-skills/devil-advocate/) | Multi-agent adversarial review for specs and design docs |
| [doc-merge](ai-coworker-skills/doc-merge/) | Merge two versions of a markdown document after upstream sync conflicts |
| [english-grammar-fix](ai-coworker-skills/english-grammar-fix/) | Auto-correct minor English grammar errors in AI responses |
| [self-analyze](ai-coworker-skills/self-analyze/) | Scan correction traces, find patterns, inject rules into CLAUDE.md |
| [self-heal](ai-coworker-skills/self-heal/) | Log user corrections to traces for pattern analysis |
| [skill-create](ai-coworker-skills/skill-create/) | 5-phase workflow to create new skills with source repo enforcement and deploy |
| [skill-edit](ai-coworker-skills/skill-edit/) | Safely edit existing skills with source repo enforcement and deploy |
| [skill-import](ai-coworker-skills/skill-import/) | Import external SKILL.md into skill-factory preserving original authorship |
| [work-review](ai-coworker-skills/work-review/) | 2-agent gatekeeper for work acceptance sign-off |

### Personal Skills (`personal-skills/`)

| Skill | Description |
|-------|-------------|
| [doc-protect](personal-skills/doc-protect/) | Protect sections of documents from AI edits |

### Imported Skills (`import-skills/`)

| Skill | Description |
|-------|-------------|
| [tdd](import-skills/tdd/) | Test-driven development with red-green-refactor cycles |

## Workflow

Skills are created and edited in this source code repo, then deployed to IDE configs:

```
Source Repo (~/project/skill-factory/) → git push → Deployed Copy → IDE Configs
```

**Never create or edit skills directly in the deployed copy** (`~/.config/opencode/skills/skill-factory/`) or IDE config directories (`~/.claude/commands/`, `~/.opencode/instructions/`). Changes in deployed copies are lost on next install.

## Install

```bash
git clone https://github.com/cicidi/skill-factory.git ~/project/skill-factory
```

To deploy skills to your IDEs, use the ai-coworker install script or `coworker sync`.

## Testing

```bash
bash tests/test_skills.sh
```

Validates all skills against skill-factory conventions: frontmatter completeness, required sections, prohibited patterns, duplicate names, and more.

## Conventions

See [CONVENTIONS.md](CONVENTIONS.md) for the project's conventions.

## License

MIT — see LICENSE file.
