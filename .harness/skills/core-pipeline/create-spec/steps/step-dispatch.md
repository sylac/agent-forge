---
name: step-dispatch
description: Dispatch spec drafting and validation specialists with strict SDD ID and format gates.
nextStepFile: ./step-finalize.md
---

```xml
<workflow>
  <critical>The orchestrator never writes spec content directly.</critical>
  <critical>Spec Supremacy must be explicit in output.</critical>

  <step n="1" goal="Dispatch ID planning">
    <action>Dispatch subagent to allocate Feature ID and REQ-ID sequence</action>
    <check if="ID rules violated">
      <action>Re-dispatch with exact violation details</action>
    </check>
  </step>

  <step n="2" goal="Dispatch spec drafting">
    <action>Dispatch subagent to author SDD spec sections and REQ table</action>
    <check if="sections missing or REQ coverage incomplete">
      <action>Re-dispatch with missing section and REQ gap list</action>
    </check>
  </step>

  <step n="3" goal="Dispatch navigation updates">
    <action>Dispatch subagent to update docs/features indexes for discoverability</action>
    <check if="navigation not updated">
      <action>Re-dispatch with explicit target files</action>
    </check>
    <action>Load ./step-finalize.md</action>
  </step>
</workflow>
```
