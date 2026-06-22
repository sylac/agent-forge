---
name: step-dispatch
description: Dispatch ideation specialists and verify output quality.
nextStepFile: ./step-finalize.md
---

```xml
<workflow>
  <critical>Use task() for all ideation work.</critical>

  <step n="1" goal="Dispatch complexity classification">
    <action>Dispatch analyst subagent to classify L0-L4 and select mode</action>
    <check if="classification invalid">
      <action>Re-dispatch with policy reminders</action>
    </check>
  </step>

  <step n="2" goal="Dispatch ideation generation">
    <action>Dispatch ideation subagent according to selected mode</action>
    <check if="brief lacks options or tradeoffs">
      <action>Re-dispatch with explicit missing sections</action>
    </check>
  </step>

  <step n="3" goal="Persist outputs">
    <action>Record ideation artifact path and summary in state</action>
    <action>Load ./step-finalize.md</action>
  </step>
</workflow>
```
