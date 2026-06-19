---
name: ai-coworker-contrarian-review
description: |
  Use when reviewing a document or spec with adversarial rigor. Use when
  you need multiple agents to debate, challenge assumptions, search for
  better alternatives, and reach a judged conclusion. Use when a document
  needs thorough multi-perspective scrutiny before finalizing.
license: MIT
compatibility: opencode
metadata:
  triggers:
    - contrarian review
    - adversarial review
    - debate the document
    - multi-agent review
    - gang review
    - devil's advocate review
    - challenge this spec
    - 杠精 review
  when_to_use: |
    When a spec, design doc, or architecture decision needs rigorous
    multi-agent review. When you want agents with different models and
    capabilities to independently critique the document, search for
    better solutions, and debate until consensus or judgment.
    Also for cross-document reviews: checking all specs in a project
    for duplication, semantic conflicts, and alignment with VISION.md.
  when_not_to_use: |
    For simple typos or formatting fixes. For documents < 20 lines.
    For purely conversational feedback without structured debate.
  requires:
    - obra/superpowers:brainstorming
    - obra/superpowers:verification-before-completion
  audience:
    - spec-authors
    - architects
---

# ai-coworker-contrarian-review

Multi-agent adversarial document review with structured debate, web search,
cross-model comparison, Vision alignment checking, cross-document conflict
detection, and judged resolution. Five agents independently review target
documents, raise issues, search for alternatives, detect duplication and
semantic conflicts, debate disagreements, and converge on modifications
under a judge's final ruling.
disagreements, and converge on modifications under a judge's final ruling.

## When to Use

- Reviewing a spec or design document that needs thorough scrutiny
- Wanting agents with different models to independently find issues
- Needing web search to identify better industry patterns
- Requiring structured debate with evidence and final judgment
- Documents where assumptions need adversarial challenge

## When NOT to Use

- Minor copy-editing (typos, formatting)
- Documents under 20 lines with no architectural significance
- When you want quick feedback, not structured debate
- Purely conversational brainstorming without formal output

## Process

### Step 0: Setup

1. Create `docs/discussion/` directory if absent.
2. Identify all target documents — ask user if ambiguous. For cross-document reviews, include ALL spec documents in the project.
3. Read all target documents AND VISION.md fully.
4. Create a round file: `docs/discussion/YYYY-MM-DD-<topic>-review.md`

### Step 0a: Agent 0 — Vision Alignment + Cross-Document Reviewer

Launch Agent 0 with the following configuration:

- **Role:** Vision enforcer and cross-document conflict detector
- **Model:** Most capable model available (needs to hold many documents in context)
- **Instructions:**
  1. Read VISION.md first — this is the master reference. Extract every principle, constraint, and architecture decision.
  2. Read ALL target documents.
  3. For EACH document, check alignment with VISION.md:
     - Does the document violate any Vision principle?
     - Does the document contradict any Architecture Decision?
     - Does the document miss implementing a Vision requirement?
  4. Cross-document analysis:
     - **Duplication:** Find sections, definitions, or concepts repeated across documents. Flag which document should be the canonical owner.
     - **Semantic conflict:** Find contradictions between documents. E.g., document A says "X is required" but document B says "X is optional." Flag both locations.
     - **Naming drift:** Find the same concept named differently across documents. Flag inconsistent terminology.
     - **Version skew:** Find cross-references pointing to outdated section numbers. Flag stale references.
     - **Missing cross-reference:** Find concepts in one document that should reference another but don't.
  5. Use brainstorming skill on every Vision principle to probe for deeper gaps.
  6. Output structured issues: `section`, `issue_type` (vision_violation | duplication | semantic_conflict | naming_drift | version_skew | missing_cross_ref | missing_coverage), `description` (cite BOTH documents with line numbers), `proposed_fix`.
- **Output:** `docs/discussion/YYYY-MM-DD-<topic>-agent0-vision-issues.md`

### Step 1: Agent 1 — Web-Searching Contrarian

Launch Agent 1 with the following configuration:

- **Role:** Devil's advocate with mandatory web search
- **Model:** Any capable model (not MiniMax — reserved for Agent 2)
- **Instructions:**
  1. Read the target document.
  2. For each claim, design decision, and implementation option, search the web for better alternatives, conflicting evidence, or industry standards that the document misses.
  3. Raise issues with citations (URLs, papers, known patterns).
  4. Use brainstorming skill to generate alternative approaches for every section.
  5. Output a structured issue list with: `section`, `issue_type` (missing_alternative | wrong_approach | weak_rationale | outdated_pattern), `description`, `evidence` (with URLs), `proposed_fix`.
- **Output:** `docs/discussion/YYYY-MM-DD-<topic>-agent1-issues.md`

### Step 2: Agent 2 — MiniMax Cross-Model Reviewer

Launch Agent 2 with the following configuration:

- **Role:** Independent reviewer using a different model
- **Model:** MUST use MiniMax 3 model (or the best available MiniMax model)
- **Instructions:**
  1. Read the target document independently (do NOT see Agent 1's output).
  2. Critique every section: correctness, completeness, clarity, consistency.
  3. For each implementation option: evaluate trade-offs, check if the comparison matrix is honest, propose missing dimensions.
  4. Use brainstorming skill for each section to generate alternative designs.
  5. Output a structured issue list with: `section`, `issue_type` (correctness | completeness | clarity | consistency | trade_off_gap | missing_edge_case), `description`, `proposed_fix`.
- **Output:** `docs/discussion/YYYY-MM-DD-<topic>-agent2-issues.md`

### Step 3: Cross-Review and Debate Coordinator

Launch Agent 3 — the Debate Coordinator:

- **Role:** Compare both agents' findings, identify agreements and conflicts, facilitate debate.
- **Model:** Any capable model.
- **Instructions:**
  1. Read both Agent 1 and Agent 2 issue lists.
  2. **For agreed issues** (both agents independently identify the same problem with similar fixes):
     - Accept the fix and apply the modification to the target document immediately.
     - Record in `docs/discussion/YYYY-MM-DD-<topic>-resolutions.md` as `status: accepted_unanimous`.
  3. **For conflicting issues** (agents disagree on approach or one flags a problem the other did not):
     - For each conflict, dispatch Agent 1 and Agent 2 to debate.
     - Each debate: max 3 back-and-forth rounds.
       - Round 1: Agent raising the issue states the case. Opposing agent responds.
       - Round 2: Rebuttals with evidence. Each agent must cite concrete examples or sources.
       - Round 3: Final arguments, no new evidence allowed. Each agent states final position.
     - Save debate transcripts to `docs/discussion/YYYY-MM-DD-<topic>-debate-<N>.md`.
  4. For each debated issue, forward the full debate transcript + both final positions to Agent 4 (Judge).

### Step 4: Judge — Final Ruling

Launch Agent 4 — the Judge:

- **Role:** Neutral arbiter with final ruling authority.
- **Model:** Most capable model available (prefer the strongest reasoning model).
- **Instructions:**
  1. Read each debate transcript.
  2. For each issue, evaluate:
     - Which position has stronger evidence (citations beat opinions).
     - Which position better aligns with the document's stated goals and project principles (CLAUDE.md, VISION.md).
     - Whether the proposed change introduces new problems.
  3. Issue a ruling: `accept_proposal` | `reject_proposal` | `compromise` (with exact compromise text).
  4. Rulings are FINAL. No appeals.
  5. Output: `docs/discussion/YYYY-MM-DD-<topic>-judge-rulings.md` with per-issue rulings and rationale.
- After rulings, apply all accepted and compromise modifications to the target document.

### Step 5: Summary and Cleanup

1. Write a final summary: `docs/discussion/YYYY-MM-DD-<topic>-review-summary.md`
   - Total issues raised, accepted, rejected, compromised.
   - List of all modifications made with line references.
   - Debate statistics (rounds used, issues per round).
   - Any remaining open concerns deferred for later.
2. **Multi-round gate:** After all modifications are applied, re-read the modified documents. If new issues are discovered or modifications introduced problems, initiate another round. The process continues until ALL issues are resolved and no new issues emerge from modifications. Max total rounds: 3 full cycles.
3. Commit all changes: target document modifications + discussion files.

## Agent Configuration Reference

### Agent 0 (Vision Alignment + Cross-Document Reviewer)
```
inputs: VISION.md + ALL target documents (must read everything)
skill: brainstorming (on every Vision principle)
focus: VISION.md violations, cross-document duplication, semantic conflicts,
       naming drift, version skew, missing cross-references
output: structured issue list with dual document citations + line numbers
```

### Agent 1 (Web-Searching Contrarian)
```
search_web: true (mandatory)
skill: brainstorming (use on every section)
focus: find better alternatives, industry patterns, conflicting evidence
output: structured issue list with URLs
```

### Agent 2 (MiniMax Cross-Model Reviewer)
```
model: MiniMax 3 (mandatory — different model than Agent 1)
search_web: optional
skill: brainstorming (use on every section)
focus: correctness, completeness, consistency, trade-off honesty
output: structured issue list with proposed fixes
```

### Agent 3 (Debate Coordinator + Conflict Resolver)
```
responsibility: reconcile ALL agents' findings, moderate debate, apply unanimous decisions.
                For cross-document reviews: consolidate cross-document conflicts,
                identify root cause document for each conflict.
max_debate_rounds: 3 per issue
output: debate transcripts + modification log + cross-document conflict map
```

### Agent 4 (Judge)
```
authority: final ruling, no appeal
criteria: evidence strength > alignment with project principles > change safety
output: per-issue rulings with rationale
```

## Output File Structure

```
docs/discussion/
├── YYYY-MM-DD-<topic>-review.md                # Round file: session metadata, issue tracker
├── YYYY-MM-DD-<topic>-agent0-vision-issues.md   # Agent 0 findings (vision + cross-doc)
├── YYYY-MM-DD-<topic>-agent1-issues.md          # Agent 1 findings
├── YYYY-MM-DD-<topic>-agent2-issues.md          # Agent 2 findings
├── YYYY-MM-DD-<topic>-debate-1.md               # Debate transcript for issue cluster 1
├── YYYY-MM-DD-<topic>-debate-2.md          # Debate transcript for issue cluster 2
├── YYYY-MM-DD-<topic>-debate-N.md          # ... more debates
├── YYYY-MM-DD-<topic>-judge-rulings.md     # Judge's final decisions
└── YYYY-MM-DD-<topic>-review-summary.md    # Final summary
```

## Issue Type Taxonomy

| Type | Agent | Meaning |
|------|-------|---------|
| `vision_violation` | Agent 0 | Document contradicts a VISION.md principle or AD |
| `duplication` | Agent 0 | Concept defined in multiple docs; flag canonical owner |
| `semantic_conflict` | Agent 0 | Two docs say contradictory things about same concept |
| `naming_drift` | Agent 0 | Same concept named differently across docs |
| `version_skew` | Agent 0 | Cross-reference points to outdated/wrong section |
| `missing_cross_ref` | Agent 0 | Concept should reference another doc but doesn't |
| `missing_coverage` | Agent 0 | VISION.md requirement not addressed by any spec |
| `missing_alternative` | Agent 1 | An industry pattern or approach not considered |
| `wrong_approach` | Agent 1 | Web evidence suggests the approach is suboptimal |
| `weak_rationale` | Agent 1 | Decision rationale lacks supporting evidence |
| `outdated_pattern` | Agent 1 | Pattern has been superseded in industry |
| `correctness` | Agent 2 | Factual error or logical contradiction |
| `completeness` | Agent 2 | Missing content, edge cases, or scenarios |
| `clarity` | Agent 2 | Ambiguous or confusing wording |
| `consistency` | Agent 2 | Conflict between sections or with parent specs |
| `trade_off_gap` | Agent 2 | Comparison matrix missing important dimension |
| `missing_edge_case` | Agent 2 | Edge case not covered |

## Debate Protocol

Each debate follows strict rounds:

```
Round 1: CASE AND RESPONSE
  Proposer states the issue, evidence, and proposed fix.
  Opponent responds: agree / partially agree / disagree with reasoning.

Round 2: REBUTTAL WITH EVIDENCE
  Proposer rebuts opponent's response with new evidence or clarification.
  Opponent rebuts with counter-evidence.
  Either side may concede at this point (ends debate).

Round 3: FINAL POSITIONS
  Each side states final position in ≤3 sentences.
  No new evidence allowed.
  Debate transcript forwarded to Judge.
```

Multiple issues can be bundled into one debate session if they relate to the same section or concern. The Coordinator decides bundling.

## Quality Gates

### MUST

- [ ] All 4 agents launched and completed
- [ ] Agent 1 performed web search and provided URLs
- [ ] Agent 2 used MiniMax model (or closest available)
- [ ] All debates stayed within 3-round limit
- [ ] Judge ruled on every contested issue
- [ ] All discussion files written to docs/discussion/
- [ ] Target document modifications applied
- [ ] Final summary written with modification list
- [ ] No agent output truncated or lost

### NICE

- [ ] Every section of target document reviewed by both agents
- [ ] Each debate reached round 3 only when genuinely unresolved
- [ ] Judge rationales cite specific project principles
- [ ] Summary includes before/after diff statistics

## Anti-Patterns

- Skipping web search for Agent 1 — it must search the web
- Using same model for Agent 1 and Agent 2 — defeats cross-model purpose
- Debate exceeding 3 rounds — Judge intervenes and rules on available evidence
- Judge deferring without ruling — every issue must get a final decision
- Applying modifications before all debates conclude — wait for full resolution
- Losing discussion files — all must be in docs/discussion/ before committing

## Test Scenarios

### Scenario 1: Simple unanimous agreement
**Input:** Review a 50-line spec with one clear missing edge case.
**Expected:** Both agents identify same issue. Agent 3 accepts and applies fix. No debate. Judge not invoked. Summary shows 1 issue, accepted unanimously.

### Scenario 2: Heated debate with evidence
**Input:** Review a spec where Agent 1 finds an industry alternative, Agent 2 disagrees.
**Expected:** Full 3-round debate. Agent 1 cites web URLs. Agent 2 counters with spec's stated constraints. Judge rules compromise. Both debate transcript and ruling saved.

### Scenario 3: Multi-issue single debate session
**Input:** Review a spec with 5 issues across 2 sections, some agreed, some contested.
**Expected:** Agreed issues applied immediately. Contested issues bundled into 2 debate sessions (one per section). Judge rules on both. Summary shows 5 issues, 3 accepted, 1 rejected, 1 compromised.

### Scenario 4: Web search finds authoritative counter-evidence
**Input:** Review a spec that claims "no existing solution for X." Agent 1 finds a published paper solving X.
**Expected:** Agent 1 raises `wrong_approach` with paper citation. Agent 2 concurs. Fix applied to reference the paper. No debate needed.

## Sources

- Multi-agent review pattern: confidence medium — based on established code review workflows adapted to adversarial debate
- Debate protocol (3-round structure): confidence medium — adapted from formal debate formats, untested in AI agent context
- MiniMax model requirement: confidence high — user-specified constraint
- Web search mandate: confidence high — user-specified constraint
- Output structure: confidence high — consistent with project's docs/discussion/ convention
