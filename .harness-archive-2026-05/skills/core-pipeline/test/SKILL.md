---
name: test
description: 'Run delegated automated and validation testing phases, routing failures back to implementation until all required test gates pass.'
---

# Test

## Purpose
Validate implementation quality through delegated testing specialists and structured failure routing back to implementation.

Never run tests directly in this skill. Dispatch all testing through task(), verify reports against explicit gate criteria, re-dispatch implementation/testing with concrete failure details as needed, and use ask_question when genuinely blocked.

## State Management
State file: .harness/state/test--feature.yaml
On start: no file → copy template | status: completed → delete + fresh | status: in_progress → ask resume/restart

## Orchestration

### Step 1: Dispatch testing specialist
**Dispatch subagent:**
- Goal: execute required automated tests and produce a detailed test report.
- Context files: feature spec, implementation summary, project constitution
- Constraints: orchestrator does not execute tests directly.

**Verify:**
- Test report exists and includes pass/fail results with failing case details.
- If fail → re-dispatch implement skill with failure report, then re-run this step.
- If pass → update state, advance.

### Step 2: Dispatch regression verification
**Dispatch subagent:**
- Goal: confirm targeted fix regressions are absent and requirement-linked scenarios are covered.
- Context files: prior failures, updated implementation report, feature spec
- Constraints: keep requirement traceability explicit.

**Verify:**
- Regression check passes for all impacted requirement IDs.
- If fail → re-dispatch implement with corrective guidance, then re-run this step.
- If pass → update state, advance.

## Completion
Delete state file. Report summary.
