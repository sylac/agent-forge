---
name: ideation
description: 'Select and execute scale-adaptive ideation mode through delegated subagents, producing a validated ideation brief for downstream specification.'
---

# Ideation

## Purpose
Determine the appropriate ideation depth for the feature and deliver a decision-grade ideation brief through delegated specialists.

Never implement, test, build, or write specs directly in this skill. Dispatch all work via task(), verify output against explicit criteria, re-dispatch with concrete feedback on failure, and use ask_question when genuinely stuck.

## State Management
State file: .harness/state/ideation--current.yaml
On start: no file → copy template | status: completed → delete + fresh | status: in_progress → ask resume/restart

## Orchestration

### Step 1: Classify scope and pick ideation strategy
**Dispatch subagent:**
- Goal: classify feature complexity into L0–L4 and recommend ideation path.
- Context files: .harness/project-constitution.md, current feature summary
- Constraints: no direct brainstorming in orchestrator; use task() only.

**Verify:**
- Complexity level and rationale are explicit.
- Chosen strategy follows policy: L0 skip, L1 analyst solo, L2 focused brainstorm, L3-L4 party mode.
- If fail → re-dispatch with feedback.
- If pass → update state, advance.

### Step 2: Run delegated ideation session
**Dispatch subagent:**
- Goal: produce ideation brief containing problem framing, option space, tradeoffs, and recommended direction.
- Context files: scope classification output, constitution constraints
- Constraints: keep framework/language agnostic; surface product unknowns via ask_question only when necessary.

**Verify:**
- Ideation brief exists and includes options with tradeoff analysis.
- Recommendation is actionable for feature analysis/spec writing.
- If fail → re-dispatch with feedback.
- If pass → update state, advance.

### Step 3: Prepare handoff package
**Dispatch subagent:**
- Goal: produce concise handoff notes for Feature Analysis and Spec phases.
- Context files: ideation brief
- Constraints: no spec authoring here; handoff only.

**Verify:**
- Handoff package clearly states assumptions, open product decisions, and proposed direction.
- If fail → re-dispatch with feedback.
- If pass → update state, advance.

## Progressive Step Loading
Load only one step file at a time from the steps directory:
- step-init.md
- step-dispatch.md
- step-finalize.md

## Completion
Delete state file. Report summary.
