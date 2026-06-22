---
name: step-finalize
description: Validate ideation deliverables and clean state.
---

```xml
<workflow>
  <critical>Finalize only after delegated output is verified.</critical>

  <step n="1" goal="Verify and close">
    <action>Verify ideation brief and handoff summary exist</action>
    <check if="verification fails">
      <action>Return to ./step-dispatch.md with feedback</action>
    </check>
    <check if="verification passes">
      <action>Delete .harness/state/ideation--current.yaml</action>
      <output>Ideation complete.</output>
    </check>
  </step>
</workflow>
```
