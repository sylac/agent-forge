---
name: step-router
description: Route autopilot execution to dispatch, inner loop, or finalization strictly by state.
stateFile: .harness/state/autopilot--pipeline.yaml
dispatchStepFile: ./step-dispatch.md
innerLoopStepFile: ./step-inner-loop.md
finalizeStepFile: ./step-finalize.md
---

```xml
<workflow>
  <critical>Route by state only. Do not perform domain work directly.</critical>
  <critical>Never load more than one step file at a time.</critical>

  <step n="1" goal="Read current phase and route">
    <action>Read .harness/state/autopilot--pipeline.yaml</action>
    <check if="current_phase is one of Ideation, Feature Analysis, Spec, Architecture, Stories, Implementation, Spec Reconciliation, User Confirmation">
      <action>Load and execute ./step-dispatch.md</action>
    </check>

    <check if="current_phase is one of Observability, Testing, UI Testing, Review">
      <action>Load and execute ./step-inner-loop.md</action>
    </check>

    <check if="current_phase is Finalization">
      <action>Load and execute ./step-finalize.md</action>
    </check>

    <check if="phase_index beyond phase_order length">
      <output>Pipeline complete.</output>
    </check>
  </step>
</workflow>
```
