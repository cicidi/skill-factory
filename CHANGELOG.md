# Changelog

## 2026-08-02 — Documentation Sync & README Refresh

### README
- Synced skill tables with actual directories — 14 factory-native, 9 personal, 7 imported (30 total)
- Replaced stale skill entries with current skills
- Updated imported skills from single `tdd` entry to all 7 mattpocock skills
- Added project banner image (`pic/the-super-lab.png`)

### Docs Reorganization
- Moved `docs/specs/devil-advocate-design.md` → `docs/skill-factory/design/devil-advocate-design.md`
- Moved `docs/specs/work-review-design.md` → `docs/skill-factory/design/work-review-design.md`
- Renamed `docs/spec-driven-development/plan/` → `docs/spec-driven-development/impl-plan/`
- Removed orphaned `docs/specs/` directory, `docs/skill-factory/raw/` JSON data, `docs/skill-factory/spec/*.html` artifact
- Removed empty directories (`docs/spec-driven-development/prd/`, `docs/superpowers/specs/`, `docs/superpowers/`)
- Cleaned up `.gitignore` (removed `docs/superpowers/` entry)

### INDEX.md
- Regenerated from actual file tree with correct filenames and headings

## 2026-06-24 — Contrarian Review & Skill-Factory Overhaul

### Repo Sync & Structure
- Backported 9 skills from deployed copy to source repo (auto-tdd, bug-hunt, bug-report, contrarian-review, doc-merge, english-grammar-fix, self-analyze, self-heal, doc-protect)
- Removed 5 old duplicate skills with deprecated `walter-worker-` prefix naming
- Cleaned orphaned `session-memory/` directory (had only `.pyc` cache, no SKILL.md)
- Updated CONVENTIONS.md: removed `walter-worker-` prefix requirement, added source-repo-vs-deployed-copy documentation

### Skill Workflow Fixes
- **skill-create**: Added source repo detection + enforcement, Phase 0 duplicate name check, Phase 5 deploy step, removed prefix naming requirement
- **skill-edit**: Added source repo enforcement, Step 8 deploy step, rename duplicate check
- Skills now follow: source repo → git push → deployed copy → IDE configs (not direct editing of deployed copies)

### Skill Fixes
- **self-analyze**: Added missing license, compatibility, metadata frontmatter; added When to Use/When NOT to Use sections
- **self-heal**: Added missing license, compatibility, metadata frontmatter; added When to Use/When NOT to Use sections
- **bug-hunt**: Added When to Use/When NOT to Use sections
- **english-grammar-fix**: Added When to Use/When NOT to Use sections, added Process section, fixed triggers

### Tests
- Added `tests/test_skills.sh` — comprehensive bash validator (69 checks: frontmatter, sections, prohibited patterns, duplicates, naming consistency)
- All skills pass validation: 69 PASS, 0 FAIL

### Documentation
- Updated README with full skill catalog (15 skills across 3 directories)
- Added workflow documentation (source repo → deploy)
- Added testing instructions

### CLAUDE.md (walter-worker)
- Fixed broken references to non-existent `templates/team-common/` paths
