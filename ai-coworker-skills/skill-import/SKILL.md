---
name: skill-import
description: |
  Use when importing an external SKILL.md from a GitHub URL or another
  repository into skill-factory under the import/ directory. Use when
  converting a skill from a non-opencode format to skill-factory
  conventions while preserving original authorship.
license: MIT
compatibility: opencode, claude-code
metadata:
  triggers:
    - import a skill
    - import skill
    - add skill from
    - convert skill
    - pull skill
    - bring in a skill
    - migrate skill
  when_to_use: |
    When the user provides a URL to an external SKILL.md and wants to
    import it into skill-factory under the import/ directory as a
    CONVENTIONS.md-compliant skill with original authorship preserved.
  when_not_to_use: |
    When the skill already exists in ai-coworker-skills/ or
    ai-coworker-skills/import/. When the source is not a valid SKILL.md.
    When the conversion requires substantial content rewriting beyond
    format mapping — use skill-create instead.
  factor_weights:
    accuracy: 0.4
    tool_integration: 0.25
    edge_cases: 0.2
    readability: 0.1
    speed: 0.05
  phase_count: 3
  audience:
    - skill-authors
    - skill-importer
---

# skill-import

Imports an external SKILL.md into skill-factory by auto-converting
frontmatter and body sections to opencode 5-field format, asking the user
only when unambiguous mapping fails.

## When to Use

- You have a URL to an external SKILL.md to pull into skill-factory
- The source uses Claude Code or other non-opencode frontmatter
- The source needs its `name` converted to kebab-case
- The source `description` field needs "Use when..." rewording
- The source body sections need mapping to CONVENTIONS.md structure

## When NOT to Use

- The skill already exists in `ai-coworker-skills/` or `ai-coworker-skills/import/` by name or trigger match
- The URL points to rendered HTML, not raw markdown
- The source has no frontmatter or is not markdown
- The conversion requires rewriting core instructions — use skill-create

## Process

### Phase 0: Reuse Audit

1. List existing skills: `ls ai-coworker-skills/` and `ls ai-coworker-skills/import/`
2. Read frontmatter of each for `name` and `metadata.triggers`
3. If the source name matches an existing skill (including in import/), STOP and report conflict
4. If clear, proceed to Phase 1

### Phase 1: Fetch and Parse

1. Fetch the source SKILL.md via webfetch or curl
2. Verify it is valid markdown with YAML frontmatter
3. If not valid, STOP — report: "Source is not a valid SKILL.md"

### Phase 2: Auto-Convert

Apply conversion rules without asking. Only pause for ambiguity.

#### Frontmatter Mapping

| Source Field | Target Field | Rule |
|---|---|---|
| `name` | `name` | Convert to kebab-case, drop filler words |
| `description` | `description` | Rewrite to start "Use when...", third person |
| `license` (missing) | `license` | Default `MIT` |
| `compatibility` (missing) | `compatibility` | Default `opencode, claude-code` |
| — | `metadata.triggers` | Infer from description and body patterns |
| — | `metadata.when_to_use` | Summarize source description intent |
| — | `metadata.when_not_to_use` | Infer from source limitations |
| Source repo/author | `metadata.source_url` | Original repo URL (from user input) |
| Source repo/author | `metadata.source_author` | Original author or organization |

#### Body Section Mapping

| Source Section | Target Section | Rule |
|---|---|---|
| Philosophy / intro | `# <name>` overview | 1-2 sentence core principle |
| When to Use | `## When to Use` | Keep as-is, bullet format |
| When NOT to Use | `## When NOT to Use` | Keep as-is |
| Workflow | `## Process` | Convert to numbered phases |
| Checklist | `## Quality Gates` | Convert to MUST/NICE checkboxes |
| Anti-patterns | `## Anti-Patterns` | Keep as-is |
| Sources | `## Sources` | Append imported from <url> |
| Changelog | REMOVE | Prohibited per CONVENTIONS.md |
| Convention Notes | REMOVE | Prohibited per CONVENTIONS.md |
| Unknown section | PAUSE | Ask user |

#### Ambiguity Triggers (ASK USER, one at a time)

- Source has no recognizable license field
- Inferred triggers seem wrong
- Source body section doesn't fit any mapping rule
- Source name conflicts with an existing skill
- Source contains concrete-context leaks

### Phase 3: Write and Commit

1. Create directory: `ai-coworker-skills/import/<name>/`
2. Write SKILL.md to that path
3. Stage: `git add ai-coworker-skills/import/<name>/`
4. Commit: `skill: import <name> from <source-repo> by <author>`
5. Report: "Imported as `ai-coworker-skills/import/<name>/SKILL.md`, commit `<hash>`"

## Quality Gates

### MUST (block commit on failure)

- [ ] Reuse audit ran — no name or trigger conflict with existing skills
- [ ] Source was valid markdown with YAML frontmatter
- [ ] Frontmatter has all 5 fields
- [ ] `name` is kebab-case and matches folder name
- [ ] `description` starts with "Use when..."
- [ ] `description` is not first person and does not summarize workflow
- [ ] No prohibited sections: Changelog, Convention Notes
- [ ] No concrete-context leaks
- [ ] No TBD/TODO/truncated sentences
- [ ] No decorative emoji in body
- [ ] `metadata.source_author` present with original author name
- [ ] `metadata.source_url` present with original source URL
- [ ] Body passes CONVENTIONS.md compliance scan

### NICE (warn but don't block)

- [ ] `description` ≤ 500 chars
- [ ] Body < 500 lines
- [ ] `## Sources` section includes import provenance URL
- [ ] Converted `## Anti-Patterns` uses plain labels

## Anti-Patterns

### 1. Silent conversion of ambiguous content

**Symptom:** Guessing the correct mapping instead of asking.

**Why wrong:** Wrong mapping cascades into misstructured instructions.
**Fix:** Pause and ask the user using the Ambiguity Triggers list.

### 2. Copying verbatim without CONVENTIONS.md scrub

**Symptom:** Source uses "I can help you..." descriptions or includes Changelog.

**Why wrong:** Produces a non-compliant skill that fails quality gates.
**Fix:** Run auto-convert rules before writing.

### 3. Skipping reuse audit

**Symptom:** Importing before checking whether the skill already exists.

**Why wrong:** Creates a duplicate that diverges from the original.
**Fix:** Run Phase 0 before Phase 1.

### 4. Writing to an existing directory

**Symptom:** Creating directory when it already exists.

**Why wrong:** Overwrites or collides with an existing skill.
**Fix:** Stop and report the conflict.

### 5. Losing original authorship

**Symptom:** Imported skill lacks `metadata.source_author` or
`metadata.source_url`.

**Why wrong:** Attribution is lost. Skills travel across projects and
teams — without provenance the original author gets no credit and future
readers lose context.

**Fix:** Always record `source_author` and `source_url` in the imported
skill's frontmatter metadata.

## Sources

- Process design: confidence high — mirrors skill-create's pipeline adapted for import
- Frontmatter mapping rules: confidence high — derived from CONVENTIONS.md 5-field format
- Body section mapping: confidence high — based on CONVENTIONS.md section table
- Ambiguity triggers: confidence medium — may expand as more source formats encountered
