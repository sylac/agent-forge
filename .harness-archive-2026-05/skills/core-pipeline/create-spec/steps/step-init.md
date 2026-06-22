---
name: step-init
description: Initialize create-spec state and establish ID planning context.
nextStepFile: ./step-dispatch.md
stateTemplate: ../state.template.yaml
---

```xml
<workflow>
  <critical>Delegate all spec authoring tasks via task().</critical>

  <step n="1" goal="Resolve create-spec state">
    <action>Check .harness/state/create-spec--feature.yaml</action>
    <check if="missing">
      <action>Copy ../state.template.yaml and set status=in_progress</action>
    </check>
    <check if="completed">
      <action>Delete and recreate from template</action>
    </check>
    <check if="in_progress">
      <ask>Spec creation is in progress. Resume or restart?</ask>
    </check>
  </step>

  <step n="2" goal="Move to delegated drafting">
    <action>Load ./step-dispatch.md</action>
  </step>
</workflow>
```
