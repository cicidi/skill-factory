---
name: self-heal
description: Log user corrections to project's .self-healing/traces/. Auto-installs global hooks for Claude Code and OpenCode.
license: MIT
compatibility: claude-code,opencode
metadata:
  triggers:
    - self-heal
    - log correction
    - trace
  when_to_use: When the user corrects the AI and the correction should be logged for future pattern analysis.
  audience: ai-coworker
---

# Self-Heal

Log every user correction for pattern analysis.

## When to Use

- When the user says "no", "don't", "stop", "wrong", "never do that" etc.
- When the AI makes a mistake that should be prevented in the future
- When setting up self-healing hooks for the first time

## When NOT to Use

- For trivial stylistic preferences that won't repeat
- When the user explicitly says not to log the correction

## Trigger

Auto-detected when user corrects AI. Keywords: "no", "don't", "stop", "wrong", "not like that", "never do", "I told you".

## Process

### 1. Check Hooks

Check both IDEs:

```bash
ls ~/.claude/hooks/on-self-heal.sh 2>/dev/null   # Claude Code
```

```bash
ls ~/.config/opencode/hooks/on-self-heal.sh 2>/dev/null  # OpenCode
```

If missing for any detected IDE → offer to install:

```
→ "Self-heal hook missing for {ide}. Install global hook? (y/n)"
→ If yes: create hook script + register in settings
```

### 2. Hook Placement

Global hooks — work for ALL projects:

```
~/.claude/hooks/on-self-heal.sh            # Claude Code
~/.config/opencode/hooks/on-self-heal.sh   # OpenCode
```

Register in settings:

```json
// ~/.claude/settings.json
{
  "hooks": {
    "UserPromptSubmit": [
      {"matcher": "", "command": "bash ~/.claude/hooks/on-self-heal.sh"}
    ]
  }
}

// ~/.config/opencode/config.json  
{
  "hooks": {
    "UserPromptSubmit": [
      {"command": "bash ~/.config/opencode/hooks/on-self-heal.sh"}
    ]
  }
}
```

### 3. Write Trace

Hook writes to current project: `{project}/.self-healing/traces/{YYYY-MM-DD}.yaml`

```yaml
- id: {uuid}
  timestamp: {ISO8601}
  context: "what AI did wrong"
  correction: "what user said"
  category: code-conventions|workflow|security|architecture|tool-use
```

### 4. Acknowledge

```
"Logged correction. Run self-analyze later to find patterns."
```

## Hook Script

```bash
#!/usr/bin/env bash
# ~/.claude/hooks/on-self-heal.sh (also at ~/.config/opencode/hooks/)
input=$(cat)
if echo "$input" | grep -qiE "\b(no|don'?t|stop|wrong|not like that|never|i told you)\b"; then
  DIR=".self-healing/traces"
  mkdir -p "$DIR"
  FILE="$DIR/$(date +%Y-%m-%d).yaml"
  ID=$(uuidgen 2>/dev/null || echo "$(date +%s)-$RANDOM")
  cat >> "$FILE" <<YAML
- id: $ID
  timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
  context: ""
  correction: "$(echo "$input" | tr '\n' ' ' | sed 's/"/\\"/g' | cut -c1-300)"
  category: workflow
YAML
fi
echo " "
```

## Categories

- `code-conventions` — style, naming, imports
- `workflow` — pipeline steps, commits, PRs
- `security` — secrets, injection
- `architecture` — design, patterns
- `tool-use` — wrong tool, wrong command
