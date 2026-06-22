---
name: to-spec
description: Turn a framed scope brief into a functional specification — the durable source-of-truth contract. Use when user wants to spec out a feature or document observable system behavior.
---

Produce a spec at `docs/specs/<AREA>/<AREA>-<NNN>-<PascalCaseTitle>.spec.md` from the scope brief at `docs/prd/<AREA>/<AREA>-<NNN>-<PascalCaseTitle>.md`.

If no scope brief exists at the canonical path, halt and say so.

## IDs and paths

```
docs/prd/<AREA>/<AREA>-<NNN>-<PascalCaseTitle>.md          # scope brief (input)
docs/specs/<AREA>/<AREA>-<NNN>-<PascalCaseTitle>.spec.md   # spec (output)
docs/specs/<AREA>/README.md                                # area index (frontmatter authored; body generated)
docs/specs/README.md                                       # top-level index (generated)
docs/adr/<NNN>-<kebab-title>.md                            # ADRs
docs/design/<AREA>/<AREA>-<NNN>-<PascalCaseTitle>.md       # design doc (optional)
```

**Area code**: 2–3 uppercase letters (e.g. `SY`, `AU`). Reuse existing; mint new only when nothing fits. When minting, create `docs/specs/<AREA>/README.md` with `area`, `name`, `description` frontmatter.

**Feature number**: zero-padded 3 digits, sequential per area, never reused. Next = (max ID ever used in this area) + 1. Scan live files AND `git log --all --diff-filter=D --name-only -- 'docs/specs/<AREA>/*.spec.md'`. Gaps stay.

**Requirement ID**: `<AREA>-<NNN>-<NN>`, sequential per spec, never reused. Delete the row to retire; the gap stays.

**Frontmatter**: flat YAML only — `key: value` and `[a, b]` arrays. No nested maps, no multiline scalars. The regen script rejects anything else.

## Process

### 1. Recon

Run in parallel:

- **Codebase** — touch-zone behavior, vocabulary, ADRs, prior art for similar behaviors.
- **Spec corpus** — next `<AREA>-<NNN>` per the rule above, component names already in use, neighboring requirement IDs, whether `<AREA>/README.md` exists.
- **UX prior art** — only if the feature has a user-visible surface; existing screens, copy, a11y patterns.

Then read the scope brief, `CONTEXT.md`, and the ADRs recon surfaced. If an existing spec covers this area+feature, edit it in place — never fork a parallel spec.

### 2. Capabilities and components

- List capabilities per actor (User, System, Operator from `CONTEXT.md`).
- Group into components — functional buckets, never module/class/file names. Reuse area-wide component names.
- Draft requirements per capability. MoSCoW priority from the scope brief.
- **Cross-cutting check**: for auth, telemetry, logging, i18n, accessibility — add a REQ row (feature-specific observable) or NFR row (flat constraint) if the feature touches it.

If two component groupings are equally defensible and the choice changes IDs, ask the user the smallest question that resolves it. Otherwise proceed.

### 3. Resolve load-bearing questions first

A question is **load-bearing** if its answer would change a requirement ID, a component grouping, or a value in acceptance criteria. Resolve before drafting — HITL or spike. Non-load-bearing gaps use a defensible default grounded in scope-brief intent.

### 4. Write

Draft from the template. Rules:

- **Black-box.** Every requirement is observable through user, API, UI, or persisted record. If verifying requires reading source, it doesn't belong here.
- **Present tense, indicative.** "The system retrieves…", not "will retrieve" or "should retrieve".
- **Vocabulary.** `CONTEXT.md` terms exactly. New domain terms get added to `CONTEXT.md` lazily, with one- or two-sentence definitions in domain language.
- **Components.** Functional groupings only. Never module/class/file/layer names in the Component column.
- **Acceptance criteria.** Start with `Verify`; one observable signal per row. Two signals = two requirements.
- **NFRs** have no IDs.
- **Snippets.** No code, no file paths. Schemas/enums/records belong in the Data Model section as tables. Inline a prototype-derived snippet only when prose is strictly less precise (e.g. a state machine); mark `_(from prototype)_`.
- **Non-obvious tradeoffs** (the kind a future reader would ask "why this way?" about) → mint an ADR before publishing; link via `related_adrs`. The scope brief is transient and can't carry rationale.
- **UI edge states.** For every user-visible surface, enumerate loading / empty / error / offline as explicit requirement rows or a States sub-table. Happy-path-only is the failure mode.

If `internal contracts / test strategy / module layout / rollout / failure handling` need to be decided, they go in a design doc at `docs/design/<AREA>/<AREA>-<NNN>-<PascalCaseTitle>.md`, not in the spec. The spec is silent on *how*. Don't block on the design doc.

If recon surfaces a plan-breaking discovery (e.g. the scope brief implies a state transition that breaks an existing spec), interrupt with: what you found, what it blocks, 2–3 options, your pick. One question per turn until resolved. Re-enter step 2 for affected capabilities only.

### 5. Publish

1. Pick `PascalCaseTitle`. Use area code + feature number from recon.
2. Create `docs/specs/<AREA>/` if needed; if introducing a new area, author `<AREA>/README.md` frontmatter.
3. Write the spec with frontmatter (`id`, `title`, `synopsis`, `prd`; optional `related_adrs`).
4. If any requirement contradicts an active ADR, halt — either revise the spec or land a superseding ADR first.
5. Run the regen:

   ```
   node .agents/skills/to-spec/bin/regen-index.mjs docs/specs
   ```

   Fix any error it reports (missing field, malformed YAML, id/filename mismatch, duplicate id, synopsis too long, broken `prd:` path) and re-run. Spec isn't published until regen exits 0.

## Done when

```
[ ] Recon completed (or skipped with a one-line justification per subagent)
[ ] Cross-cutting concerns (auth, telemetry, logging, i18n, a11y) addressed as REQ/NFR or explicitly N/A
[ ] No unresolved load-bearing questions; no [?] markers
[ ] Every precise value (number, threshold, strategy) has a source: scope brief, recon, ADR, or explicit user answer
[ ] ADR conflicts resolved; non-obvious tradeoffs minted as ADRs
[ ] UI surfaces cover loading / empty / error / offline
[ ] Functional Specification contains only Must / Should rows
[ ] Spec file at canonical path with complete frontmatter (id, title, synopsis ≤140 chars, prd → existing file)
[ ] New area (if any) has authored README.md frontmatter
[ ] regen-index.mjs exited 0
```

<spec-template>

---
id: <AREA>-<NNN>
title: <Title in Title Case>
synopsis: <one sentence, present tense, black-box, ≤140 chars — what the feature is, in domain terms>
prd: ../../prd/<AREA>/<AREA>-<NNN>-<PascalCaseTitle>.md
related_adrs: [ADR-NNN, ADR-MMM]   # omit field entirely if none
---

# <AREA>-<NNN> Feature Specification: <Title>

## 1. Overview

One or two paragraphs. What this feature is, who interacts with it, the shape of the behavior, and the boundaries of what it covers. A reader should be able to stop here and know whether the rest is relevant to them. Present tense, black-box.

## 2. User Capabilities

| Actor      | Capability                                                |
| :--------- | :-------------------------------------------------------- |
| **User**   | Can <do something observable>                             |
| **System** | Automatically <does something on a trigger>               |

One row per distinct capability. Actor names from `CONTEXT.md`.

## 3. Functional Specification

| ID                  | Priority    | Component          | Behavior / Logic                                                                                  | Acceptance Criteria                                  |
| :------------------ | :---------- | :----------------- | :------------------------------------------------------------------------------------------------ | :--------------------------------------------------- |
| **<AREA>-<NNN>-01** | **Must**    | **<Component>**    | The system <observable behavior in present tense, naming inputs and outputs in domain terms>.     | Verify <single observable signal>.                   |
| **<AREA>-<NNN>-02** | **Should**  | **<Component>**    | …                                                                                                  | Verify …                                             |

Rules:

- IDs sequential, zero-padded 2 digits, never reused.
- Priority: `Must` / `Should`, bold. `Could` / `Won't` belong in the scope brief, not here.
- Component: bolded short capability name; reuse across rows.
- Behavior: one sentence, present tense, black-box.
- Acceptance criterion: starts with `Verify`, names one observable signal.

## 4. User Interface & Experience

Omit if no UI surface.

### 4.1 <Surface Name>

Brief paragraph describing the surface.

| Element                | Interaction / Condition                                    | Visual State / Feedback                                  |
| :--------------------- | :--------------------------------------------------------- | :------------------------------------------------------- |
| **<Element name>**     | <When this happens / when this state holds>                | <What the user sees>                                     |

#### States

| State       | Condition                          | What the user sees                        |
| :---------- | :--------------------------------- | :---------------------------------------- |
| **Loading** | <trigger>                          | <observable feedback>                     |
| **Empty**   | <condition>                        | <observable feedback>                     |
| **Error**   | <condition>                        | <observable feedback>                     |
| **Offline** | <condition>                        | <observable feedback>                     |

Omit states that genuinely don't apply; include all that do.

### 4.2 State Transitions

| From Status | To Status | Trigger                       |
| :---------- | :-------- | :---------------------------- |
| `Open`      | `Sending` | <observable trigger>          |

## 5. Data Model & Storage

| Entity              | Attributes                              | Relationships                            |
| :------------------ | :-------------------------------------- | :--------------------------------------- |
| `<EntityName>`      | <attr1>, <attr2>, <attr3>               | Belongs to `<Other>`, Has many `<Other>` |

### 5.1 <EnumName> Enum

| Value      | Description                                  |
| :--------- | :------------------------------------------- |
| `<Value>`  | <what this state means, observably>          |

### 5.2 <RecordName> Record

| Property   | Type    | Description                                  |
| :--------- | :------ | :------------------------------------------- |
| <Property> | <type>  | <meaning in domain terms>                    |

## 6. Non-Functional Requirements

| Category          | Requirement                                                                |
| :---------------- | :------------------------------------------------------------------------- |
| **Performance**   | <quantified constraint where possible>                                     |
| **Reliability**   | <observable guarantee>                                                     |
| **Security**      | <observable property>                                                      |
| **Storage**       | <retention / cleanup guarantee>                                            |
| **Accessibility** | <observable a11y guarantee>                                                |

## 7. Constraints & Dependencies

Omit if empty.

- Depends on <external system / API / permission>.
- Requires <prerequisite condition>.
- Limited by <platform / regulatory / contractual constraint>.

Internal modules and libraries belong in the design doc, not here.

## 8. Out of Scope

Omit if empty or merely restating the scope brief's `Won't` items.

</spec-template>
