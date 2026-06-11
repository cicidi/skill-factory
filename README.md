# skill-factory

A curated collection of AI agent skills (SKILL.md format), framework-agnostic, opencode-native.

## What's a skill?

A **skill** is a self-contained directory with a `SKILL.md` file. It packages "how to do X" in a way any SKILL.md-aware agent can execute. Copy it, fork it, move it between projects — it just works.

## Available skills

| Skill | Description |
|-------|-------------|
| [skill-create](ai-coworker-skills/skill-create/) | 4-phase workflow to create new skills — search, interview, build, verify, publish |

## Install

```bash
git clone https://github.com/<org>/skill-factory.git ~/.config/opencode/skills/skill-factory
```

Or copy individual skills:

```bash
cp -r ai-coworker-skills/skill-create ~/.config/opencode/skills/
```

## Conventions

See [CONVENTIONS.md](CONVENTIONS.md) for the project's conventions.

## License

MIT — see LICENSE file.
