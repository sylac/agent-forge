---
name: create-architecture
description: 'Generate architecture documentation from approved specification through delegated architecture specialists with traceable requirement constraints.'
---

# Create Architecture

## Purpose
Produce a requirement-traceable architecture document that constrains implementation decisions while remaining technology-agnostic where possible.

Never implement, test, build, or write architecture directly in this skill. Dispatch all architecture work via task(), verify outputs against explicit requirement-traceability criteria, re-dispatch on failure, and use ask_question when genuinely stuck.

## State Management
State file: .harness/state/create-architecture--feature.yaml
On start: no file → copy template | status: completed → delete + fresh | status: in_progress → ask resume/restart

## Orchestration

### Step 1: Dispatch architecture drafting
**Dispatch subagent:**
- Goal: produce architecture document in docs/architecture/ aligned to approved feature spec.
- Context files: feature spec, .harness/project-constitution.md, existing architecture docs
- Constraints: orchestrator must not author architecture directly; preserve spec authority.

**Verify:**
- Architecture document is created/updated in docs/architecture/.
- Key design choices trace back to requirement IDs.
- If fail → re-dispatch with feedback.
- If pass → update state, advance.

### Step 2: Dispatch architecture validation
**Dispatch subagent:**
- Goal: validate architecture consistency, risk handling, and implementation constraints.
- Context files: generated architecture doc, feature spec, constitution
- Constraints: no implementation work.

**Verify:**
- Validation report confirms no contradiction with spec.
- Required constraints for implementation are explicit.
- If fail → re-dispatch with feedback.
- If pass → update state, advance.

## Completion
Delete state file. Report summary.
