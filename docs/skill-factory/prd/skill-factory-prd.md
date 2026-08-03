## Change Log
| Date | Change |
|------|--------|
| 2026-07-26 | Auto-generated from 126 session decisions |


# skill-factory PRD

**Change Log**

| Version | Date       | Author | Description |
|---------|------------|--------|-------------|
| 1.0     | 2026-07-24 | Team   | Initial PRD – based on 126 decisions covering skill creation/management/import workflows |

---

## 1. Overview

skill-factory is a curated, framework-agnostic collection of AI agent skills, each packaged as a self-contained directory with a `SKILL.md` file. It is designed to be **opencode-native** – any SKILL.md-aware agent can copy, fork, or move a skill between projects without modification. The project serves:

- **AI agent developers** who want to create, edit, and share reusable capabilities.
- **End users** of AI assistants (e.g., Claude, opencode) who wish to extend agent behavior with proven, community-vetted skills.
- **Maintainers** who oversee skill quality, consistency, and version control.

The project has grown organically through 126 documented decisions, covering everything from skill creation workflows to import policies for external contributions. This PRD formalises the requirements for the platform itself.

## 2. Goals & Success Metrics

| Goal | Success Metric |
|------|----------------|
| **Increase skill quantity** | 50+ production-ready skills within 6 months of PRD acceptance |
| **Maintain quality bar** | <5% rejection rate on pull requests due to format violations |
| **Lower creation friction** | Average time to first skill creation by a new contributor < 30 min |
| **Adoption** | 20+ active forks / clones per month (external projects using skills) |
| **Self‑healing** | 80% of user corrections to skill output automatically trigger pattern injection into `CLAUDE.md` |
| **Reusability** | 100% of skills contain no hard‑coded absolute paths; all config stored in `~/.person_info.md` or environment variables |

## 3. User Stories / Use Cases

- **As a skill author**, I want to scaffold a new skill using a guided 5‑phase workflow (`skill-create`) so that I produce a SKILL.md that follows the schema, includes examples, and deploys to the correct source repository.
- **As a skill maintainer**, I want to edit an existing skill (`skill-edit`) with safety checks (source repo enforcement) and automatic deployment so that changes are version‑controlled and traceable.
- **As an external contributor**, I want to import a SKILL.md from another project into the factory (`skill-import`) while preserving original authorship and metadata.
- **As an agent operator**, I want to apply a skill to my current project simply by copying the directory, without worrying about dependency resolution or runtime environment.
- **As a quality engineer**, I want to run automated tests (e.g., `auto-tdd`, `bug-hunt`) against skills to verify correctness before promotion.
- **As a documentation curator**, I want the factory to automatically generate an `INDEX.md` with summaries and content type columns for all published skills.
- **As a power user**, I want to aggregate decision logs and correction traces (`self-heal`, `self-analyze`) to continuously improve skill behaviour.

## 4. Functional Requirements

### 4.1 Skill Lifecycle

| ID   | Requirement | Priority | Notes |
|------|-------------|----------|-------|
| F1   | **Create** – The system shall provide a `skill-create` workflow with 5 phases: (1) idea validation, (2) spec drafting, (3) precision & examples (including legal‑clause bounds), (4) implementation, (5) deployment + source repo enforcement. | P0 | Implemented; must remain stable. |
| F2   | **Edit** – The system shall provide a `skill-edit` workflow that validates the skill directory exists in the source repository before allowing modifications, then deploys changes automatically. | P0 | Prevents drift. |
| F3   | **Import** – The system shall allow importing a SKILL.md from any external project while preserving original authorship, commit history, and license. | P1 | Must handle merge conflicts gracefully. |
| F4   | **Delete / Archive** – The system shall support removal of a skill with a deprecation notice and optional move to an `archived/` folder. | P2 | Not yet implemented. |

### 4.2 Skill Metadata & Structure

| ID   | Requirement | Priority |
|------|-------------|----------|
| F5   | Every skill must contain a `SKILL.md` file with a defined schema (phases, input/output, examples, change log). | P0 |
| F6   | Skill directories must follow a naming convention: no generic names, include type suffix (e.g., `-skill`, `-pipeline`). | P1 |
| F7   | Configuration files (e.g., API keys, personal info) must be stored in `~/.person_info.md` or environment variables, never inside the skill directory. | P0 |
| F8   | State files must be dated, append not overwrite, and include one of 10 allowed state types. | P1 |

### 4.3 Quality Assurance

| ID   | Requirement | Priority |
|------|-------------|----------|
| F9   | The factory must include a suite of test skills (e.g., `auto-tdd`, `bug-hunt`) that other skills can invoke for continuous testing. | P1 |
| F10  | The factory must track user corrections via `self-heal` (writing to traces) and `self-analyze` (injecting patterns into `CLAUDE.md`). | P1 |
| F11  | All skills must pass a format validator (e.g., `SKILL.md` lint, required sections, no broken relative links) before merge. | P0 |

### 4.4 Documentation & Navigation

| ID   | Requirement | Priority |
|------|-------------|----------|
| F12  | An `INDEX.md` shall be auto‑generated listing all skills with description, type, and content summary column. | P1 |
| F13  | The project README must include a “How to Contribute” section referencing `skill-create` and `skill-import`. | P0 |
| F14  | A decision log (`DECISIONS.md` or similar) shall be maintained with all 126+ historical decisions for traceability. | P1 |

### 4.5 Automation & CI/CD

| ID   | Requirement | Priority |
|------|-------------|----------|
| F15  | On every pull request, run a pipeline that validates SKILL.md structure, checks for forbidden patterns (absolute paths, missing type suffix), and runs a quick smoke test against a sandbox agent. | P1 |
| F16  | Deploy changes to the main branch only after successful validation and approval. | P0 |

## 5. Non-Functional Requirements

| ID   | Requirement | Target / Constraint |
|------|-------------|---------------------|
| N1   **Portability** | Skills must be self-contained; no runtime dependencies beyond a SKILL.md‑aware agent. | 100% of skills pass “copy, fork, move” test. |
| N2   **Security** | Imported skills must be scanned for malicious patterns (e.g., command injection, environment variable theft). | Scan before merge. |
| N3   **Scalability** | The factory should support up to 500 skills without degradation of `INDEX.md` generation time. | < 1 sec per regeneration. |
| N4   **Maintainability** | All skill creation/editing workflows must be themselves implemented as skills in the factory (e.g., `skill-create` is a skill). | Yes – ensures self‑consistency. |
| N5   **Backward Compatibility** | Skills created under a previous schema version must continue to work; schema migrations must be documented. | Provide a `VERSION.md` per skill if needed. |
| N6   **Documentation** | Every skill must include a `CHANGELOG.md` (or section in SKILL.md) and a meaningful description. | Mandatory. |

## 6. Out of Scope

- **Defining the full set of skills** – The PRD covers the platform, not the content of individual skills. Existing skills (e.g., `youtube‑research‑pipeline`, `luma-event-scout`) are examples, not requirements.
- **Building a runtime agent** – skill-factory does not ship its own AI agent; it relies on external SKILL.md‑aware agents (e.g., Claude via opencode).
- **Skill marketplace or registry** – No centralised discovery beyond the factory’s own directory; no monetisation or licensing enforcement.
- **Runtime dependency management** – Skills may assume certain tools (e.g., Playwright, Whisper), but the factory does not manage installation.
- **Hosting a skill execution sandbox** – The factory is a static collection; it does not provide a cloud execution environment.
- **Multi‑language support** – All skills are currently English‑only; internationalisation is deferred.
- **Formal verification of skill correctness** – Quality relies on testing skills (`auto-tdd`, `bug-hunt`) but not external theorem proving.