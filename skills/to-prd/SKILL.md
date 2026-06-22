---
name: to-prd
description: Synthesize a scope brief from conversation context and decisions log. Use when user wants to create a PRD, scope brief, or frame a feature for development.
---

Produce a scope brief at `docs/prd/<AREA>/<AREA>-<NNN>-<PascalCaseTitle>.md`. DO NOT interview the user — synthesize from what you already know.

## Anti-Pattern: The Mini-Spec

**DO NOT put implementation details in the scope brief.** It is a framing artifact, not a contract. Warning signs:

- Module names, file paths, schemas, or API contracts appear anywhere in the document
- Test strategy or testing decisions are mentioned
- Acceptance criteria read like integration tests instead of observable outcomes
- The document keeps getting updated after a spec exists

## Process

### 1. Mint the identifier

Determine the area code (2–3 uppercase letters). Reuse an existing area code when one fits; mint a new one only when no existing area applies. When minting a new area, also create `docs/specs/<AREA>/README.md` with flat YAML frontmatter (`area`, `name`, `description`).

Compute the feature number: scan current files AND git deletions to find the max ID ever used in that area, then add 1. Zero-pad to 3 digits. Gaps stay permanently.

```sh
# current files
ls docs/prd/<AREA>/ 2>/dev/null | grep -oP '<AREA>-\K\d{3}'
# deleted files (all stages share the numbering)
git log --all --diff-filter=D --name-only -- 'docs/specs/<AREA>/*.spec.md' 'docs/prd/<AREA>/*.md' | grep -oP '<AREA>-\K\d{3}'
```

### 2. Write the scope brief

Use the template below. Every user story must carry a MoSCoW tag: `[Must]`, `[Should]`, `[Could]`, or `[Won't]`. The `[Could]` and `[Won't]` stories signal deferred scope to the next stage.

### 3. Confirm and write

Present the draft to the user: *"Here's the scope brief. Does the problem statement land? Are the MoSCoW priorities right?"*

After approval, write the file to `docs/prd/<AREA>/<AREA>-<NNN>-<PascalCaseTitle>.md`. Create the directory if it does not exist.

## Done when

The scope brief file exists at the canonical path, the user has approved it, and it contains no module names, file paths, schemas, API contracts, or test strategy.

<scope-brief-template>

```yaml
---
id: <AREA>-<NNN>
title: <Title in Title Case>
area: <AREA>
---
```

> This document is transient scaffolding. It is written once and never updated after the contract artifact at `docs/specs/<AREA>/` lands. Anything that needs to survive long-term lands in the spec, an ADR, or the design doc.

## Problem Statement

The problem the user is facing, stated from the user's perspective. No solution language.

## User Stories

Each story carries a MoSCoW priority tag.

1. [Must] As a <actor>, I want <feature>, so that <benefit>
2. [Should] As a <actor>, I want <feature>, so that <benefit>
3. [Could] As a <actor>, I want <feature>, so that <benefit>
4. [Won't] As a <actor>, I want <feature>, so that <benefit>

## Out of Scope

What this feature explicitly does not cover.

## Success Criteria

Observable post-launch outcomes. Each criterion should be liftable into a spec acceptance criterion later.

- <Observable outcome 1>
- <Observable outcome 2>

## ADRs in Play

Existing ADRs that constrain this feature, plus new ADRs likely needed.

- **ADR-NNN**: <title> — <how it constrains this feature>
- **Needed**: <topic> — <why a new ADR is likely required>

If no ADRs apply, write: "None identified."

</scope-brief-template>
