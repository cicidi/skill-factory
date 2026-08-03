# skill-factory Implementation Plan

## Change Log

| Version | Date | Description |
|---------|------|-------------|
| 0.1 | 2026-06-10 | Initial project bootstrap with skill-create foundation |
| 0.2 | 2026-06-11 | Core skills (skill-edit, skill-import) and quality infrastructure |
| 0.3 | 2026-06-11 | Directory restructure, naming conventions, first imports |
| 0.4 | 2026-06-12 | Adversarial review skills (devil-advocate, work-review) |
| 0.5 | 2026-06-18 | Contrarian-review and multi-agent frameworks |
| 0.6 | 2026-06-23 | Skill consolidation, cleanup, and mega-migration |
| 0.7 | 2026-07-01 | Specialized productivity skills (tmux, multi-model) |
| 0.8 | 2026-07-14 | Document organization and knowledge management |
| 0.9 | 2026-07-18 | Media processing skills (YouTube, OCR, transcription) |
| 1.0 | 2026-07-22 | Pipeline skills (video workflow, event scouting) |

## Milestones & Phases

---

### Phase 1: Project Bootstrap & Foundation (2026-06-10)

**Objective:** Establish the project structure, configuration, and core skill creation mechanism.

#### Key Deliverables
- `opencode` configuration with `variant: thinking-high` for build agent
- Three‑directory structure: `walter-worker-skills/`, `import-skills/`, `personal-skills/`
- Naming convention: `walter-worker-` prefix for own skills, no prefix for imports
- `CONVENTIONS.md` updated to allow name ≠ folder name
- `CLAUDE.md` with 1–3 clarifying questions rule (except ≥90% confidence)
- Initial `skill-create` module as bootstrap skill

#### Dependencies & Build Order
1. Define project conventions (CONVENTIONS.md, CLAUDE.md) – prerequisite for any skill
2. Configure `opencode` (thinking‑high variant) – prerequisite for agent operations
3. Build `skill-create` as the first skill (self‑bootstrapping)
4. Create directory structure and set gitignore for `personal-skills/`

#### Key Commits
- `5d9747e9` — feat: initialize skill-factory project with skill-create
- `54496dad` — refactor: move skills into walter-worker-skills namespace
- `5dcb52c7` — docs: add skill-factory bootstrap design spec
- `8ce5ae73` — docs: implementation plan for skill-factory bootstrap
- `8cb87bec` — chore: remove ai-worker-skills, fix skill-create description and references

---

### Phase 2: Core Editing & Import Infrastructure (2026-06-10 – 2026-06-11)

**Objective:** Build the skills needed to edit existing skills and import third‑party skills.

#### Key Deliverables
- `skill-edit` skill: follows `skill-create` process exactly; accepts requirements as interview answers; uses targeted edits only; enforces quality gates before commit; redirects to `skill-create` if ≥80% rewrite
- `skill-import` skill: fetches source SKILL.md via webfetch/curl; auto‑converts frontmatter to opencode 5‑field format; auto‑adapts body sections; implements ambiguity triggers (one question at a time); stores imported skills in `import-skills/`; preserves `metadata.source_author` and `source_url`
- Quality gates for both skills (MUST/NICE checklists, anti‑patterns, line count <150)

#### Dependencies
- `skill-edit` depends on `skill-create` process definition and CONVENTIONS.md
- `skill-import` depends on frontmatter mapping rules and directory structure
- Both depend on quality gate framework from Phase 1

#### Build Order
1. Implement `skill-import` (needs metadata schema first)
2. Implement `skill-edit` (requires target skill existence check)
3. Validate both skills against quality gates (must pass MUSTs)

#### Key Commits
- `1d7bb7ed` — skill: add skill-edit and skill-import from round-01 Agent-A
- `d9baa432` — docs: round-01 agent-B evaluation — both skills PASS
- `33e48d2e` — fix: skill-create quality gate improvements from round-01 review
- `773594b9` — fix(skill-import): add author preservation, import/ subdirectory, and anti-pattern for lost authorship

---

### Phase 3: First Import & Quality Refinements (2026-06-11)

**Objective:** Validate the import pipeline with a real‑world skill and tighten quality rules.

#### Key Deliverables
- Import TDD skill from `mattpocock/skills` into `import-skills/`
- Optimize imported skill to meet project conventions (description, overview, line count)
- Upgrade `skill-create` quality gates: add anti‑patterns section, MUST/NICE checkboxes, philosophy‑driven overview, `deploy/` prohibition, description ≤500 chars, body line limit tightened to <150
- META.yaml schema defined for imports: `source`, `upstream_commit`, `license`, `imported_at`, `imported_by`, `note`
- CI workflow for import metadata validation

#### Dependencies
- Import depends on `skill-import` being functional and META.yaml schema defined
- Quality gate improvements depend on CONVENTIONS.md

#### Key Commits
- `eed365ce` — skill: import tdd from mattpocock/skills
- `d98ed8d3` — fix(tdd): optimize description and overview per skill-factory conventions
- `3c058b5e` — docs: final verification logs and bootstrap summary
- `d30f01c0` — feat(skill-create): Phase 0 multi-source search — GitHub (>=10 repos), web search, import-vs-inspire decision
- `a2e47245` — refactor: three-directory structure with walter-worker- prefix naming

---

### Phase 4: Skill Migration & Bulk Addition (2026-06-11)

**Objective:** Seed the project with a set of coworker skills.

#### Key Deliverables
- Migrate 5 skills from previous `walter-worker` set using `skill-edit` / `skill-import` process
- Ensure all skills conform to naming convention and quality gates

#### Dependencies
- Requires Phase 3 skill‑create improvements for validation

#### Key Commits
- `a5dcc4e9` — skill: add 5 migrated coworker skills

---

### Phase 5: Adversarial Review Skills (2026-06-11 – 2026-06-18)

**Objective:** Build multi‑agent skills for design review and work acceptance.

#### Key Deliverables
- `walter-worker-devil-advocate`: 3‑agent architecture (con, pro, judge); max 5 rounds with majority vote; output `discussion.md` + `report.md` to `docs/devil-advocate/`; triggers: `review spec`, `杠精`, `devil advocate`, `adversarial review`
- `walter-worker-work-review`: 2‑agent (Collector → Reviewer); Collector writes test plan; Reviewer executes tests (existing UT/FT, Playwright for E2E, curl for manual); output `acceptance.md` + `report.md` to `docs/work-review/`; triggers: `work review`, `acceptance`, `sign off`, `verify work`
- `walter-worker-contrarian-review`: 5‑agent adversarial document review

#### Dependencies
- Both skills depend on agent orchestration patterns established in skill-create
- Output directory conventions must be consistent (docs/<skill-name>/)

#### Build Order
1. `devil-advocate` (simpler 3‑agent)
2. `work-review` (2‑agent)
3. `contrarian-review` (5‑agent, built later)

#### Key Commits
- `70ccdc4a` — skill: add walter-worker-devil-advocate — multi-agent adversarial review for specs and design docs
- `01f533c9` — skill: add walter-worker-work-review — 2-agent gatekeeper for work acceptance sign-off
- `3a54ffc6` — skill: add walter-worker-contrarian-review — 5-agent adversarial document review

---

### Phase 6: Skill Consolidation & Mega‑Migration (2026-06-23)

**Objective:** Restructure repository to scale: rename, move, deduplicate, and clean up skills.

#### Key Deliverables
- Rename all 21 walter-worker skills to simplified naming (e.g., `self-patch` → `english-grammar-fix`)
- Remove deprecated skills (`initiative-create`, `initiative-edit`, `session-memory`, `gate-*`, `flow-*`, `connect-*`, `doc-review`, `bug-sleuth`, `bug-create`)
- Add new skills: `auto-tdd`, `session-memory`, `initiative-create/edit` (later moved out)
- Add self‑heal / self‑analyze skills
- Remove `docs/superpowers` from tracking
- Contrarian‑review overhaul: source repo enforcement, naming cleanup, tests, docs

#### Dependencies
- Rename must preserve internal `name` fields consistently
- Removal must respect skill interdependencies

#### Key Commits
- `7bfe010f` — feat: add auto-tdd, session-memory, initiative-create/edit skills; add contrarian-review Mode 1
- `add4f31e` — chore: remove docs/superpowers from tracking, add to gitignore
- `3395648c` — refactor: rename skills to simplified naming, migrate 21 AI coworker skills
- `4d02f4cd` — chore: remove initiative-create/edit (moved to walter-worker)
- `fca74392` — chore: remove session-memory (moved to walter-worker)
- `dce0d79c` — feat: add self-heal and self-analyze skills
- `887a719b` — chore: remove self-init (walter-worker skills/init/ is more current)
- `82c4563a` — chore: remove gate-* skills (not in walter-worker scope)
- `1b48039a` — chore: remove skills deleted from walter-worker (flow-*, connect-*, doc-review, bug-sleuth, bug-create)
- `7226d537` — refactor: rename self-patch to english-grammar-fix
- `c329159c` — fix: add english-grammar-fix (was untracked)
- `06a4e020` — chore: remove self-strain
- `bd9bb024` — chore: remove self-heal/self-analyze from personal-skills (in walter-worker-skills)
- `559834af` — chore: contrarian review overhaul — source repo enforcement, naming cleanup, tests, docs
- `cca25cd5` — fix: re-apply skill fixes lost during rebase (frontmatter + sections)
- `bc4d6cc0` — fix: remove walter-worker- prefix from 4 skill frontmatter names

---

### Phase 7: Specialized Productivity Skills (2026-07-01 – 2026-07-14)

**Objective:** Expand beyond core workflow with domain‑specific skills.

#### Key Deliverables
- `tmux-status-bar`: tmux bar with project, git, and initiative context
- `multi-model-team`: GLM 5.2 architect + DeepSeek v4 Pro worker orchestration
- `doc-organize`: 9 doc types, 