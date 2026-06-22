---
name: step-dispatch
description: Dispatch non-inner-loop phases to specialist subagents, verify outputs, and advance state.
nextStepFile: ./step-router.md
stateFile: .harness/state/autopilot--pipeline.yaml
---

```xml
<workflow>
  <critical>This step handles delegated execution for non-inner-loop phases.</critical>
  <critical>Never implement, test, build, or write specs directly.</critical>
  <critical>If blocked, use ask_question. Never halt silently.</critical>

  <step n="1" goal="Dispatch current phase">
    <action>Read state and resolve current_phase</action>
    <action>Construct delegation prompt using Goal / Context / Constraints sections</action>
    <action>Dispatch subagent via task() in YOLO mode</action>
  </step>

  <step n="2" goal="Verify phase output and route on result">
    <check if="current_phase is Ideation">
      <action>Verify ideation mode and rationale are recorded</action>
    </check>
    <check if="current_phase is Feature Analysis">
      <action>Verify analysis artifact exists and references feature intent</action>
    </check>
    <check if="current_phase is Spec">
      <action>Verify Feature ID format GROUP-NNN and Requirement IDs FeatureId-NN</action>
      <action>Verify spec supremacy statement is present</action>
    </check>
    <check if="current_phase is Architecture">
      <action>Verify architecture constraints trace to requirement IDs</action>
    </check>
    <check if="current_phase is Stories">
      <action>Verify stories map to requirement IDs</action>
    </check>
    <check if="current_phase is Implementation">
      <action>Verify implementation report covers all requirement IDs</action>
      <action>Set next phase to Observability to enter inner loop</action>
    </check>
    <check if="current_phase is Spec Reconciliation">
      <action>Verify missed requirements are routed back to Implementation</action>
      <action>Verify extra behavior decisions recorded through ask_question</action>
    </check>
    <check if="current_phase is User Confirmation">
      <action>Verify explicit user YES is recorded before finalization</action>
    </check>

    <check if="verification fails">
      <action>Re-dispatch same phase with concrete corrective feedback</action>
    </check>

    <check if="verification passes">
      <action>Advance phase_index and current_phase according to phase_order</action>
      <action>Persist state and load ./step-router.md</action>
    </check>
  </step>
</workflow>
```
