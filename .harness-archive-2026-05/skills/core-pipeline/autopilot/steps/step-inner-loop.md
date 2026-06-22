---
name: step-inner-loop
description: Execute Observability → Testing → UI Testing → Review loop until all gates pass, with no iteration cap.
nextStepFile: ./step-router.md
stateFile: .harness/state/autopilot--pipeline.yaml
---

```xml
<workflow>
  <critical>Inner loop has no iteration cap.</critical>
  <critical>When genuinely stuck, use ask_question for a precise decision.</critical>
  <critical>Never do implementation or testing directly; always dispatch subagents.</critical>

  <step n="1" goal="Dispatch current gate">
    <action>Read current_phase from state</action>
    <action>Dispatch corresponding specialist subagent via task()</action>
  </step>

  <step n="2" goal="Validate gate result">
    <check if="current_phase is Observability">
      <action>Require zero unresolved critical findings</action>
    </check>
    <check if="current_phase is Testing">
      <action>Require passing test report and failing cases addressed</action>
    </check>
    <check if="current_phase is UI Testing">
      <action>Require no unresolved functional UI defects</action>
    </check>
    <check if="current_phase is Review">
      <action>Require review decision pass with no blocking issues</action>
    </check>

    <check if="gate fails">
      <action>Record failure in inner_loop.history</action>
      <action>Dispatch implementation subagent with failure report and required fixes</action>
      <action>Re-run failed gate by keeping current_phase unchanged</action>
      <action>Persist state and continue loop</action>
    </check>

    <check if="gate passes">
      <action>Advance to next gate: Observability→Testing→UI Testing→Review</action>
      <check if="Review passes">
        <action>Advance to Spec Reconciliation</action>
      </check>
      <action>Persist state and load ./step-router.md</action>
    </check>
  </step>
</workflow>
```
