---
name: create-spec
description: 'Create and maintain SDD-compliant feature specifications by delegating drafting and validation to subagents with strict requirement ID governance and spec supremacy.'
---

# Create Spec

## Purpose
Produce a complete, authoritative feature specification in SDD format where requirement IDs define the implementation contract.

Never implement, test, or build directly in this skill. Dispatch all drafting and validation through task(), verify against explicit SDD criteria, re-dispatch with corrective feedback when checks fail, and use ask_question when genuinely blocked.

## State Management
State file: .harness/state/create-spec--feature.yaml
On start: no file → copy template | status: completed → delete + fresh | status: in_progress → ask resume/restart

## Orchestration

### Step 1: Prepare spec scaffolding and ID plan
**Dispatch subagent:**
- Goal: determine feature grouping, assign Feature ID pattern GROUP-NNN, and pre-plan requirement ID sequence.
- Context files: .harness/project-constitution.md, docs/features/, ideation and analysis artifacts
- Constraints: no direct writing by orchestrator; ID collisions are forbidden.

**Verify:**
- Feature ID matches GROUP-NNN with zero-padded number.
- Planned requirement IDs match FeatureId-NN.
- If fail → re-dispatch with feedback.
- If pass → update state, advance.

### Step 2: Draft full SDD specification via subagent
**Dispatch subagent:**
- Goal: generate full spec with all required sections and explicit REQ-ID coverage.
- Context files: ID plan, analysis outputs, constitution
- Constraints: declarative language, technology-agnostic statements, no implementation details in overview.

**Verify:**
- Required sections present and ordered.
- Every developer-facing behavior has a unique REQ-ID.
- Spec includes explicit statement of Spec Supremacy: implementation must conform to spec.
- If fail → re-dispatch with targeted corrections.
- If pass → update state, advance.

### Step 3: Validate navigation and publication
**Dispatch subagent:**
- Goal: update feature indexes and ensure spec is discoverable from navigation files.
- Context files: docs/features/, new spec path
- Constraints: only delegated edits; keep existing navigation consistent.

**Verify:**
- Spec file is present under docs/features/.
- Required index/navigation updates are applied.
- If fail → re-dispatch with feedback.
- If pass → update state, advance.

## Progressive Step Loading
Load only one step file at a time from the steps directory:
- step-init.md
- step-dispatch.md
- step-finalize.md

## Completion
Delete state file. Report summary.
