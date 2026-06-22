---
name: nfr-assess
description: 'Assess implementation against specification non-functional requirements and report pass/fail status with supporting evidence.'
---

# NFR Assess

## Purpose
Evaluate how well the implementation satisfies non-functional requirements defined in the feature spec, including performance, security, and accessibility targets.

## Orchestration
### Step 1: Extract NFR targets and acceptance thresholds
**Dispatch subagent:** Read the target spec NFR section and capture explicit targets, constraints, and validation criteria.
**Verify:** Confirm each NFR is measurable or has a clear evaluation rule. Re-dispatch if NFRs are not normalized into assessable criteria.

### Step 2: Audit implementation evidence against NFRs
**Dispatch subagent:** Review relevant implementation artifacts and collect evidence for performance, security, and accessibility compliance against each NFR target.
**Verify:** Confirm evidence includes concrete artifacts (paths, configs, checks, test outputs, or code references). Re-dispatch if evidence is missing or weak.

### Step 3: Score each NFR as pass/fail with rationale
**Dispatch subagent:** For each NFR criterion, assign pass/fail status and provide justification, risk impact, and remediation guidance for failures.
**Verify:** Confirm every NFR has an explicit status and rationale tied to evidence. Re-dispatch on unsupported judgments or ambiguous status.

### Step 4: Produce consolidated NFR assessment report
**Dispatch subagent:** Compile a concise report summarizing NFR status by category, evidence links, and prioritized remediation actions.
**Verify:** Confirm report completeness, consistency with extracted NFR targets, and prioritization clarity. Re-dispatch for missing criteria or conflicting conclusions.

## Completion
Return an NFR assessment report with pass/fail status per NFR and evidence-backed rationale. This skill is stateless.
