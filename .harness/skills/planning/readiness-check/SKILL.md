---
name: readiness-check
description: 'Run a pre-implementation readiness gate by delegating document existence, completeness, and architecture coverage verification.'
---

# Readiness Check

## Purpose
Determine whether project planning artifacts are sufficient to begin implementation and report concrete gaps when not ready.

## Orchestration

Never do the work directly: dispatch subagents via task() for all work, verify each result explicitly, re-dispatch with feedback when verification fails, and use ask_question when genuinely stuck.

### Step 1: Verify prerequisite artifacts exist
**Dispatch subagent:**
- Goal: Confirm required prerequisite artifacts are present for readiness evaluation.
- Context files: docs/features/, docs/architecture/, docs/prd/, .harness/state/.
- Constraints: Check existence only; do not infer missing documents.

**Verify:**
- Result lists found and missing artifacts for spec, architecture, and stories.
- If fail → re-dispatch with feedback
- If pass → update state, advance

### Step 2: Verify spec completeness
**Dispatch subagent:**
- Goal: Check feature specification completeness, required sections, and assigned REQ-IDs.
- Context files: docs/features/, .harness/project-constitution.md.
- Constraints: Use explicit checks; identify missing sections and missing or malformed REQ-IDs.

**Verify:**
- Output includes a concrete completeness verdict with section-by-section and REQ-ID findings.
- If fail → re-dispatch with feedback
- If pass → update state, advance

### Step 3: Verify architecture coverage
**Dispatch subagent:**
- Goal: Validate that architecture documentation covers all specified requirements.
- Context files: docs/features/, docs/architecture/, Step 2 completeness findings.
- Constraints: Map requirements to architecture coverage; list uncovered requirements explicitly.

**Verify:**
- Coverage report includes requirement-to-architecture mapping and uncovered gaps.
- If fail → re-dispatch with feedback
- If pass → update state, advance

### Step 4: Produce readiness decision
**Dispatch subagent:**
- Goal: Produce final readiness status as READY or NOT READY with supporting evidence and gap list.
- Context files: Step 1 artifact check, Step 2 completeness findings, Step 3 coverage report.
- Constraints: Decision must be unambiguous; include actionable next steps for each gap.

**Verify:**
- Final report clearly states READY or NOT READY and includes prioritized gaps when not ready.
- If fail → re-dispatch with feedback
- If pass → update state, advance

## Completion
Report summary.
