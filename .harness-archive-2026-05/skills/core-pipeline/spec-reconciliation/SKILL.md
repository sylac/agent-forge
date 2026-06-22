---
name: spec-reconciliation
description: 'Reconcile final implementation against specification, enforce spec supremacy, and route gaps to implementation or user decision paths.'
---

# Spec Reconciliation

## Purpose
Ensure the final implementation exactly matches the approved specification by identifying missing requirements and out-of-spec behavior.

Never implement fixes directly in this skill. Dispatch all reconciliation analysis and remediation work via task(), verify every requirement-level outcome explicitly, re-dispatch on gaps, and use ask_question for extra-behavior product decisions or genuine blockers.

## State Management
State file: .harness/state/spec-reconciliation--feature.yaml
On start: no file → copy template | status: completed → delete + fresh | status: in_progress → ask resume/restart

## Orchestration

### Step 1: Dispatch reconciliation analysis
**Dispatch subagent:**
- Goal: compare final implementation behavior against every requirement ID in the feature spec.
- Context files: feature spec, implementation report, review report, test evidence
- Constraints: spec supremacy is mandatory; analysis must be exhaustive by requirement ID.

**Verify:**
- Reconciliation report lists all requirement IDs with status implemented/missing.
- Extra behavior outside spec is explicitly listed.
- If fail → re-dispatch with feedback.
- If pass → update state, advance.

### Step 2: Route missed requirements and extra behavior
**Dispatch subagent:**
- Goal: route each gap according to policy.
- Context files: reconciliation report, feature spec
- Constraints: missed requirements must return to implement; extra behavior requires user decision via ask_question.

**Verify:**
- Every missing requirement is dispatched to implement for completion.
- Every extra behavior item has a recorded user decision: update spec or remove behavior.
- If fail → re-dispatch with corrective instructions.
- If pass → update state, advance.

### Step 3: Dispatch post-fix reconciliation
**Dispatch subagent:**
- Goal: re-run reconciliation after fixes/decisions and confirm zero unresolved deltas.
- Context files: updated implementation outputs and revised spec if approved by user
- Constraints: no unresolved mismatch permitted before finalization.

**Verify:**
- No missing requirements remain.
- No unresolved out-of-spec behavior remains.
- If fail → repeat Step 2 routing.
- If pass → update state, advance.

## Completion
Delete state file. Report summary.
