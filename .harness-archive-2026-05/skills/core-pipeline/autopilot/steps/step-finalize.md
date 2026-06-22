---
name: step-finalize
description: Finalization dispatcher for branch, commit, PR, documentation updates, and state cleanup.
stateFile: .harness/state/autopilot--pipeline.yaml
---

```xml
<workflow>
  <critical>Finalization is delegated. Orchestrator does not perform git or docs updates directly.</critical>

  <step n="1" goal="Dispatch finalization">
    <action>Dispatch finalizer subagent with reconciliation report, docs paths, and constitution constraints</action>
    <action>Require branch creation, commit, PR opening, and docs status/index updates</action>
  </step>

  <step n="2" goal="Verify finalization artifacts">
    <action>Verify branch name and commit reference are returned</action>
    <action>Verify PR URL is returned</action>
    <action>Verify feature spec status updated to Approved</action>
    <action>Verify navigation indexes updated</action>

    <check if="verification fails">
      <action>Re-dispatch finalizer with exact remediation instructions</action>
    </check>

    <check if="verification passes">
      <action>Set status=completed in state</action>
      <action>Delete .harness/state/autopilot--pipeline.yaml</action>
      <output>Autopilot complete with finalized delivery artifacts.</output>
    </check>
  </step>
</workflow>
```
