# Decision Record — unknown
> Project: skill-factory
> Decisions: 47

## Change Log
| Date | Change |
|------|--------|
| 2026-07-26 | Auto-generated from session analysis |

## Decisions

### 1. Add 'variant': 'thinking-high' to the build agent in opencode config
- **Source**: opencode
- **Context**: User requested to change thinking effort
- **Rationale**: Thinking effort is controlled via variant field; existing config had no variant for build agent, so added thinking-high variant
- **Confidence**: high

### 2. 重建三个平级的 skill 目录：ai-coworker-skills、import-skills、personal-skills
- **Source**: opencode
- **Context**: 原仓库结构混乱，用户明确要求三个独立目录存放不同来源的技能
- **Rationale**: 分离原生、导入和个人技能，便于管理和前缀规则实施
- **Alternatives rejected**: 原先的 ai-coworker-skills/import/ 子目录
- **Confidence**: high

### 3. ai-coworker-skills 和 personal-skills 下的 skill 在 name 字段加 ai-coworker- 前缀，文件夹名不改；import-skills 不加前缀；修
- **Source**: opencode
- **Context**: 用户要求所有自身技能显示前缀，但文件夹保持原名
- **Rationale**: 满足显示需求同时避免大量文件夹重命名操作
- **Alternatives rejected**: 文件夹也重命名, 仅在安装后修改显示名
- **Confidence**: high

### 4. 在 skill-create 的 Phase 0 增加 GitHub 搜索（≥10 repo）和 Web 搜索，并提供 import/吸收灵感/自建三种决策分支
- **Source**: opencode
- **Context**: 用户希望 skill-create 能从外部获取启发，支持复用或借鉴
- **Rationale**: 增强技能创建时的外部参考能力，提升创建质量
- **Alternatives rejected**: 仅限本地扫描
- **Confidence**: high

### 5. 在 ~/.claude/CLAUDE.md 添加规则：每次请求至少问1-3个 clarify 问题，除非置信度≥90%
- **Source**: opencode
- **Context**: 用户要求在所有任务中强制澄清需求
- **Rationale**: 减少误解，提高需求准确性；90%阈值避免过度打扰
- **Alternatives rejected**: 总是提问不设阈值
- **Confidence**: high

### 6. 为 skill-import 增加 metadata.source_author 和 metadata.source_url 字段，并在 Quality Gates 中验证
- **Source**: opencode
- **Context**: 导入外部 skill 时需要保留原作者信息
- **Rationale**: 保证知识溯源，符合 open-source 规范
- **Alternatives rejected**: 不记录来源
- **Confidence**: high

### 7. 导入的 skill 放入独立的 import-skills/ 目录，而非 ai-coworker-skills/import/
- **Source**: opencode
- **Context**: 用户明确要求三个平级目录，导入 skill 不应混合在工厂原生目录内
- **Rationale**: 保持目录职责清晰，避免混淆
- **Alternatives rejected**: ai-coworker-skills/import/ 子目录
- **Confidence**: high

### 8. 保留并修复 skill-create 作为自举起点，而非从头重建
- **Source**: opencode
- **Context**: skill-create 是创建其他技能的入口工具，需要先修复问题再使用
- **Rationale**: 确保自举系统正确运行，避免重复工作
- **Alternatives rejected**: 删除 skill-create 从零开始
- **Confidence**: high

### 9. Follow exact skill-create process phases (0->1->2->3->4) for skill-edit creation
- **Source**: opencode
- **Context**: User instructed to follow skill-create process exactly
- **Rationale**: Ensures consistency and quality enforcement across all skills
- **Confidence**: high

### 10. Use provided requirements as user answers during interview (Phase 1)
- **Source**: opencode
- **Context**: User role simulated answers based on requirements
- **Rationale**: Simulate realistic interview without actual human interaction
- **Alternatives rejected**: Real-time human interview
- **Confidence**: medium

### 11. Accept default factor weights (Accuracy 0.4, Edge cases 0.3, Readability 0.15, Speed 0.1, Tool integ
- **Source**: opencode
- **Context**: AI asked if user accepts defaults; user answered yes
- **Rationale**: No need to customize
- **Alternatives rejected**: Custom weights
- **Confidence**: high

### 12. Build SKILL.md following opencode 5-field frontmatter format and CONVENTIONS.md body structure with 
- **Source**: opencode
- **Context**: Phase 2 requirement
- **Rationale**: Adhere to project conventions
- **Alternatives rejected**: Different format or longer document
- **Confidence**: high

### 13. Include anti-patterns section in SKILL.md
- **Source**: opencode
- **Context**: Phase 2, instruction to include anti-patterns section, philosophy-driven approach
- **Rationale**: Prevent common mistakes
- **Confidence**: high

### 14. Include quality gates section that blocks if violated (MUST gates)
- **Source**: opencode
- **Context**: Phase 2, required by skill-create process
- **Rationale**: Enforce quality
- **Confidence**: high

### 15. Present diff summary and get user approval before editing (Step 4)
- **Source**: opencode
- **Context**: Workflow requirement
- **Rationale**: Ensure user consent and review
- **Alternatives rejected**: Editing without approval
- **Confidence**: high

### 16. Use Edit tool for targeted changes, never Write on entire file, never create new file
- **Source**: opencode
- **Context**: Step 5 of process
- **Rationale**: Prevent overwriting or creating new files (skill-create's job)
- **Alternatives rejected**: Using Write tool
- **Confidence**: high

### 17. Run quality gates before commit; MUST gates block publish
- **Source**: opencode
- **Context**: Step 6 and Step 7
- **Rationale**: Ensure quality
- **Alternatives rejected**: Committing without verification
- **Confidence**: high

### 18. Use conventional commit message format: skill(<name>): <imperative verb> <description>
- **Source**: opencode
- **Context**: Publish step
- **Rationale**: Standard for project
- **Confidence**: high

### 19. Output only final SKILL.md content at end, not actually create files or commit
- **Source**: opencode
- **Context**: Instructions at end
- **Rationale**: Avoid side effects in simulation
- **Alternatives rejected**: Actually writing to files
- **Confidence**: high

### 20. Redirect to skill-create if target skill doesn't exist or change is ≥80% rewrite
- **Source**: opencode
- **Context**: Process Step 1 and Step 3
- **Rationale**: Scope boundary
- **Alternatives rejected**: Attempting to edit non-existent skill or full rewrite
- **Confidence**: high

### 21. Skip interview phase and go directly to build with pre-specified requirements
- **Source**: opencode
- **Context**: User instructed to skip Phase 1 interview and proceed to Phase 2 build using provided requirements.
- **Rationale**: Requirements were complete, no need for elicitation.
- **Alternatives rejected**: Conducting the interview phase to gather more details
- **Confidence**: high

### 22. Use webfetch (preferred) or curl to fetch source SKILL.md
- **Source**: opencode
- **Context**: Workflow step 2: fetch source content.
- **Rationale**: webfetch is more integrated; curl is fallback.
- **Alternatives rejected**: Using only one tool, Manual copy-paste
- **Confidence**: high

### 23. Auto-convert frontmatter: map name to kebab-case, rewrite description to start with 'Use when...', d
- **Source**: opencode
- **Context**: Frontmatter mapping required by requirements.
- **Rationale**: Standardize all skills to opencode 5-field format with consistent defaults.
- **Alternatives rejected**: Keeping original description verbatim, Asking user for all fields
- **Confidence**: high

### 24. Auto-adapt body sections: map Philosophy→overview, Anti-Pattern→Anti-Patterns, Workflow→Process, Che
- **Source**: opencode
- **Context**: Body section mapping required to match CONVENTIONS.md structure.
- **Rationale**: All imported skills must follow the same structure for consistency and AI readability.
- **Alternatives rejected**: Keeping source section names, Adding more mappings without user input
- **Confidence**: high

### 25. Implement Ambiguity Triggers: ask user one question at a time only when mapping is ambiguous (no lic
- **Source**: opencode
- **Context**: User requirement: ask ONE QUESTION AT A TIME only when ambiguous.
- **Rationale**: Minimize interruptions while ensuring correctness for edge cases.
- **Alternatives rejected**: Ask user to fill all gaps upfront, Silently guess all values
- **Confidence**: high

### 26. Define Quality Gates as MUST (block commit) and NICE (warn only) checklists
- **Source**: opencode
- **Context**: Quality section required by build instructions.
- **Rationale**: Ensure accuracy and compliance; separate blocking from non-blocking checks.
- **Alternatives rejected**: Single list of all checks, No quality gates
- **Confidence**: high

### 27. Include Anti-Patterns section with four specific anti-patterns
- **Source**: opencode
- **Context**: Required by build instructions to have anti-patterns section.
- **Rationale**: Prevent common mistakes during import (silent conversion, verbatim copy, skipped audit, write to existing dir).
- **Alternatives rejected**: Generic anti-patterns, Omit section
- **Confidence**: high

### 28. Target <150 lines but accept 186 lines due to required content (conversion table, gates, anti-patter
- **Source**: opencode
- **Context**: User requirement 'Target < 150 lines'; output ended at 186.
- **Rationale**: Content completeness prioritized over strict line count; line count is soft target.
- **Alternatives rejected**: Cutting required sections to meet line target
- **Confidence**: medium

### 29. Tighten NICE gate 'Body < 500 lines' to '< 150 lines' in skill-create
- **Source**: opencode
- **Context**: Diagnosis of skill-create revealed the body line limit was too loose per CONVENTIONS.md requirement.
- **Rationale**: CONVENTIONS.md specifies body should be under 150 lines; the existing 500-line limit would allow overly long skills.
- **Alternatives rejected**: Keeping the limit at 500 lines
- **Confidence**: high

### 30. Add 'Anti-Patterns section present' as NICE gate in skill-create
- **Source**: opencode
- **Context**: skill-create lacked a requirement for an Anti-Patterns section, though downstream skills need it.
- **Rationale**: Ensures generated skills include anti-patterns, aligning with CONVENTIONS.md.
- **Confidence**: high

### 31. Add 'Quality Gates section with MUST/NICE checkboxes' as NICE gate in skill-create
- **Source**: opencode
- **Context**: skill-create did not require a Quality Gates section in generated skills.
- **Rationale**: Makes quality criteria explicit and traceable, improving skill consistency.
- **Confidence**: high

### 32. Add 'Philosophy-driven overview' as NICE requirement in skill-create Phase 2
- **Source**: opencode
- **Context**: Phase 2 instructions in skill-create were missing guidance to include a philosophy-driven overview.
- **Rationale**: Philosophical framing improves skill cohesion and user understanding.
- **Confidence**: medium

### 33. Add 'No deploy/ concept' prohibition as MUST gate in skill-create
- **Source**: opencode
- **Context**: CONVENTIONS.md prohibits deploy/ concept, but skill-create didn't check for it.
- **Rationale**: Prevents invalid skill structures from being created.
- **Confidence**: high

### 34. Add 'description ≤ 500 chars' as NICE gate in skill-create
- **Source**: opencode
- **Context**: CONVENTIONS.md recommends description length ≤500 characters, but skill-create didn't enforce it.
- **Rationale**: Keeps descriptions succinct and readable.
- **Confidence**: high

### 35. Accept Agent-B's assessment that skill-edit and skill-import have zero MUST violations
- **Source**: opencode
- **Context**: Double-checked both skills against CONVENTIONS.md and found no issues.
- **Rationale**: Both skills pass all quality gates; no additional issues found.
- **Confidence**: high

### 36. Commit changes to skill-create and report with specific commit message
- **Source**: opencode
- **Context**: Changes required version control tracking.
- **Rationale**: Follow standard development workflow for traceability.
- **Confidence**: high

### 37. Use main agent orchestration with stateless subagents for each round (con, pro, judge) in devil-advo
- **Source**: opencode
- **Context**: During brainstorming for devil-advocate skill.
- **Rationale**: Clear state management, debuggable, follows project's existing pattern (Agent-A/B/C bootstrap).
- **Alternatives rejected**: Persistent sessions with task_id for cross-round memory (Scheme B) - risk of state drift and debugging difficulty.
- **Confidence**: high

### 38. Change output path for devil-advocate from project default to {project-path}/docs/devil-advocate/YYY
- **Source**: opencode
- **Context**: User requested a specific location (docs/devil-advocate) instead of docs/superpowers/devil-advocate.
- **Rationale**: Direct user request.
- **Alternatives rejected**: Staying at docs/superpowers/
- **Confidence**: high

### 39. Create two output files for devil-advocate: discussion.md (full debate) and report.md (summary).
- **Source**: opencode
- **Context**: User asked '有没有discussion.md' (is there a discussion.md?).
- **Rationale**: Separate raw debate from human-readable summary.
- **Alternatives rejected**: Single report.md containing everything.
- **Confidence**: high

### 40. Limit debate to max 5 rounds, then fall back to 3-agent majority vote on unresolved points.
- **Source**: opencode
- **Context**: Part of devil-advocate process design.
- **Rationale**: Prevent infinite loops; voting provides tie-breaker.
- **Alternatives rejected**: No limit or different round count.
- **Confidence**: high

### 41. Use triggers 'review spec', '杠精', 'devil advocate', 'adversarial review' for devil-advocate skill.
- **Source**: opencode
- **Context**: Defining skill activation.
- **Rationale**: Match user's intended use cases.
- **Alternatives rejected**: Single trigger only.
- **Confidence**: medium

### 42. Use sequential two-agent architecture (Collector then Reviewer) without auto-retry for work-review s
- **Source**: opencode
- **Context**: During work-review brainstorming.
- **Rationale**: Simple, clear separation of concerns; user manually re-triggers after fixes.
- **Alternatives rejected**: Cyclic review with automatic re-check (Scheme B) - risk of infinite loop and skill responsibility creep.
- **Confidence**: high

### 43. Agent 1 (Collector) writes a test plan (scenarios, types, steps) but no executable test code.
- **Source**: opencode
- **Context**: User corrected that Agent 1 should not write test code, only test plan.
- **Rationale**: Keep Agent 1's role limited to analysis and specification; Agent 2 executes.
- **Alternatives rejected**: Agent 1 writing actual test scripts.
- **Confidence**: high

### 44. Agent 2 (Reviewer) executes the test plan by running existing UT/FT, writing Playwright for E2E, and
- **Source**: opencode
- **Context**: User specified that Agent 2 should actually run tests, possibly write code, and use Playwright/dev's tests.
- **Rationale**: Agent 2 validates each acceptance criterion through real execution.
- **Alternatives rejected**: Agent 2 only analyzing code without running tests.
- **Confidence**: high

### 45. Output for work-review goes to {project-path}/docs/work-review/YYYY-MM-DD-<topic>/ with acceptance.m
- **Source**: opencode
- **Context**: During work-review output structure design.
- **Rationale**: Consistent with devil-advocate pattern, easy to find.
- **Alternatives rejected**: Output to default skill directory.
- **Confidence**: high

### 46. Use triggers 'work review', 'acceptance', 'sign off', 'verify work' for work-review skill.
- **Source**: opencode
- **Context**: Defining skill activation.
- **Rationale**: Aligns with typical developer terminology.
- **Alternatives rejected**: Single or different triggers.
- **Confidence**: medium

### 47. Compress SKILL.md to under 150 lines to pass quality gate.
- **Source**: opencode
- **Context**: After writing devil-advocate SKILL.md, it was 271 lines, then reduced to 175, then 155.
- **Rationale**: Line count limit (NICE: 150) enforced by project guidelines.
- **Alternatives rejected**: Leaving as is and ignoring quality gate.
- **Confidence**: high
