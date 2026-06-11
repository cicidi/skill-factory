---
name: tdd
description: |
  Use when building features or fixing bugs that require disciplined
  feedback loops. Use when the user mentions "red-green-refactor", wants
  integration tests, asks for test-first development, or needs to ensure
  behavior survives refactoring.
license: MIT
compatibility: opencode, claude-code
metadata:
  triggers:
    - tdd
    - test-driven development
    - red-green-refactor
    - test-first development
    - write tests first
    - integration tests
  when_to_use: |
    When implementing features or fixing bugs with a test-first approach.
    When the user wants red-green-refactor discipline. When building
    behavior-driven code that must survive refactoring.
  when_not_to_use: |
    When the user explicitly prefers test-after or no tests. When the
    change is purely cosmetic (formatting, comments). When the codebase
    has no test infrastructure and user doesn't want to set it up.
  audience:
    - developers
  source_author: mattpocock
  source_url: https://github.com/mattpocock/skills/blob/main/skills/engineering/tdd/SKILL.md
---

# tdd

Tests verify behavior through public interfaces, not implementation details.
Code can change entirely; tests shouldn't. One vertical slice at a time —
never batch all tests before writing any implementation.

## When to Use

- Implementing new features with test-first discipline
- Fixing bugs by first writing a failing test that reproduces the issue
- Refactoring code that already has test coverage
- The user mentions "TDD", "red-green-refactor", or "test-first"

## When NOT to Use

- User explicitly chooses test-after or no-test approach
- Purely cosmetic changes (formatting, comments, whitespace)
- The codebase lacks test infrastructure and user doesn't want to add it
- Prototyping or throwaway code

## Philosophy

**Core principle:** Tests should verify behavior through public interfaces,
not implementation details. Code can change entirely; tests shouldn't.

**Good tests** are integration-style: they exercise real code paths through
public APIs. They describe what the system does, not how it does it. A good
test reads like a specification — "user can checkout with valid cart" tells
you exactly what capability exists. These tests survive refactors because
they don't care about internal structure.

**Bad tests** are coupled to implementation. They mock internal
collaborators, test private methods, or verify through external means. The
warning sign: your test breaks when you refactor, but behavior hasn't
changed.

## Anti-Patterns

### Horizontal Slices

**DO NOT write all tests first, then all implementation.** This is
"horizontal slicing" — treating RED as "write all tests" and GREEN as
"write all code."

This produces bad tests:
- Tests written in bulk test imagined behavior, not actual behavior
- You test the shape of things rather than user-facing behavior
- Tests become insensitive to real changes
- You commit to test structure before understanding the implementation

**Correct approach:** Vertical slices via tracer bullets. One test → one
implementation → repeat.

```
WRONG (horizontal):
  RED:   test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

RIGHT (vertical):
  RED→GREEN: test1→impl1
  RED→GREEN: test2→impl2
  RED→GREEN: test3→impl3
```

## Process

### 1. Planning

Before writing any code:
- Confirm what interface changes are needed
- Confirm which behaviors to test (prioritize)
- Identify opportunities for deep modules (small interface, deep implementation)
- Design interfaces for testability
- List the behaviors to test (not implementation steps)
- Get user approval on the plan

**You can't test everything.** Confirm with the user which behaviors matter
most. Focus on critical paths and complex logic.

### 2. Tracer Bullet

Write ONE test that confirms ONE thing about the system:

```
RED:   Write test for first behavior → test fails
GREEN: Write minimal code to pass → test passes
```

This proves the path works end-to-end.

### 3. Incremental Loop

For each remaining behavior:

```
RED:   Write next test → fails
GREEN: Minimal code to pass → passes
```

Rules:
- One test at a time
- Only enough code to pass current test
- Don't anticipate future tests
- Keep tests focused on observable behavior

### 4. Refactor

After all tests pass, look for refactor candidates:
- Extract duplication
- Deepen modules (move complexity behind simple interfaces)
- Apply SOLID principles where natural
- Run tests after each refactor step

**Never refactor while RED.** Get to GREEN first.

## Quality Gates

### MUST (block commit on failure)

- [ ] Test describes behavior, not implementation
- [ ] Test uses public interface only
- [ ] Test would survive internal refactor
- [ ] Code is minimal for this test
- [ ] No speculative features added
- [ ] Never refactor while RED

### NICE (warn but don't block)

- [ ] Tests use the project's domain glossary
- [ ] ADRs in the affected area are respected
- [ ] Deep module opportunities identified

## Sources

- Original: mattpocock/skills/skills/engineering/tdd/SKILL.md
- Philosophy: confidence high — adapted from source
- Anti-patterns (horizontal slices): confidence high — from source
- Workflow (planning, tracer bullet, loop, refactor): confidence high — from source
- Quality gates: confidence medium — inferred from source checklist
