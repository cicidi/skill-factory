# Changelog

## 2026-06-24 — Contrarian Review & Skill-Factory Overhaul

### Repo Sync & Structure
- Backported 9 skills from deployed copy to source repo (auto-tdd, bug-hunt, bug-report, contrarian-review, doc-merge, english-grammar-fix, self-analyze, self-heal, doc-protect)
- Removed 5 old duplicate skills with deprecated `ai-coworker-` prefix naming
- Cleaned orphaned `session-memory/` directory (had only `.pyc` cache, no SKILL.md)
- Updated CONVENTIONS.md: removed `ai-coworker-` prefix requirement, added source-repo-vs-deployed-copy documentation

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

### CLAUDE.md (ai-coworker)
- Fixed broken references to non-existent `templates/team-common/` paths
