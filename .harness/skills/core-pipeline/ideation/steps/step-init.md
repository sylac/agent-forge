---
name: step-init
description: Initialize ideation state and resolve resume semantics.
nextStepFile: ./step-dispatch.md
---

```xml
<workflow>
  <critical>Delegate all analysis work. Never ideate directly.</critical>

  <step n="1" goal="Initialize state">
    <action>Check .harness/state/ideation--current.yaml</action>
    <check if="missing">
      <action>Create state with status=in_progress and context summary</action>
    </check>
    <check if="in_progress">
      <ask>Ideation is in progress. Resume or restart?</ask>
    </check>
    <check if="completed or restart">
      <action>Reset state and continue</action>
    </check>
  </step>

  <step n="2" goal="Route to dispatch">
    <action>Load ./step-dispatch.md</action>
  </step>
</workflow>
```
