```markdown
# skill-factory Test Plan

## Change Log

| Date | Version | Description |
|------|---------|-------------|
| 2026-07-23 | 1.0 | Initial test plan, derived from development history (commits 5d9747e9…5bfdb57e) |

---

## 1. Testing Strategy

| Level | Scope | Approach |
|-------|-------|----------|
| **Unit** | Skill helper scripts, validation functions, metadata parsers | Isolated tests with mock inputs; run in CI on every push. |
| **Integration** | Cross-skill workflows (skill-create → skill-edit → commit), agent orchestrations (devil-advocate, work-review), import pipeline | Use real or simulated skill files; verify intermediate outputs and final state. |
| **End‑to‑End** | Full user journeys: create a skill from scratch, import a third‑party skill, run an adversarial review, execute a work‑review sign‑off | Execute in a temporary repository; verify all side‑effects (commits, files, marketplace registration). |
| **Static Analysis** | Skill content conformance, frontmatter format, line count, naming rules, metadata completeness | Lint‑style checks (MUST / NICE gates) set up in CI and optionally as pre‑commit hooks. |

### 1.1 Unit Testing

- **Validation helpers**: `is_under_150_lines()`, `description_length_check()`, `prefix_enforcement()`, `anti_patterns_present()`, `metadata_complete()`.
- **Agent sub‑components**: Collector/Reviewer logic for `work-review`, Con/Pro/Judge for `devil-advocate` – test state transitions and vote aggregation.

### 1.2 Integration Testing

- **skill-create** execution (Phase 0–4) with mocked external search results.
- **skill-edit** pipeline: fetch → convert → write → validate.
- **skill-import** workflow: fetch → extract → write metadata → register.
- **Cross‑skill**: skill-edit → redirect to skill-create when ≥80% rewrite.
- **Agent orchestration**: devil-advocate 5‑round debate with vote fallback; work-review with automatic test execution.

### 1.3 End‑to‑End Testing

- Full “Create a coworker skill” journey (including commit and marketplace symlink).
- “Import a skill from GitHub” with metadata validation and CI enforcement.
- “Run work-review against a feature branch” – agent 2 runs Playwright E2E + existing unit tests, produces `acceptance.md` and `report.md`.
- “Trigger devil-advocate on a spec” – outputs `discussion.md` and `report.md` in `docs/devil-advocate/`.

### 1.4 Static Analysis / Content Validation

- **All skills** must pass the MUST gates defined in their own `Quality Gates` section.
- **Import skills** must have a complete `META.yaml` (source, upstream_commit, license, imported_at, imported_by, note).
- **Naming**: `walter-worker-` prefix for own skills; no prefix for imports; folder names unchanged.
- **Line count**: body ≤150 lines (NICE), enforced as soft target.
- **Description**: ≤500 chars.
- **Sections**: must include Anti-Patterns, Quality Gates (MUST/NICE), Philosophy‑driven overview.

---

## 2. Key Test Scenarios

### 2.1 Skill Creation (`skill-create`)

| ID | Scenario | Expected Outcome |
|----|----------|------------------|
| SC‑01 | Phase 0 with external search – GitHub (≥10 repos) and Web search – user chooses “import” | Skill is created from fetched content, stored in `import-skills/`. |
| SC‑02 | Phase 0 – user chooses “absorb inspiration” | Skill is created with original content but inspired by found examples. |
| SC‑03 | Phase 0 – user chooses “build from scratch” | No external data used; standard interview Phase 1 begins. |
| SC‑04 | Phase 2 – generated skill includes Anti-Patterns, Quality Gates, Philosophy overview | All three sections present. |
| SC‑05 | Line count of body exceeds 150 | NICE gate triggers warning; skill can still be committed. |
| SC‑06 | Body exceeds 500 lines | (Original loose gate) – tightened to <150; test that gate now warns at 151+. |
| SC‑07 | Description >500 chars | NICE gate warns. |
| SC‑08 | Skill contains `deploy/` concept | MUST gate blocks commit. |

### 2.2 Skill Editing (`skill-edit`)

| ID | Scenario | Expected Outcome |
|----|----------|------------------|
| SE‑01 | Edit existing skill – change <80% of content | Targeted changes applied via Edit tool; no new file created. |
| SE‑02 | Change ≥80% of content | Tool redirects to `skill-create`. |
| SE‑03 | Non‑existent skill | Redirect to `skill-create`. |
| SE‑04 | Auto‑convert frontmatter (kebab‑case name, `Use when…` description, MIT license, opencode/claude‑code compatibility) | All fields correct. |
| SE‑05 | Auto‑adapt body sections (Philosophy→overview, Anti‑Pattern→Anti‑Patterns, Workflow→Process, Checklist→Quality Gates; remove Changelog/Convention Notes) | Section mapping performed correctly. |
| SE‑06 | Ambiguity triggers – unclear license, unknown body section | Agent asks exactly one clarifying question. |

### 2.3 Skill Import (`skill-import`)

| ID | Scenario | Expected Outcome |
|----|----------|------------------|
| SI‑01 | Import valid upstream skill (e.g. `tdd` from mattpocock/skills) | Skill placed in `import-skills/`, name unchanged, prefix not added. |
| SI‑02 | Metadata preservation – `source_author`, `source_url` present | Both fields written and validated in CI. |
| SI‑03 | Missing metadata (no license) | Ambiguity trigger: agent asks one question. |
| SI‑04 | CI validation of import metadata completeness | Pipeline fails if `META.yaml` is missing or incomplete. |

### 2.4 Agent‑Based Skills

#### Devil‑Advocate (`walter-worker-devil-advocate`)

| ID | Scenario | Expected Outcome |
|----|----------|------------------|
| DA‑01 | Trigger: “review spec” on a design document | Two output files: `discussion.md` (full debate) and `report.md` (summary). |
| DA‑02 | Debate reaches 5‑round limit | Fallback to 3‑agent majority vote; vote recorded in report. |
| DA‑03 | Trigger: “杠精” / “devil advocate” / “adversarial review” | Skill activates and follows same process. |

#### Work‑Review (`walter-worker-work-review`)

| ID | Scenario | Expected Outcome |
|----|----------|------------------|
| WR‑01 | Agent 1 (Collector) creates a test plan (no executable code) | Test plan written to `acceptance.md`. |
| WR‑02 | Agent 2 (Reviewer) executes tests using Playwright, curl, existing UT/FT | Acceptance criteria verified; `report.md` generated. |
| WR‑03 | Output path: `docs/work-review/YYYY-MM-DD-<topic>/` | Files appear in correct directory. |
| WR‑04 | Trigger: “work review” / “acceptance” / “sign off” / “verify work” | Skill activates. |

#### Multi‑Model Team (`multi-model-team`)

| ID | Scenario | Expected Outcome |
|----|----------|------------------|
| MT‑01 | GLM 5.2 architect + DeepSeek v4 Pro worker orchestration | Two‑agent collaboration produces coherent output. |

#### Contrarian Review (`walter-worker-contrarian-review`)

| ID | Scenario | Expected Outcome |
|----|----------|------------------|
| CR‑01 | 5‑agent adversarial document review | All agents produce independent critiques. |
| CR‑02 | Mode 1 activation | Correct sub‑process invoked. |

### 2.5 Directory & Naming Conventions

| ID | Scenario | Expected Outcome |
|----|----------|------------------|
| NC‑01 | All own skills in `walter-worker-skills/` | Folder exists; skills inside have `walter-worker-` prefix in name field. |
| NC‑02 | Imported skills in `import-skills/` | Folder exists; skills have original names (no prefix). |
| NC‑03 | Private skills in `personal-skills/` | Folder exists; symlinked locally, gitignored, not in marketplace. |
| NC‑04 | Flat vs nested structure | Both validated; flat structure allowed. |

### 2.6 Quality Gates Enforcement

| ID | Scenario | Expected Outcome |
|----|----------|------------------|
| QG‑01 | MUST gate violation (e.g., no Anti-Patterns section) | Commit blocked. |
| QG‑02 | NICE gate violation (e.g., body >150 lines) | Warning displayed; commit allowed. |
| QG‑03 | Quality gates run before every commit (Step 6 of process) | Script executes; passes/fails reported. |

### 2.7 CI / Automation

| ID | Scenario | Expected Outcome |
|----|----------|------------------|
| CI‑01 | Push containing import without complete `META.yaml` | CI job fails. |
| CI‑02 | Push with skill missing required frontmatter fields | CI job fails. |
| CI‑03 | Push with skill that has `deploy/` concept | MUST gate fails in CI. |

---

## 3. Quality Gates / Acceptance Criteria

All skills and tools in the skill‑factory project must meet the following criteria.  
**MUST** gates block commit; **NICE** gates produce warnings.

### 3.1 Skill Content

| Gate | Type | Criteria |
|------|------|----------|
| Anti‑Patterns section present | MUST | Skill includes an `Anti‑Patterns` or `Anti-Patterns` section (or mapped section). |
| Quality Gates section with MUST / NICE | MUST | Skill contains a Quality Gates section with checkbox‑style lists. |
| Philosophy‑driven overview | NICE | Skill starts with a rationale/overview that explains the “why”. |
| No `deploy/` concept | MUST | Skill does not reference a `deploy/` directory or deployment workflow. |
| Description ≤500 chars | NICE | `description` field in frontmatter is ≤500 characters. |
| Body ≤150 lines | NICE | Body of SKILL.md (after frontmatter) is ≤150 lines. (Formerly 500; tightened.) |
| Name kebab‑case | MUST | Skill `name` field is kebab‑case (enforced by skill-edit auto‑conversion). |
| `Use when…` description start | NICE | Description begins with `"Use when..."`. |

### 3.2 Imported Skills

| Gate | Type | Criteria |
|------|------|----------|
| META.yaml complete | MUST | Contains `source`, `upstream_commit`, `license`, `imported_at`, `imported_by`, `note`. |
| Original author preserved | MUST | `source_author` and `source_url` present in metadata. |
| No prefix added | MUST | Imported skill name does not get `walter-worker-` prefix. |

### 3.3 Naming & Directory

| Gate | Type | Criteria |
|------|------|----------|
| Own skills in `walter-worker-skills/` | MUST | Skills created by the factory reside in `walter-worker-skills/`. |
| Prefix applied to own skill name | MUST | Skill name field includes `walter-worker-` prefix. |
| Import skills in `import-skills/` | MUST | Third‑party skills go to `import-skills/`. |
| Personal skills in `personal-skills/` | MUST | Private skills go to `personal-skills/` (gitignored). |
| No generic filenames | MUST | File names must include type suffix (e.g., `-decision-YYYY-MM-DD.md`). |

### 3.4 Process Steps

| Gate | Type | Criteria |
|------|------|----------|
| Phase 0 external search | MUST (for skill-create) | At least one external source consulted (GitHub ≥10 repos or web search).