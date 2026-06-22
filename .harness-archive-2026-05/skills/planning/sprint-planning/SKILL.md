---
name: sprint-planning
description: 'Generate an ordered implementation sprint plan from approved planning artifacts through delegated decomposition and prioritization.'
---

# Sprint Planning

## Purpose
Produce an ordered sprint story plan with dependency-aware sequencing and acceptance criteria.

## State Management
State file: .harness/state/sprint-planning--feature-name.yaml
On start: no file → copy template | status: completed → delete + fresh | status: in_progress → ask resume/restart

## Orchestration

Never do the work directly: dispatch subagents via task() for all work, verify each result explicitly, re-dispatch with feedback when verification fails, and use ask_question when genuinely stuck.

### Step 1: Gather planning inputs
**Dispatch subagent:**
- Goal: Read and summarize implementation-relevant context from feature spec, architecture, and PRD.
- Context files: docs/features/, docs/architecture/, docs/prd/, .harness/project-constitution.md.
- Constraints: Preserve requirement intent; identify blockers and unknowns explicitly.

**Verify:**
- Summary references all three document families and highlights risks or missing inputs.
- If fail → re-dispatch with feedback
- If pass → update state, advance

### Step 2: Decompose into stories
**Dispatch subagent:**
- Goal: Decompose scope into implementation stories, each with clear acceptance criteria.
- Context files: Step 1 planning summary, docs/features/, docs/architecture/, docs/prd/.
- Constraints: Stories must be independently testable and traceable to documented requirements.

**Verify:**
- Every story has acceptance criteria and requirement traceability notes.
- If fail → re-dispatch with feedback
- If pass → update state, advance

### Step 3: Order by dependency and priority
**Dispatch subagent:**
- Goal: Produce dependency-aware execution order and priority ranking for all stories.
- Context files: Story set from Step 2, Step 1 planning summary.
- Constraints: Explain ordering rationale; call out critical path items and parallelizable work.

**Verify:**
- Ordered list includes dependency notes, priority rationale, and no dependency violations.
- If fail → re-dispatch with feedback
- If pass → update state, advance

### Step 4: Publish sprint plan state
**Dispatch subagent:**
- Goal: Write final sprint plan with ordered stories to .harness/state/sprint--feature.yaml.
- Context files: Ordered story list from Step 3, Step 2 story details.
- Constraints: Keep format machine-readable and stable for downstream implementation workflows.

**Verify:**
- Output file exists at .harness/state/sprint--feature.yaml and includes ordered stories plus acceptance criteria references.
- If fail → re-dispatch with feedback
- If pass → update state, advance

## Completion
Delete state file. Report summary.
