---
name: review
description: 'Dispatch reviewer specialists to audit spec-code alignment, code quality, and test evidence; route failures back through implementation dispatch workflow.'
---

# Review

## Purpose
Perform a delegated quality and compliance audit that blocks completion until specification alignment and quality standards are satisfied.

Never review or modify code directly in this skill. Dispatch all audit work via task(), verify against explicit acceptance criteria, route failures back to implement dispatch pattern, and use ask_question when genuinely stuck.

## State Management
State file: .harness/state/review--feature.yaml
On start: no file → copy template | status: completed → delete + fresh | status: in_progress → ask resume/restart

## Orchestration

### Step 1: Dispatch reviewer subagent
**Dispatch subagent:**
- Goal: audit spec-to-code alignment, code quality, and test evidence with explicit findings.
- Context files: feature spec, architecture doc, implementation report, test and UI test reports, constitution
- Constraints: orchestrator does not review code directly; all audits delegated.

**Verify:**
- Review report maps every requirement ID to implemented evidence.
- Report includes SOLID/DRY/KISS assessment and coverage assessment.
- If fail → route issues to implement dispatch pattern and re-run review.
- If pass → update state, advance.

### Step 2: Dispatch closure validation
**Dispatch subagent:**
- Goal: verify all prior review findings were resolved without regressions.
- Context files: previous review findings, updated implementation and test evidence
- Constraints: no direct code changes in closure step.

**Verify:**
- All required changes are closed.
- No new blocking review issues introduced.
- If fail → route back to implement and re-run Step 1.
- If pass → update state, advance.

## Completion
Delete state file. Report summary.
