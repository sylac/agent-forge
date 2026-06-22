---
name: test-design
description: 'Design a requirement-traceable test strategy from a feature spec, covering unit, integration, and end-to-end tests mapped to REQ-IDs.'
---

# Test Design

## Purpose
Design a complete, requirement-traceable test strategy for a feature by mapping each spec REQ-ID to concrete unit, integration, and end-to-end test cases.

## Orchestration
### Step 1: Parse the feature spec and extract testable requirements
**Dispatch subagent:** Read the target feature specification in `docs/features/`, extract all REQ-IDs, acceptance criteria, constraints, and dependency assumptions.
**Verify:** Confirm every extracted item has a source REQ-ID and clear test intent. If REQ-ID extraction is incomplete or ambiguous, re-dispatch with a gap list. If ambiguity remains, ask_question to resolve missing or conflicting requirement wording.

### Step 2: Design the test strategy by test level
**Dispatch subagent:** For each REQ-ID, propose test coverage across unit, integration, and end-to-end levels with rationale, priority, and preconditions.
**Verify:** Confirm each REQ-ID has at least one proposed validating test and that test levels are justified. Re-dispatch when coverage is shallow, duplicated, or not risk-based.

### Step 3: Build the REQ-ID traceability plan document
**Dispatch subagent:** Produce a test plan document that maps `REQ-ID -> test cases`, including scope, setup, data needs, and expected outcomes.
**Verify:** Confirm one-to-many traceability is explicit, formatting is readable, and no REQ-ID is orphaned. Re-dispatch to fix missing mappings, weak assertions, or incomplete execution notes.

### Step 4: Final quality gate
**Dispatch subagent:** Run a consistency pass for terminology, requirement alignment, and contradiction checks against the source spec.
**Verify:** Confirm the plan is internally consistent and directly traceable to spec language. Re-dispatch on any mismatch; ask_question if source spec intent cannot be resolved from available artifacts.

## Completion
Return a finalized test plan document with explicit REQ-ID coverage across unit, integration, and end-to-end testing. This skill is stateless.
