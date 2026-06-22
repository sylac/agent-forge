---
name: finalize
description: 'Finalize delivery by delegated branch/commit/PR workflow, update living documentation status and indexes, and clean runtime state files.'
---

# Finalize

## Purpose
Complete release handoff through delegated repository finalization and documentation publication tasks after all quality gates and reconciliations pass.

Never perform direct finalization operations in this skill. Dispatch all branch/commit/PR and documentation updates via task(), verify completion artifacts explicitly, re-dispatch on failure, and use ask_question if a genuine release decision is needed.

## State Management
State file: .harness/state/finalize--feature.yaml
On start: no file → copy template | status: completed → delete + fresh | status: in_progress → ask resume/restart

## Orchestration

### Step 1: Dispatch release finalizer
**Dispatch subagent:**
- Goal: create branch, commit approved changes, and open a pull request.
- Context files: final implementation/review/reconciliation outputs, project constitution
- Constraints: execute git and PR operations in delegated flow; include clear rationale in commit and PR summary.

**Verify:**
- Branch name, commit reference, and PR URL are returned.
- If fail → re-dispatch with feedback.
- If pass → update state, advance.

### Step 2: Dispatch living-doc updates
**Dispatch subagent:**
- Goal: mark feature specification status as Approved and refresh navigation indexes.
- Context files: docs/features/, docs/architecture/, final spec paths
- Constraints: maintain existing documentation structure and links.

**Verify:**
- Feature spec status is Approved.
- Navigation indexes are updated and consistent.
- If fail → re-dispatch with feedback.
- If pass → update state, advance.

### Step 3: Dispatch state cleanup
**Dispatch subagent:**
- Goal: clean transient state files related to completed pipeline execution.
- Context files: .harness/state/
- Constraints: remove only run-state artifacts for completed flow.

**Verify:**
- Relevant state files are cleaned.
- Finalization summary is complete and includes PR link.
- If fail → re-dispatch with feedback.
- If pass → update state, advance.

## Completion
Delete state file. Report summary.
