---
name: tdd-with-specs
description: Test-driven development driven by an approved spec — derive failing tests from each requirement, then write code. Use when user wants to implement against a spec or mentions "red-green-refactor".
---

Implement an approved spec by walking its requirements one REQ ID at a time, red→green→refactor. DO NOT invent behavior the spec does not state; if the spec is missing or ambiguous, halt and surface the ambiguity to the user, naming the requirement ID and the missing/conflicting acceptance signal — the spec file at its canonical path (`docs/specs/<AREA>/<AREA>-<NNN>-<PascalCaseTitle>.spec.md`) is where the resolution must land before implementation continues.

## Philosophy

**Core principle**: Tests should verify behavior through public interfaces, not implementation details. Code can change entirely; tests shouldn't.

**Good tests** are integration-style: they exercise real code paths through public APIs. They describe _what_ the system does, not _how_ it does it. A good test reads like a specification - "user can checkout with valid cart" tells you exactly what capability exists. These tests survive refactors because they don't care about internal structure.

**Bad tests** are coupled to implementation. They mock internal collaborators, test private methods, or verify through external means (like querying a database directly instead of using the interface). The warning sign: your test breaks when you refactor, but behavior hasn't changed. If you rename an internal function and tests fail, those tests were testing implementation, not behavior.

See [tests.md](tests.md) for examples and [mocking.md](mocking.md) for mocking guidelines.

## Anti-Pattern: Horizontal Slices

**DO NOT write all tests first, then all implementation.** This is "horizontal slicing" - treating RED as "write all tests" and GREEN as "write all code."

This produces **crap tests**:

- Tests written in bulk test _imagined_ behavior, not _actual_ behavior
- You end up testing the _shape_ of things (data structures, function signatures) rather than user-facing behavior
- Tests become insensitive to real changes - they pass when behavior breaks, fail when behavior is fine
- You outrun your headlights, committing to test structure before understanding the implementation

**Correct approach**: Vertical slices via tracer bullets. One test → one implementation → repeat. Each test responds to what you learned from the previous cycle. Because you just wrote the code, you know exactly what behavior matters and how to verify it.

```
WRONG (horizontal):
  RED:   test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

RIGHT (vertical):
  RED→GREEN: test1→impl1
  RED→GREEN: test2→impl2
  RED→GREEN: test3→impl3
  ...
```

## Workflow

### 1. Load the spec

Locate the spec file at `docs/specs/<AREA>/<AREA>-<NNN>-<PascalCaseTitle>.spec.md`. If the user has not named one, ask: "Which spec are we implementing? Give me the path under `docs/specs/`." DO NOT proceed without a spec file on disk.

Then:

- Read the spec end-to-end and enumerate every requirement ID (`<AREA>-<NNN>-<NN>`) and its acceptance criteria.
- Cross-check the project's domain glossary and ADRs in the area you're touching — test names and interface vocabulary must match the spec's language.
- Confirm the ordered list of REQ IDs you intend to drive out with the user, flagging any you believe are already covered by existing tests.
- If a requirement is ambiguous, contradictory, or missing acceptance criteria, STOP. Surface the ambiguity to the user: name the requirement ID and the missing or conflicting acceptance signal. The spec file at its canonical path must be amended before implementation continues. DO NOT guess.

### 2. Consult the design doc (optional)

Check whether a design doc exists at `docs/design/<AREA>/<AREA>-<NNN>-<PascalCaseTitle>.md`.

- **If it exists**: read it for test strategy (frameworks, fixtures, mocking policy, unit-vs-integration boundaries) and internal module hints. Let these inform your test structure and fixture setup — but the spec's acceptance criteria still drive _what_ you test.
- **If it does not exist**: default to TDD orthodoxy — structure emerges during refactor. DO NOT block on a missing design doc.

### 3. Tracer Bullet

Pick the first REQ ID from the agreed list and write ONE test that asserts its acceptance criterion through the public interface:

```
RED:   Write test for <REQ-ID> → test fails
GREEN: Write minimal code to pass → test passes
```

Reference the REQ ID in the test name or a comment so traceability is mechanical, not memory-based — a grep for the ID must land on its test.

### 4. Incremental Loop

For each remaining REQ ID, in spec order:

```
RED:   Write next test for <REQ-ID> → fails
GREEN: Minimal code to pass → passes
```

Rules:

- One REQ ID at a time; one test per acceptance criterion
- Only enough code to pass the current test
- DO NOT add behavior the spec does not require
- Keep tests focused on observable behavior described by the spec
- If implementation reveals the spec is wrong, STOP and amend the spec file at its canonical path (`docs/specs/<AREA>/…`) before continuing

### 5. Refactor

After all tests pass, look for [refactor candidates](refactoring.md):

- [ ] Extract duplication
- [ ] Deepen modules (move complexity behind simple interfaces)
- [ ] Apply SOLID principles where natural
- [ ] Consider what new code reveals about existing code
- [ ] Run tests after each refactor step

**Never refactor while RED.** Get to GREEN first.

## Done when

```
[ ] Every REQ ID in the spec is covered by at least one test that names it
[ ] Every test describes behavior through a public interface and would survive an internal refactor
[ ] No code exists that is not demanded by a test, and no test exists that is not demanded by the spec
[ ] Full test suite is green on a clean checkout
[ ] Spec amendments (if any) landed in the spec file at its canonical path before the implementing code
```
