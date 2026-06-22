---
name: implement
description: 'Dispatch development specialists to implement feature requirements under architecture and constitution constraints, then verify build, lint, and requirement coverage.'
---

# Implement

## Purpose
Deliver implementation that conforms to specification and architecture through delegated developer execution and strict acceptance verification.

Never implement code directly in this skill. Dispatch all development work via task(), verify results against build/lint/REQ-ID criteria, re-dispatch with precise defect feedback on failure, and use ask_question only when a genuine decision is required.

## State Management
State file: .harness/state/implement--feature.yaml
On start: no file → copy template | status: completed → delete + fresh | status: in_progress → ask resume/restart

## Orchestration

### Step 1: Dispatch developer subagent
**Dispatch subagent:**
- Goal: implement the feature completely with all requirement IDs satisfied.
- Context files: feature spec (primary), architecture doc (constraint), .harness/project-constitution.md
- Constraints: preserve spec supremacy; do not alter requirements without explicit upstream approval.

**Verify:**
- Developer report maps each requirement ID to code changes.
- Build passes.
- Lint is clean.
- If fail → re-dispatch with explicit defect list.
- If pass → update state, advance.

### Step 2: Dispatch implementation audit pass
**Dispatch subagent:**
- Goal: independently verify all spec requirements are addressed with no omissions.
- Context files: implementation diff summary, feature spec, architecture doc
- Constraints: no new coding in audit.

**Verify:**
- Audit confirms complete requirement coverage.
- Any missed requirement is routed back to Step 1 re-dispatch.
- If fail → re-dispatch with feedback.
- If pass → update state, advance.

## Completion
Delete state file. Report summary.
