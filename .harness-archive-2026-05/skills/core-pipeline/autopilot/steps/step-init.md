---
name: step-init
description: Initialize autopilot state, collect execution context, and prepare deterministic routing.
nextStepFile: ./step-router.md
stateTemplate: ../state.template.yaml
---

```xml
<workflow>
  <critical>You are the pipeline orchestrator. Delegate all work through task().</critical>
  <critical>Never implement, test, build, or write specs directly.</critical>
  <critical>Only one step file may be loaded at a time.</critical>
  <critical>Execution mode is YOLO: continue autonomously except genuine product decisions.</critical>

  <step n="1" goal="Resolve run state">
    <action>Check .harness/state/autopilot--pipeline.yaml</action>
    <check if="state missing">
      <action>Copy ../state.template.yaml into .harness/state/autopilot--pipeline.yaml</action>
      <action>Set status=in_progress, current_phase=Init, phase_index=0</action>
    </check>
    <check if="status is completed">
      <action>Delete existing state</action>
      <action>Copy fresh template and set status=in_progress</action>
    </check>
    <check if="status is in_progress">
      <ask>Autopilot state is already in progress. Resume or restart?</ask>
      <check if="restart">
        <action>Delete state and copy fresh template</action>
      </check>
    </check>
  </step>

  <step n="2" goal="Collect feature context by delegation">
    <action>Dispatch subagent to synthesize current user goal into concise feature_summary</action>
    <action>Provide constitution and existing docs as context</action>
    <action>Record feature_summary and timestamps into state</action>
    <check if="summary missing or ambiguous">
      <action>Re-dispatch with explicit formatting feedback</action>
    </check>
  </step>

  <step n="3" goal="Hand off to router">
    <action>Set current_phase=Ideation</action>
    <action>Persist state</action>
    <action>Load and execute ./step-router.md</action>
  </step>
</workflow>
```
