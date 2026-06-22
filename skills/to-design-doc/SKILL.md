---
name: to-design-doc
description: Produce an engineering design doc from an approved spec. Use when user wants a design doc, RFC, internal architecture, or test strategy for a spec.
---

Produce a design doc that captures HOW engineering delivers a spec — internal modules, seams, contracts between them, test strategy, failure handling, rollout. DO NOT restate observable behavior already contracted in the spec; the design doc owns only internal-how decisions.

## Anti-Pattern: The Re-Spec

**DO NOT paraphrase the spec's observable behavior.** The design doc owns *how*, never *what*. Warning signs:

- A section restates acceptance criteria or user capabilities from the spec
- The Overview paragraph reads like a product pitch instead of an engineering plan
- Module responsibilities are described in terms of user-visible outcomes rather than internal mechanics
- The doc could be useful to a product manager — it shouldn't be; the spec already is

## Process

### 1. Verify inputs

Read the spec file at `docs/specs/<AREA>/<AREA>-<NNN>-<PascalCaseTitle>.spec.md`. If missing, halt:

> "No spec found at `docs/specs/<AREA>/<AREA>-<NNN>-<PascalCaseTitle>.spec.md`. The design doc needs a contracted spec to design against."

Read `CONTEXT.md` for domain vocabulary. Read any ADRs listed in the spec's `related_adrs` frontmatter, plus scan `docs/adr/` for ADRs that touch the same area.

### 2. Identify modules and seams

Decompose the spec's requirements into internal modules — named units of responsibility. For each module, write a one-line responsibility statement. Identify the seams: where modules talk to each other, and through what shapes (function signatures, message payloads, event types).

DO NOT assign file paths or class names — implementation agents choose those. Name modules by responsibility (e.g. "SyncScheduler", "ConflictResolver"), not by file location.

### 3. Detect ADR-worthy decisions

For every internal-how decision, ask: does this encode a tradeoff that should survive independent of this design doc? Indicators:

- Two or more viable approaches with different failure profiles (event-sourcing vs CRUD, optimistic vs pessimistic locking)
- A retry/concurrency/consistency policy that other features might depend on
- A technology choice that constrains future work

If yes, halt the design doc for that decision. Draft the ADR at `docs/adr/<NNN>-<kebab-title>.md`, get user approval, then resume. DO NOT bury tradeoff rationale in the design doc.

> "This decision — <decision summary> — is a durable tradeoff, not a one-feature implementation detail. I'll draft an ADR for it before continuing the design doc."

### 4. Draft the design doc

Use the `<design-doc-template>` below. Fill each section from spec + recon + ADRs + CONTEXT.md.

Rules:

- **Module Map**: responsibility only, no file paths. One line per module.
- **Internal Contracts**: tabular. Caller → callee, interface shape, error contract.
- **Test Strategy**: name frameworks, fixture sources, mocking boundaries, coverage gates. Distinguish unit from integration. No test cases — those are written during implementation against spec acceptance criteria.
- **Failure Handling**: failure modes table. Each row: failure mode, detection mechanism, response. Cover the non-obvious cases the spec's NFRs imply but don't spell out.
- **Rollout**: deploy order, feature flags, migrations, backward-compat window. Omit if the feature is a single atomic deploy with no data migration.
- **Open Questions**: only non-load-bearing ones. Load-bearing questions block publishing — resolve them first (step 3) or with the user.

### 5. Publish

1. Derive `<AREA>`, `<NNN>`, and `<PascalCaseTitle>` from the spec's filename and frontmatter.
2. Create `docs/design/<AREA>/` if needed.
3. Write the design doc to `docs/design/<AREA>/<AREA>-<NNN>-<PascalCaseTitle>.md` with required YAML frontmatter (`id`, `title`, `spec`; optional `related_adrs`). Frontmatter is flat YAML only.
4. Confirm with the user before writing: *"Ready to publish the design doc to `docs/design/<AREA>/<AREA>-<NNN>-<PascalCaseTitle>.md`. Proceed?"*

### 6. Hand off

Tell the user:

> "Design doc written to `docs/design/<AREA>/<AREA>-<NNN>-<PascalCaseTitle>.md`. It covers <N> modules, <M> internal contracts, and <K> identified failure modes. Implementation can now proceed against the spec, using this doc for internal-how guidance."

## Done when

```
[ ] Spec file exists and was read in full this session
[ ] Every module has a one-line responsibility — no file paths
[ ] Every tradeoff-grade decision has been extracted to an ADR, not buried inline
[ ] No section restates observable behavior from the spec
[ ] Internal contracts are tabular with caller, callee, shape, and error contract
[ ] Test strategy names frameworks, mocking boundaries, and coverage gates
[ ] Open questions are non-load-bearing only; load-bearing ones resolved before publishing
[ ] Frontmatter present and valid: id, title, spec (relative path to existing spec file)
[ ] User approved before file was written
```

<design-doc-template>

---
id: <AREA>-<NNN>
title: <Title in Title Case>
spec: ../../specs/<AREA>/<AREA>-<NNN>-<PascalCaseTitle>.spec.md
related_adrs: [ADR-NNN]   # omit field entirely if none
---

# <AREA>-<NNN> Design Doc: <Title>

## 1. Overview

One paragraph. What internal approach this doc prescribes and why this shape was chosen over alternatives. Reference ADRs for tradeoff rationale — do not duplicate it here. DO NOT restate what the feature does for users; the spec owns that.

## 2. Module Map

| Module | Responsibility |
| :----- | :------------- |
| **<ModuleName>** | <One-line: what this module owns internally> |
| **<ModuleName>** | <One-line: what this module owns internally> |

No file paths. Agents choose paths at implementation time.

## 3. Internal Contracts

How modules talk to each other. These are internal seams, not the external API contracted in the spec.

| Caller | Callee | Interface / Message Shape | Error Contract |
| :----- | :----- | :------------------------ | :------------- |
| **<Module>** | **<Module>** | `<function signature or message shape>` | <what happens on failure> |

## 4. Test Strategy

### 4.1 Unit Tests

- **Framework**: <name>
- **Mocking boundary**: <what gets mocked and why>
- **Fixture sources**: <where test data comes from>
- **Coverage gate**: <minimum % or rule>

### 4.2 Integration Tests

- **Framework**: <name>
- **Scope**: <what integration boundary is exercised>
- **Fixture sources**: <where test data comes from>

Test *cases* are not listed here. They are written during implementation, one requirement at a time, driven by the spec's acceptance criteria.

## 5. Failure Handling

| Failure Mode | Detection | Response |
| :----------- | :-------- | :------- |
| <what can go wrong> | <how we know it happened> | <what the system does> |

## 6. Rollout

- **Deploy order**: <sequence of deployable units, if more than one>
- **Feature flags**: <flag names and default states, or "none">
- **Migrations**: <data migrations required, with rollback strategy>
- **Backward-compat window**: <how long old and new coexist, or "N/A">

Omit this section entirely if the feature is a single atomic deploy with no data migration.

## 7. Open Questions

Non-load-bearing questions only. Load-bearing questions must be resolved before this doc is published.

- <question>

</design-doc-template>
