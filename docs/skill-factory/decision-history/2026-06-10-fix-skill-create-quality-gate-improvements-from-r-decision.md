# Decision Record — 2026-06-10
> Project: skill-factory
> Decisions: 18

## Change Log
| Date | Change |
|------|--------|
| 2026-07-26 | Auto-generated from session analysis |

## Decisions

### 1. fix: skill-create quality gate improvements from round-01 review
- **Source**: git-commit
- **Timestamp**: 2026-06-10T23:59:31-07:00
- **Context**: git commit 33e48d2e
- **Rationale**: committed change
- **Commit**: `33e48d2e`
- **Confidence**: high

### 2. docs: round-01 agent-B evaluation — both skills PASS
- **Source**: git-commit
- **Timestamp**: 2026-06-10T23:55:57-07:00
- **Context**: git commit d9baa432
- **Rationale**: committed change
- **Commit**: `d9baa432`
- **Confidence**: high

### 3. skill: add skill-edit and skill-import from round-01 Agent-A
- **Source**: git-commit
- **Timestamp**: 2026-06-10T23:53:49-07:00
- **Context**: git commit 1d7bb7ed
- **Rationale**: committed change
- **Commit**: `1d7bb7ed`
- **Confidence**: high

### 4. chore: remove ai-worker-skills, fix skill-create description and references
- **Source**: git-commit
- **Timestamp**: 2026-06-10T23:47:31-07:00
- **Context**: git commit 8cb87bec
- **Rationale**: committed change
- **Commit**: `8cb87bec`
- **Confidence**: high

### 5. docs: implementation plan for skill-factory bootstrap
- **Source**: git-commit
- **Timestamp**: 2026-06-10T23:47:03-07:00
- **Context**: git commit 8ce5ae73
- **Rationale**: committed change
- **Commit**: `8ce5ae73`
- **Confidence**: high

### 6. docs: add skill-factory bootstrap design spec
- **Source**: git-commit
- **Timestamp**: 2026-06-10T23:43:57-07:00
- **Context**: git commit 5dcb52c7
- **Rationale**: committed change
- **Commit**: `5dcb52c7`
- **Confidence**: high

### 7. refactor: move skills into ai-coworker-skills namespace
- **Source**: git-commit
- **Timestamp**: 2026-06-10T21:14:15-07:00
- **Context**: git commit 54496dad
- **Rationale**: committed change
- **Commit**: `54496dad`
- **Confidence**: high

### 8. feat: initialize skill-factory project with skill-create
- **Source**: git-commit
- **Timestamp**: 2026-06-10T21:10:17-07:00
- **Context**: git commit 5d9747e9
- **Rationale**: committed change
- **Commit**: `5d9747e9`
- **Confidence**: high

### 9. Public open source repository
- **Source**: opencode
- **Timestamp**: 2026-06-10
- **Context**: User originally chose private local, but later changed to public open source.
- **Rationale**: To share skills with the community and enable collaboration.
- **Alternatives rejected**: Private local, Public + private hybrid
- **Confidence**: high

### 10. Directory structure: ai-worker-skills/ for own skills, import/ for imported, personal/ for private
- **Source**: opencode
- **Timestamp**: 2026-06-10
- **Context**: Need to organize skills by source and visibility.
- **Rationale**: Clear separation; personal/ is gitignored for privacy; import/ has metadata for attribution.
- **Alternatives rejected**: Flat all in one directory, Nested by author only
- **Confidence**: high

### 11. Naming convention: ai-worker-skills get prefix 'ai-worker-', imports keep original name
- **Source**: opencode
- **Timestamp**: 2026-06-10
- **Context**: User wanted brand recognition for own skills and clarity.
- **Rationale**: Easy to identify sources in tool UI; imports preserve upstream identity.
- **Alternatives rejected**: Same prefix for all, No prefix
- **Confidence**: high

### 12. Use Claude Code local marketplace via extraKnownMarketplaces
- **Source**: opencode
- **Timestamp**: 2026-06-10
- **Context**: Need a standard way to install skills.
- **Rationale**: Native support; no extra scripts for Claude; OpenCode uses separate symlink approach.
- **Alternatives rejected**: Symlink-only, Custom install script for each tool
- **Confidence**: high

### 13. skill-import skill behavior: fetch, extract, write metadata, register in marketplace
- **Source**: opencode
- **Timestamp**: 2026-06-10
- **Context**: Automate import of third-party skills with proper attribution.
- **Rationale**: Ensure license compliance and traceability; reusable workflow.
- **Alternatives rejected**: Manual copy-paste, Script without interactive prompts
- **Confidence**: high

### 14. META.yaml schema with source, upstream_commit, license, imported_at, imported_by, note
- **Source**: opencode
- **Timestamp**: 2026-06-10
- **Context**: Need structured metadata for each import for compliance.
- **Rationale**: Standard format; easy to validate in CI; human-readable.
- **Alternatives rejected**: Only README note, JSON schema
- **Confidence**: high

### 15. CI workflow to validate import metadata completeness
- **Source**: opencode
- **Timestamp**: 2026-06-10
- **Context**: Ensure all imports meet attribution requirements.
- **Rationale**: Automated enforcement; prevent incomplete contributions.
- **Alternatives rejected**: Manual review only
- **Confidence**: high

### 16. Test flat vs nested SKILL.md structure
- **Source**: opencode
- **Timestamp**: 2026-06-10
- **Context**: User questioned deep nesting (skills/<name>/SKILL.md).
- **Rationale**: Validate compatibility with Claude Code marketplace; both passed, so may adopt flat structure for simplicity.
- **Alternatives rejected**: Assuming nested required
- **Confidence**: medium

### 17. OpenCode installation: git plugin + project-level symlink
- **Source**: opencode
- **Timestamp**: 2026-06-10
- **Context**: OpenCode does not support marketplace natively.
- **Rationale**: Git plugin offers easy sharing; symlink for per-project control.
- **Alternatives rejected**: Only symlink, Only git plugin
- **Confidence**: high

### 18. Personal skills symlinked directly, gitignored, not in marketplace
- **Source**: opencode
- **Timestamp**: 2026-06-10
- **Context**: User wants private skills not exposed in public repo.
- **Rationale**: Privacy; simplifies git management; still usable via symlink.
- **Alternatives rejected**: Encrypted storage in repo, Separate private repo
- **Confidence**: high
