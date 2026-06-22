---
name: test-trace
description: 'Trace implemented test coverage back to spec REQ-IDs and report uncovered requirements through a coverage matrix.'
---

# Test Trace

## Purpose
Assess requirement-level test coverage by tracing implemented tests back to specification REQ-IDs and identifying uncovered requirements.

## Orchestration
### Step 1: Extract REQ-IDs from the feature spec
**Dispatch subagent:** Read the target spec in `docs/features/` and compile the authoritative REQ-ID list with requirement descriptions.
**Verify:** Confirm the REQ-ID list is complete and deduplicated. Re-dispatch on extraction errors or missing requirement context.

### Step 2: Scan tests for requirement references and inferred coverage
**Dispatch subagent:** Scan existing test suites to find explicit REQ-ID references and infer coverage from assertions, test names, and scenarios where IDs are absent.
**Verify:** Confirm each detected mapping has evidence (file path, test name, assertion summary). Re-dispatch when mappings are speculative or unsupported.

### Step 3: Compare expected versus observed coverage
**Dispatch subagent:** Compare the spec REQ-ID set to observed test mappings and classify each REQ-ID as covered, partially covered, or not covered.
**Verify:** Confirm classification criteria are applied consistently and partial coverage includes concrete missing behavior notes. Re-dispatch for inconsistent thresholds.

### Step 4: Generate the coverage matrix report
**Dispatch subagent:** Produce a coverage matrix listing each REQ-ID, coverage status, evidence references, and recommended follow-up tests for uncovered gaps.
**Verify:** Confirm every REQ-ID appears exactly once in the matrix and recommendations are actionable. Re-dispatch for omissions, weak evidence, or non-actionable guidance.

## Completion
Return a requirement-to-test coverage matrix showing covered and uncovered REQ-IDs with evidence and next actions. This skill is stateless.
