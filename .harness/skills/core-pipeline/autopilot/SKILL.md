---
name: autopilot
description: 'Run the full Harness core pipeline autonomously from idea through finalization with stateful resume, strict subagent orchestration, and spec supremacy enforcement.'
---

# Autopilot

## Purpose
Orchestrate the complete end-to-end delivery pipeline by dispatching specialist subagents for every phase and advancing only after explicit verification gates pass.

## State Management
State file: .harness/state/autopilot--pipeline.yaml
On start: no file → copy template | status: completed → delete + fresh | status: in_progress → ask resume/restart

## Orchestration

### Step 1: Initialize run state and inputs
**Dispatch subagent:**
- Goal: collect the feature intent, initialize pipeline state, and prepare phase tracking for autonomous execution.
- Context files: .harness/project-constitution.md, docs/features/, docs/architecture/
- Constraints: NEVER implement, test, build, or write specs directly; dispatch subagents via task() for all work.

**Verify:**
- State file exists and status is in_progress.
- Pipeline phases are present in order: Init, Ideation, Feature Analysis, Spec, Architecture, Stories, Implementation, Observability, Testing, UI Testing, Review, Spec Reconciliation, User Confirmation, Finalization.
- If fail → re-dispatch with feedback.
- If pass → update state, advance.

### Step 2: Route scale-adaptive ideation mode
**Dispatch subagent:**
- Goal: classify initiative scale and select ideation mode (L0 skip, L1 analyst solo, L2 focused brainstorm, L3-L4 party mode).
- Context files: .harness/project-constitution.md, current feature brief from state
- Constraints: YOLO execution — only use ask_question for genuine product decisions or true blockers.

**Verify:**
- Scale level and rationale are recorded in state.
- Selected mode matches rules: L0 skip, L1 solo, L2 focused, L3-L4 full party mode.
- If fail → re-dispatch with feedback.
- If pass → update state, advance.

### Step 3: Execute planning pipeline by dispatch-only protocol
**Dispatch subagent:**
- Goal: produce and validate phase artifacts for Feature Analysis, Spec, Architecture, and Stories through delegated specialists.
- Context files: .harness/project-constitution.md, docs/features/, docs/architecture/, ideation outputs
- Constraints: orchestrator never writes domain artifacts directly; all work must be done via task() subagent dispatch.

**Verify:**
- Required planning artifacts exist and are internally consistent.
- Spec includes Feature ID and Requirement IDs in SDD format.
- Architecture constraints reference the approved spec.
- If fail → re-dispatch failing phase with explicit corrective feedback.
- If pass → update state, advance.

### Step 4: Dispatch implementation and run inner loop until clean
**Dispatch subagent:**
- Goal: implement approved stories, then run observability, testing, UI testing, and review as a continuous inner loop until all gates pass.
- Context files: feature spec, architecture doc, .harness/project-constitution.md, prior loop reports
- Constraints: inner loop has no iteration cap; when genuinely stuck, use ask_question tool instead of halting.

**Verify:**
- Implementation report maps each requirement ID to delivered behavior.
- Observability, test, UI test, and review each report pass.
- Any failed gate routes back to implementation with concrete feedback and then re-runs the failed gate.
- If fail → re-dispatch per failure routing and continue loop.
- If pass → update state, advance.

### Step 5: Reconcile spec against final implementation
**Dispatch subagent:**
- Goal: compare delivered behavior against spec and enforce spec supremacy before finalization.
- Context files: final implementation reports, feature spec, review outputs
- Constraints: missed requirements must go back to implementation; extra behavior requires user decision via ask_question.

**Verify:**
- Every requirement ID is implemented or explicitly resolved.
- Missed requirements are queued for re-implementation.
- Extra behavior has recorded user decision: update spec or remove behavior.
- If fail → re-dispatch reconciliation or implementation with feedback.
- If pass → update state, advance.

### Step 6: Request user confirmation and finalize
**Dispatch subagent:**
- Goal: obtain explicit user approval, then perform branch, commit, PR, and documentation status/index updates.
- Context files: final reconciliation report, docs/features/, docs/architecture/, project constitution
- Constraints: only proceed to finalization after explicit YES; orchestrator still dispatches all work.

**Verify:**
- Explicit user confirmation recorded.
- Finalization report includes branch, commit, PR link, spec status set to Approved, and updated navigation indexes.
- State cleanup completed.
- If fail → re-dispatch finalization with feedback.
- If pass → update state, advance.

## Progressive Step Loading
Load only one step file at a time from the steps directory:
- step-init.md
- step-router.md
- step-dispatch.md
- step-inner-loop.md
- step-finalize.md

Never preload future step files. Never run multiple step files simultaneously.

## Completion
Delete state file. Report summary.
