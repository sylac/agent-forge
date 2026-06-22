---
name: retrospective
description: 'Run a post-sprint or post-incident retrospective by collecting timeline evidence and synthesizing what worked, what failed, and what to improve.'
---

# Retrospective

## Purpose
Produce a structured retrospective for a sprint or incident by combining scoped context, delivery evidence, and actionable improvement commitments.

## Orchestration
### Step 1: Gather retrospective scope and constraints
**Dispatch subagent:** Initiate context intake and ask_question to capture sprint or incident boundaries, timeline, systems involved, and goals for the retrospective.
**Verify:** Confirm scope includes time window and relevant repositories/pipelines. Re-dispatch if boundaries are vague; ask_question again when critical scope data is missing.

### Step 2: Analyze delivery evidence
**Dispatch subagent:** Review git history, pull request activity, and CI failures within the scoped period; summarize major events and signal patterns.
**Verify:** Confirm evidence is time-bounded, source-linked, and highlights inflection points (delays, regressions, recoveries). Re-dispatch for weak chronology or missing signal sources.

### Step 3: Synthesize findings and action items
**Dispatch subagent:** Produce balanced synthesis: what went well, what did not, root causes, and prioritized action items with owners and expected outcomes.
**Verify:** Confirm findings are evidence-backed and actions are specific, measurable, and realistic. Re-dispatch if recommendations are generic or unowned.

### Step 4: Produce retrospective document
**Dispatch subagent:** Compile final retrospective document with scope, timeline, findings, action plan, and follow-up checkpoints.
**Verify:** Confirm document is complete, decision-ready, and suitable for team review. Re-dispatch for missing sections or unclear accountability.

## Completion
Return a finalized retrospective document containing evidence-backed findings and actionable follow-up items. This skill is stateless.
