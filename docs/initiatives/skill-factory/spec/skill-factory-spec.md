# skill-factory Technical Specification

**Version:** 1.0  
**Status:** Implemented  
**Last Updated:** 2026-07-23

---

## Change Log

| Date | Change | Reference |
|------|--------|-----------|
| 2026-06-10 | Public open source repository; directory structure with three skill categories (walter-worker-skills, import-skills, personal-skills); naming convention with prefix | various decisions |
| 2026-06-10 | Repository initialization with `skill-create` as bootstrap entry point | git-commit 5d9747e9 |
| 2026-06-11 | Three-directory structure finalized + prefix naming | git-commit a2e47245 |
| 2026-06-11 | `skill-create` Phase 0 multi-source search (GitHub ≥10 repos, web search, import-vs-inspire decision) | git-commit d30f01c0 |
| 2026-06-11 | `skill-import` with author preservation, import/ subdirectory | git-commit 773594b9 |
| 2026-06-11 | `skill-edit` and `skill-import` PASS quality gates | git-commit d9baa432 |
| 2026-06-11 | `skill-create` quality gate improvements | git-commit 33e48d2e |
| 2026-06-11 | TDD skill imported from mattpocock/skills | git-commit eed365ce |
| 2026-06-11 | 5 migrated coworker skills added | git-commit a5dcc4e9 |
| 2026-06-12 | `walter-worker-devil-advocate` — multi-agent adversarial review | git-commit 70ccdc4a |
| 2026-06-12 | `walter-worker-work-review` — 2-agent gatekeeper | git-commit 01f533c9 |
| 2026-06-18 | `walter-worker-contrarian-review` — 5-agent adversarial review | git-commit 3a54ffc6 |
| 2026-06-23 | Multiple skill additions, removals, and renaming; simplified naming convention | git-commit 3395648c |
| 2026-06-23 | `self-heal` and `self-analyze` skills added | git-commit dce0d79c |
| 2026-06-23 | `self-patch` renamed to `english-grammar-fix` | git-commit 7226d537 |
| 2026-07-01 | `tmux-status-bar` skill added | git-commit 5cc3d4bc |
| 2026-07-02 | Frontmatter name fixes (prefix removed from 4 skills) | git-commit bc4d6cc0 |
| 2026-07-14 | `multi-model-team` skill (GLM 5.2 + DeepSeek v4 Pro orchestration) | git-commit 56f3e001 |
| 2026-07-17 | `doc-organize` skill (9 doc types, 6 stages, INDEX.md) | git-commit ee7c7087 |
| 2026-07-18 | `youtube-summarize`, `pic-to-txt`, `youtube-research-pipeline` skills | multiple commits |
| 2026-07-22 | `skill-create` Phase 3 enhancement; `create-video-workflow` v3; `transcribe-audio` | multiple commits |
| 2026-07-23 | `luma-event-scout` skill with API scraping, speaker gate, form filling | multiple commits |

---

## 1. System Architecture Overview

The **skill-factory** is a skill management and creation system for the OpenCode/Claude Code ecosystem. It organizes skills into three isolated directories, provides creation, editing, and import workflows, and enforces quality gates through a defined specification format.

### 1.1 High-Level Structure

```
<project-root>/
├── walter-worker-skills/          # Native (first-party) skills
├── import-skills/               # Imported third-party skills
├── personal-skills/             # Private user skills (gitignored)
├── docs/
│   ├── devil-advocate/          # Devil's advocate debate outputs
│   ├── work-review/             # Work review acceptance outputs
│   └── ...                      # Other doc types
├── CONVENTIONS.md               # Project conventions
├── CLAUDE.md                    # Agent behavior rules
└── .gitignore                   # Excludes personal-skills/
```

### 1.2 Skill Lifecycle

- **Create**: via `skill-create` (self-bootstrapping process: Phase 0→1→2→3→4)
- **Edit**: via `skill-edit` (Step 1→2→3→4→5→6→7)
- **Import**: via `skill-import` (fetch → convert → audit → register)
- **Publish**: via conventional commit + quality gate validation
- **Personal**: via symlink (gitignored, not in marketplace)

### 1.3 Runtime Environment

- Skills execute within **Claude Code** (CLI) and **OpenCode** (GUI) environments
- OpenCode installation: git plugin + project-level symlink
- Claude Code: local marketplace via `extraKnownMarketplaces`
- Skills can be triggered via trigger keywords defined in skill frontmatter

---

## 2. Key Interfaces / APIs

### 2.1 SKILL.md Frontmatter Format (5-field)

All skills must have exactly these five frontmatter fields:

| Field | Description | Rules |
|-------|-------------|-------|
| `name` | Skill name | kebab-case; walter-worker- prefix for native/personal |
| `description` | One-line purpose | Must start with "Use when..." |
| `license` | License type | Default: MIT |
| `compatibility` | Compatible platforms | Default: "opencode, claude-code" |
| `trigger` | Activation keywords | Comma-separated; inferred from description+body |

**Example:**
```yaml
---
name: walter-worker-dev-advocate
description: Use when you need adversarial review of specs or design docs
license: MIT
compatibility: opencode, claude-code
trigger: review spec, 杠精, devil advocate, adversarial review
---
```

### 2.2 META.yaml Schema (Import Only)

Required for every imported skill in `import-skills/`:

```yaml
source: <URL or repo>                     # Required
upstream_commit: <commit hash>            # Required
license: <SPDX identifier>               # Required
imported_at: <ISO 8601 timestamp>         # Required
imported_by: <author/github handle>       # Required
note: <free text>                         # Optional
```

### 2.3 Skill Workflow Interfaces

#### 2.3.1 `skill-create` (Self-Bootstrapping Process)

**Entry**: No target exists  
**Phases**:
| Phase | Action | Output |
|-------|--------|--------|
| 0 | Multi-source search (GitHub ≥10 repo results, web search) | Decision: import / absorb inspiration / build from scratch |
| 1 | Interview (user role simulation) | Requirements |
| 2 | Build SKILL.md following 5-field frontmatter + CONVENTIONS.md body | Draft SKILL.md (≤150 lines) |
| 3 | Precision & Examples with legal-clause bounds + 2-3 example spectrum | Refined SKILL.md |
| 4 | Quality gates validation + commit + publish | Final SKILL.md |

**Quality Gates (MUST — block commit)**:
- `description ≤ 500 characters`
- `Body < 150 lines` (hardened from 500)
- `No deploy/ concept` (prevent invalid structures)
- `Quality Gates section present with MUST/NICE checkboxes`
- `Anti-Patterns section present`
- `Philosophy-driven overview`

**Quality Gates (NICE — warn only)**:
- `description ≤ 500 chars`
- `Anti-Patterns section present`
- `Quality Gates section present`
- `Philosophy-driven overview`
- `Body < 150 lines`

#### 2.3.2 `skill-edit` (Modification Workflow)

**Entry**: Target exists and change < 80% rewrite  
**Steps**:
1. **Check existence**: If not exists → redirect to `skill-create`
2. **Fetch source**: Use `webfetch` (preferred) or `curl`
3. **Assess scope**: If ≥80% rewrite → redirect to `skill-create`
4. **Present diff summary** → get user approval
5. **Make targeted edits** (Edit tool only, never Write entire file, never create new file)
6. **Run quality gates** (MUST gates block commit)
7. **Publish** with conventional commit message

#### 2.3.3 `skill-import` (Third-Party Conversion)

**Entry**: External source URL/repo  
**Steps**:
1. **Fetch source** SKILL.md using webfetch/curl
2. **Auto-convert frontmatter**:
   - `name` → kebab-case
   - `description` → begins with "Use when..."
   - `license` → MIT (default)
   - `compatibility` → "opencode, claude-code" (default)
   - `triggers` → inferred from description and body
3. **Auto-adapt body sections**:
   - Philosophy → overview
   - Anti-Pattern → Anti-Patterns
   - Workflow → Process
   - Checklist → Quality Gates
   - Remove: Changelog, Convention Notes
4. **Write META.yaml** with source, upstream_commit, license, imported_at, imported_by
5. **Place in** `import-skills/<name>/SKILL.md`
6. **Validate quality gates** → commit

**Ambiguity Triggers**: Ask user one question at a time only when:
- No license specified
- Triggers are unclear
- Unknown body section encountered

#### 2.3.4 `devil-advocate` (Adversarial Review)

**Architecture**: Main agent orchestration with 3 stateless subagents per round  
**Process**:
1. Con agent → presents arguments against
2. Pro agent → defends position
3. Judge agent → summarizes and identifies unresolved points
4. **Limit**: Max 5 rounds; unresolved points resolved by 3-agent majority vote

**Output**: `{project-path}/docs/devil-advocate/YYYY-MM-DD-<topic>/`
- `discussion.md` — full debate transcript
- `report.md` — human-readable summary

**Triggers**: `review spec`, `杠精`, `devil advocate`, `adversarial review`

#### 2.3.5 `work-review` (Acceptance Gatekeeper)

**Architecture**: Sequential 2-agent (Collector → Reviewer), no auto-retry  
**Agent 1 (Collector)**:
- Writes test plan (scenarios, types, steps)
- **Does NOT** write executable test code

**Agent 2 (Reviewer)**:
- Executes test plan
- Runs existing UT/FT
- Writes Playwright tests for E2E
- Uses curl/httpie for manual tests
- Validates each acceptance criterion

**Output**: `{project-path}/docs/work-review/YYYY-MM-DD-<topic>/`
- `acceptance.md` — test plan
- `report.md` — execution results

**Triggers**: `work review`, `acceptance`, `sign off`, `verify work`

---

## 3. Data Models / Schemas

### 3.1 Skill Definition (SKILL.md)

**Structure**:
```yaml
---
name: <string>                        # 5-field frontmatter
description: <string>                 # Must start "Use when..."
license: <string>                     # Default: MIT
compatibility: <string>               # Default: "opencode, claude-code"
trigger: <string>                     # Comma-separated
---

# Overview
<philosophy-driven description>        # Mapped from Philosophy

## Process
<workflow description>                 # Mapped from Workflow

## Anti-Patterns
- <list of common mistakes>           # Required section

## Quality Gates
### MUST (block)
- [ ] <gate description>
### NICE (warn)
- [ ] <gate description>
```

**Constraints**:
- Body (excluding frontmatter): ≤150 lines (target; soft limit)
- File must end with newline

### 3.2 Import Metadata (META.yaml)

```yaml
source: <url>
upstream_commit: <