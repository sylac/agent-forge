---
name: correct-course
description: 'Correct mid-implementation divergence from specification by comparing code to spec, deciding remediation per gap, and orchestrating corrective actions.'
---

# Correct Course

## Purpose
Detect and resolve divergence between implementation and specification while enforcing spec-first alignment.

## Orchestration
### Step 1: Diff implementation behavior against specification
**Dispatch subagent:** Compare current implementation artifacts to target spec requirements and identify where behavior, interfaces, or constraints diverge.
**Verify:** Confirm divergences are mapped to specific spec clauses or REQ-IDs with concrete implementation evidence. Re-dispatch if findings are vague or untraceable.

### Step 2: Classify and validate divergence set
**Dispatch subagent:** Cluster divergences by severity and type (missing behavior, contradictory behavior, undocumented behavior, scope drift).
**Verify:** Confirm each divergence includes impact and recommended default path. Re-dispatch for unclear classification or missing impact analysis.

### Step 3: Decision gate per divergence
**Dispatch subagent:** For each divergence, ask_question to decide whether to update spec or fix code.
**Verify:** Enforce Spec Supremacy: in first place code should be adjusted to match docs, docs can be updated only if they missed something that surfaced up during implementation. Re-dispatch any decision that violates this rule without justified evidence.

### Step 4: Execute corrective path and re-check alignment
**Dispatch subagent:** Dispatch the appropriate fix path (implementation correction or justified spec amendment), then re-evaluate alignment.
**Verify:** Confirm each resolved divergence is closed with evidence and no new drift introduced. Re-dispatch unresolved items until alignment is restored or escalation is required.

## Completion
Return a course-correction report documenting divergences, decisions, applied corrections, and final alignment status. This skill is stateless.
