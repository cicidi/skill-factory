---
name: find-my-unknown
description: |
  Use when starting any non-trivial task and you want to surface what you
  don't know before coding. Use when the user says "I'm not sure how to",
  "what am I missing", "help me think through this", or wants to brainstorm,
  prototype, or clarify requirements before implementation. Use when the
  user is about to dive into code without a clear plan. This skill uses
  interview-style questioning throughout — one question at a time, deep on
  architecture/data model, shallow on swappable choices, 2-3 rounds per topic
  max — to find unknowns before they become expensive mistakes.
license: MIT
compatibility: claude-code,opencode
metadata:
  source: "A Field Guide to Fable: Finding Your Unknowns" by Thariq Shihipar
  source_url: https://x.com/trq212/article/2073100352921215386
  triggers:
    - brainstorm
    - prototype
    - blind spot
    - unknown unknowns
    - what am I missing
    - I'm not sure how to
    - implementation plan
    - surface unknowns
    - clarify requirements
    - find my unknowns
    - find my unknown
---

# find-my-unknown

Surface and reduce unknowns before they become expensive mistakes.
Based on Thariq Shihipar's "A Field Guide to Fable: Finding Your Unknowns."

**Core idea:** "The map is not the territory." Your prompts and context (the map)
are not the actual codebase with its real-world constraints (the territory).
The gap is unknowns. When Claude encounters an unknown, it guesses your intent —
the more complex the task, the more guesses, the more that can go wrong.

**Core interaction pattern:** Interview-first. Claude silently scans code and
docs to do its homework, then asks the user ONE question at a time about
anything unclear or direction-changing. Deep追问 on architecture/data model;
shallow on swappable choices. 2-3 rounds per topic max, then move on.

## When to Use

- Starting any non-trivial feature or refactor
- Working in unfamiliar codebase territory
- The user expresses uncertainty or vagueness about requirements
- The task has many unstated decision points
- The user jumps straight to "just build X" without clarifying scope

## When NOT to Use

- Trivial tasks (typo fix, one-line change, obvious bug)
- Requirements are fully specified with no ambiguity
- The user explicitly says they have already planned thoroughly

## The Four Types of Unknowns

| Type | Definition | Example |
|------|-----------|---------|
| Known knowns | Explicitly stated in your prompt | "I want a dark mode toggle" |
| Known unknowns | You know you haven't figured out | "Not sure which auth library" |
| Unknown knowns | Obvious to you, never written down | Aesthetic preferences, tacit conventions |
| Unknown unknowns | You never knew you didn't know | "I didn't know color grading was a thing" |

## Interview Rules (apply to ALL phases)

These rules govern every interaction with the user:

### One question at a time
Ask exactly ONE question. Wait for the answer before asking the next.
Never batch questions — the user's answer to Q1 may make Q2 irrelevant.

### Depth heuristic

| Go DEEP (追问 2-3 rounds) | Go SHALLOW (ask once, move on) |
|---------------------------|-------------------------------|
| Backend architecture | Library/package choice |
| API design (contracts) | LLM provider selection |
| Data model / schema | Config values with defaults |
| Auth / permissions model | UI styling details |
| Things hard to change later | Things easy to swap later |

**Litmus test:** "If I get this wrong, how expensive is the fix?"
Expensive fix → deep. Cheap fix → shallow.

If a topic doesn't affect the current development cycle, don't追问.

### 2-3 round limit per topic
After 2-3 question-answer exchanges on one topic, summarize what you learned
and move to the next highest-priority gap. Staying on one topic too long has
diminishing returns — unknown unknowns on OTHER topics are piling up.

### "I don't know" is valid
If the user says "I don't know," that's a signal there's a knowledge gap.
Offer to: (a) explain the options, (b) pick a reasonable default and move on,
or (c) research and come back. Don't keep drilling on something the user
can't answer.

### Stop condition
When answers become "whatever you think is best" on 2+ consecutive questions,
the user's known unknowns are exhausted. Summarize decisions and move to
implementation planning.

## Auxiliary Tools

These are tools the interview process can reach for when needed. They are
NOT standalone phases — they serve the interview, not replace it.

### Tool A: Blind Spot Scan

**When to use:** You've done your silent scan, but sense the user is in
unfamiliar territory — new codebase area, new domain, or their questions
reveal they don't know what they don't know.

**How:** Before starting the interview, or mid-interview when you detect a
knowledge gap, do a targeted scan. Explore the codebase, trace paths, read
conventions. Then weave the findings into your questions:

> "I read through the auth module. It has a constraint I think you should know
> about — all providers must implement a `refresh` method. Does that change
> your approach, or should I just follow that pattern?"

This surfaces unknown unknowns without needing the user to ask for them.

### Tool B: Brainstorming & Prototyping

**When to use:** The user says "I'll know it when I see it" or can't articulate
what they want — they need to react to options, not describe them.

**How:** Mid-interview, when you hit an "unknown known" (a preference the user
can't verbalize), offer to generate options:

> "You mentioned you're not sure about the dashboard layout. Want me to
> generate 2-3 quick HTML prototypes with fake data so you can react?"

If the user says yes, generate the prototypes, let them react, then
continue the interview with the preference now clarified.

For visual prototypes, delegate to `frontend-design:frontend-design`.
For approach brainstorming, delegate to `superpowers:brainstorming`.

### Tool C: References

**When to use:** The user points at something — "make it like X" — or
describing the full requirement would take longer than pointing at code.

**How:** When the user references an existing file, directory, or URL, read it
thoroughly. Extract the semantics (not just surface patterns), summarize what
you found, and confirm:

> "I read `vendor/rate-limiter`. It uses exponential backoff with jitter,
> caps at 60s, and treats 429 and 503 as retryable. Want me to replicate
> that exact behavior, or should I adapt anything?"

This saves the user from describing what already exists in code.

## Process

### Phase 1: Scan & Prepare (silent)

Do your homework before asking the user anything:

1. **Read the codebase** — relevant files, modules, existing patterns
2. **Read project governance** — CLAUDE.md, CLAUDE.local.md, CONVENTIONS.md
3. **Map the territory** — what already exists, what constraints are in play
4. **Identify gaps** — what don't you know? What decisions are unmade?
5. **Use Blind Spot Scan** if the territory is unfamiliar — actively hunt for
   hidden constraints, conventions, and concepts the user hasn't mentioned

Output: a mental list of unknowns, prioritized by how much they'd change the
implementation if decided differently.

### Phase 2: Interview — Surface Unknowns

Now engage the user with one question at a time, following the Interview Rules.

**Question priority:**
1. Architecture-changing decisions (data model, API shape, auth model)
2. Scope decisions (what's in vs. out for this iteration)
3. Convention preferences (follow existing vs. new pattern)
4. Optimization choices (library selection, config values)
5. Unknown unknowns surfaced during the interview itself

**After each answer:**
- If the topic is high-impact (depth heuristic = deep): ask 1-2 follow-ups
  to nail down details, then move on
- If the topic is low-impact (depth heuristic = shallow): acknowledge, note
  the decision, and move on immediately
- After 2-3 rounds on a topic: summarize and pivot

**During the interview, reach for auxiliary tools when:**
- User seems unaware of a codebase constraint → **Tool A: Blind Spot Scan**
  (scan silently, then surface the finding as a question)
- User can't articulate a preference → **Tool B: Brainstorming & Prototyping**
  (generate options for them to react to)
- User says "like X" or describing would be verbose → **Tool C: References**
  (read X, extract semantics, confirm)

**After the interview:**
Summarize all decisions made. Highlight any remaining open questions.
Then offer to proceed to planning.

### Phase 3: Mid-Implementation — Interview for Deviations

Unknowns will surface during implementation. When a boundary case forces a
decision:

1. **Can you resolve it silently?** If the answer is clear from existing
   codebase patterns, make the call and log it.
2. **Does it need user input?** If the decision changes architecture,
   API contract, or data model → ask one question.
3. **Log everything** in `implementation-notes.md` under a `## Deviations`
   section: what was expected, what happened, what was decided, why.

### Phase 4: Post-Implementation

#### Review → delegate

Delegate to `contrarian-review` Mode 1 (lightweight gate) for routine changes,
or Mode 2 (full adversarial review) or `devil-advocate` for high-stakes work.

#### Quiz

Generate an HTML report covering:
- **Context:** Why this change, what problem it solves
- **Intuition:** Why this approach over alternatives
- **What changed:** File-by-file walkthrough with rationale
- **Quiz:** 3-5 questions testing understanding (not memorization)

The user should pass the quiz before merging.

## Skill Dependencies

| When | Delegate to |
|------|-------------|
| After interview, ready to plan | `superpowers:writing-plans` |
| Visual/UI prototyping needed | `frontend-design:frontend-design` |
| Post-implementation review | `contrarian-review` or `devil-advocate` |

## Anti-Patterns

- **Skipping to implementation** — the most common failure. "Just build X"
  without clarifying unknowns leads to costly rewrites.
- **Asking too many questions at once** — the user can only answer one thing
  at a time. Batch questions = wasted questions.
- **Deep-diving on swappable choices** — "Which LLM provider?" is a 1-question
  decision. Don't spend 5 rounds on it.
- **Staying on one topic too long** — after 2-3 rounds, diminishing returns
  kick in. Other unknowns are waiting.
- **Not doing homework first** — don't ask the user about things you could
  learn by reading the codebase yourself.
- **Treating the plan as final** — unknowns surface during implementation.
  That's expected. Log deviations and keep going.

## Sources

- "A Field Guide to Fable: Finding Your Unknowns" by Thariq Shihipar
  (https://x.com/trq212/article/2073100352921215386) — confidence: high
- Interview rules and depth heuristics: user-specified refinements — confidence: high
- Skill delegation mappings: ai-coworker-specific additions
