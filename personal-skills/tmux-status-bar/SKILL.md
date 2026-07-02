---
name: tmux-status-bar
description: |
  Use when setting up or customizing the tmux status bar to display session name,
  project folder, git branch, git status, and active initiative from coworker.
  Triggered by phrases like "tmux bar", "tmux status", "customize tmux",
  "setup tmux display".
license: MIT
compatibility: opencode
metadata:
  triggers:
    - customize tmux
    - tmux bar
    - tmux status
    - tmux display
    - setup tmux
    - configure tmux
  when_to_use: |
    When the user wants to customize their tmux status bar to show project context,
    git information, and coworker initiative. Use this skill to create or update
    the status bar configuration.
  when_not_to_use: |
    For general tmux configuration (keybinds, plugins, colors) — those are
    separate topics. For tmux session management only.
---

# tmux-status-bar

Customize the tmux status bar with project-aware context: session name,
project folder, git branch + status, and active coworker initiative.

## When to Use

- User wants to see project/git/initiative info in their tmux bar
- Setting up tmux status bar from scratch
- Updating an existing tmux bar to show more context
- User asks to "show git branch in tmux" or "add initiative to tmux"

## When NOT to Use

- Non-tmux terminal setups (zsh prompt, starship, etc.)
- tmux plugin installation (use tmux-setup skill instead)
- General shell prompt customization

## Process

### Step 1: Create the status info script

Create `~/.tmux/scripts/status_info.sh`:

```sh
#!/bin/sh
# tmux status bar: session | project | branch | git status | initiative

SESSION=$(tmux display-message -p '#{session_name}' 2>/dev/null)
PANE_PATH=$(tmux display-message -p -F '#{pane_current_path}' 2>/dev/null)

if [ ! -d "$PANE_PATH" ]; then exit 0; fi
cd "$PANE_PATH" || exit 0

printf "#[fg=colour240]tmux:#[fg=green]%s#[fg=colour240] | " "$SESSION"

PROJECT_DIR=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -n "$PROJECT_DIR" ]; then
    FOLDER=$(basename "$PROJECT_DIR")
else
    FOLDER=$(basename "$PWD")
fi
printf "#[fg=colour240]project:#[fg=brightwhite]%s#[fg=colour240] | " "$FOLDER"

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$BRANCH" ]; then
    printf "#[fg=colour240]branch:#[fg=cyan]%s" "$BRANCH"
else
    printf "#[fg=colour240]branch:#[fg=colour245]--"
fi

if [ -n "$BRANCH" ]; then
    BEHIND=0; AHEAD=0
    REMOTE=$(git rev-parse --abbrev-ref "@{u}" 2>/dev/null)
    if [ -n "$REMOTE" ]; then
        BEHIND=$(git rev-list --count HEAD.."@{u}" 2>/dev/null || echo 0)
        AHEAD=$(git rev-list --count "@{u}"..HEAD 2>/dev/null || echo 0)
    fi

    DIRTY=0; STAGED=0; UNTRACKED=0
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        DIRTY=1
        STAGED=$(git diff --cached --name-only 2>/dev/null | wc -l)
        UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l)
    fi

    printf " #[fg=colour240]status:"
    [ "$AHEAD" -gt 0 ] && printf "#[fg=yellow]%s" "↑${AHEAD}"
    [ "$BEHIND" -gt 0 ] && printf "#[fg=red]%s" "↓${BEHIND}"
    [ "$STAGED" -gt 0 ] && printf "#[fg=green]%s" "+${STAGED}"
    [ "$UNTRACKED" -gt 0 ] && printf "#[fg=magenta]%s" "?${UNTRACKED}"
    [ "$DIRTY" -eq 1 ] && printf "#[fg=yellow]*" || printf "#[fg=green]✓"
fi

INITIATIVE=""
for DIR in "$PANE_PATH" "$PROJECT_DIR" "$HOME"; do
    if [ -n "$DIR" ] && [ -f "$DIR/.coworker/initiatives/.active" ]; then
        INITIATIVE=$(cat "$DIR/.coworker/initiatives/.active" 2>/dev/null)
        break
    fi
done
if [ -n "$INITIATIVE" ]; then
    printf " #[fg=colour240]| initiative:#[fg=magenta]%s" "$INITIATIVE"
fi
```

Make it executable:

```sh
chmod +x ~/.tmux/scripts/status_info.sh
```

### Step 2: Update tmux config

Edit `~/.tmux.conf`. Ensure it has the following status bar settings
(use existing settings if already configured):

```
set -g status-style 'bg=colour236,fg=white'

set -g status-left-length 40
set -g status-left "#[fg=yellow]#{session_created_string} "

set -g status-right-length 250
set -g status-right "#(~/.tmux/scripts/status_info.sh) "
```

Replace existing `status-left` and `status-right` lines — do NOT append.

### Step 3: Reload

```sh
tmux source-file ~/.tmux.conf
```

### Fallback

If the script produces no output, check:
- `tmux display-message -p -F '#{pane_current_path}'` returns a valid directory
- The script has execute permission
- `status-right-length` is at least 250

## Status Bar Layout

```
 2026-07-01 06:45:23   [tmux:opencode | project:opencode | branch:dev status:↑1 ✓ | initiative:claude-md-design]  [1:zsh]
```

| Field | Color | Meaning |
|-------|-------|---------|
| `tmux:NAME` | green | Session name |
| `project:NAME` | white | Git repo top-level basename |
| `branch:NAME` | cyan | Current git branch |
| `status:↑N ↓N +N ?N ✓/*` | yellow/red/green/magenta | Ahead, behind, staged, untracked, clean/dirty |
| `initiative:NAME` | magenta | Active coworker initiative (from `.coworker/initiatives/.active`) |

## Sources

- Script design: confidence high — verified working on Linux with tmux 3.x
- Color codes: tmux standard `fg=colourN` format, works with truecolor terminals
- Initiative detection: walks up from pane path to find `.coworker/initiatives/.active`
