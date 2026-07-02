---
name: devil-advocate
description: |
  Use when reviewing a spec, design doc, or proposal that needs
  adversarial stress-testing. Use when you want to find hidden
  assumptions, missing edge cases, or risks before implementation.
  Use when the user asks for a devil's advocate review or 杠精.
license: MIT
compatibility: opencode
metadata:
  triggers:
    - review spec
    - review design
    - devil advocate
    - adversarial review
    - stress test
    - 杠精
  when_to_use: |
    When a spec, design doc, or proposal needs rigorous adversarial
    review before implementation. When hidden assumptions, risks,
    or missing edge cases need to be discovered through debate.
  when_not_to_use: |
    For simple changes not warranting structured debate. For reviews
    where stakeholders are already aligned. For code reviews.
    For topics without a concrete document to review.
---

# ai-coworker-devil-advocate

Adversarial review through multi-agent debate. Three agents (con, pro, judge)
engage in structured rounds to stress-test a spec or design doc. Con attacks,
pro defends, judge rules. Max 5 rounds, majority-vote fallback for deadlocks.

## When to Use

- Spec, design doc, or proposal ready for adversarial review
- Need to surface hidden assumptions, missing edge cases, or risks
- User asks for devil's advocate or 杠精 review

## When NOT to Use

- Trivial changes not warranting structured debate
- Stakeholders already fully aligned
- Code review (use issue-report workflow instead)
- No concrete document to analyze

## Process

### Phase 1: Prepare

1. Read the document the user provided
2. Create `{project-path}/docs/devil-advocate/YYYY-MM-DD-<topic>/`
3. Initialize `discussion.md` with metadata
4. Announce: "Starting adversarial review. Max 5 rounds. Output at `<dir>`."

### Phase 2: Debate Rounds (max 5)

Per round, dispatch 3 Task subagents sequentially. The driving agent tracks
round count and passes unresolved items between rounds.

Round 1: full-document review. Rounds 2-5: only unresolved items.

After each judge ruling, append to `discussion.md`. Termination:
- Unresolved = 0 → Phase 4 (all resolved)
- Unresolved > 0, round < 5 → next round
- Unresolved > 0, round = 5 → Phase 3 (vote)

#### Con Agent

```
You are the CON agent. Attack the document. Find flaws.

INPUT: original doc + previous round unresolved items (if round > 1).

Analyze across: assumptions, completeness, feasibility, risks, alternatives.
For each argument: Claim (one sentence), Evidence (doc line numbers or
external sources), Impact (high/medium/low).

If round > 1, only address unresolved items from the previous round.
Every claim must have specific evidence — search files, GitHub, web.
```

#### Pro Agent

```
You are the PRO agent. Defend the document. Counter con's arguments.

INPUT: original doc + con agent's full arguments.

For each con argument, state ACCEPT (con is right, note as finding) or
REFUTE (counter with evidence). Then add supporting arguments beyond
the con's critique.

Search for counter-evidence: project files, GitHub, web.
```

#### Judge Agent

```
You are the JUDGE. Evaluate both sides. Rule on disputes.

INPUT: original doc + con arguments + pro responses.

Rulings:
- Con wins: solid evidence, pro cannot refute
- Pro wins: pro has stronger counter-evidence or identifies flaws
- Deferred: comparable evidence, needs next round

Output: Consensus (agreed points), Rulings (table with claim, evidence,
response, ruling, reason), Unresolved (deferred items only).

Reject vague claims without specific evidence. Only defer when both
sides have truly comparable evidence.
```

### Phase 3: Vote (only after round 5 with unresolved)

1. Per unresolved item, dispatch a voting subagent with full discussion.md
2. Each votes CON / PRO / ABSTAIN with one-sentence reason
3. Majority decides; tie = marked "unresolved" in report
4. Append to discussion.md

### Phase 4: Output

1. Generate `report.md`:
   - Consensus items, key risks (accepted/won by con), unresolved items, recommendations
2. Print to terminal:
   - Round summary, top 3-5 risks, unresolved items, file paths

## Quality Gates

### MUST (block)
- [ ] Document read completely before debate
- [ ] Output directory created and discussion.md initialized
- [ ] 3 subagents dispatched per round (con, pro, judge)
- [ ] Con arguments include evidence + impact
- [ ] Pro responses include ACCEPT/REFUTE per argument
- [ ] Judge output includes consensus + rulings + unresolved
- [ ] Round limit enforced (max 5)
- [ ] discussion.md updated per round
- [ ] report.md generated at end

### NICE (warn)
- [ ] Agents search beyond the document for evidence
- [ ] Arguments cite specific doc line numbers
- [ ] Judge explains reasoning per ruling
- [ ] Vote phase only triggered when necessary

## Anti-Patterns

### 1. No evidence

Arguments without specific citations or searches. Reject and re-dispatch.

### 2. Surface-level critique

Vague "this might not work" without explaining why. Judge must reject.

### 3. Judge avoids decisions

Too many defers when evidence clearly favors one side. Only defer when
both sides have comparable evidence.

### 4. Pro won't concede

Arguing against clearly valid con points. Pro prompt requires ACCEPT when
appropriate. Valid con criticism is a finding, not a defeat.

## Sources

- User requirement: 3-agent con/pro/judge adversarial debate
- skill-factory/CONVENTIONS.md: structure and naming conventions
- skill-factory bootstrap design: multi-subagent orchestration pattern
- User-confirmed: auto-review mode, max 5 rounds, majority-vote fallback,
  output at {project-path}/docs/devil-advocate/
