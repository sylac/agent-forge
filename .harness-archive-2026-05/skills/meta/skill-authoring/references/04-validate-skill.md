```xml
<workflow_step id="validate-skill" phase="validate" gate="VALIDATION-GATE">
  <critical>
    MANDATORY EXECUTION RULES:
    - NEVER load multiple step files simultaneously.
    - ALWAYS read the ENTIRE current step file before taking any action.
    - NEVER skip steps or optimize the sequence.
    - NEVER read the quality gate file until VALIDATION-GATE is complete.
  </critical>

  <sequence_verification>
    <current_state>validate</current_state>
    <required_prior_gate>WRITE-GATE</required_prior_gate>
    <stop_condition>
      If WRITE-GATE is missing, this file was loaded prematurely. Return to Phase 3,
      produce WRITE-GATE, and ignore this file until then.
    </stop_condition>
    <unlocked_file>references/04-validate-skill.md</unlocked_file>
    <conditional_unlock>scripts/validate-skill.py is unlocked only now, during validation.</conditional_unlock>
    <locked_file>references/05-quality-gate.md remains locked until VALIDATION-GATE is produced.</locked_file>
    <process_warning>Report any earlier premature phase-reference read, even if file content is otherwise correct.</process_warning>
  </sequence_verification>

  <objective>
    Verify metadata, AgentSkills baseline compatibility, body structure, dependency reachability, safety, invocation readiness, and runtime-specific checks.
  </objective>

  <validation_order>
    <check id="1" name="metadata">Required fields exist, parse cleanly, and match the target directory.</check>
    <check id="2" name="agentskills-baseline">Name, description, optional metadata, length guidance, and supporting-file references.</check>
    <check id="3" name="body-structure">Body is readable as Markdown; local XML-style tags are balanced if used.</check>
    <check id="4" name="dependency-reachability">Every referenced references/, assets/, or scripts/ path exists or has an explicit external source.</check>
    <check id="5" name="safety">Risky actions and trust assumptions are explicit.</check>
    <check id="6" name="invocation">Loaded SKILL.md alone gives enough instruction to start the task.</check>
    <check id="7" name="runtime-specific">Run validators or adapter checks for the target platform.</check>
  </validation_order>

  <deterministic_checks>
    <command purpose="local validator">python .harness/skills/meta/skill-authoring/scripts/validate-skill.py path/to/skill/SKILL.md</command>
    <command purpose="AgentSkills validator when installed">skills-ref validate path/to/skill</command>
    <command purpose="Harness adapter check when applicable">bash .harness/scripts/check-skill-symlinks.sh</command>
  </deterministic_checks>

  <quality_checklist>
    <item>Single capability or workflow.</item>
    <item>name matches directory and uses portable characters.</item>
    <item>description states what and when, with trigger terms near the front.</item>
    <item>Required behavior is in SKILL.md, not only in references.</item>
    <item>Supporting files are named in SKILL.md and exist.</item>
    <item>Main file is concise enough for progressive loading.</item>
    <item>Local XML-style blocks are balanced and meaningful when used.</item>
    <item>Markdown rendering remains readable.</item>
    <item>Scripts and risky actions have safety notes.</item>
    <item>Runtime-specific deviations are documented.</item>
  </quality_checklist>

  <gate_artifact name="VALIDATION-GATE">
    <field name="Passed">Checks run and clean.</field>
    <field name="Warnings">Non-blocking portability or style concerns.</field>
    <field name="Accepted deviations">Runtime-specific choices with rationale.</field>
    <field name="Blocked">Errors requiring edits before completion.</field>
    <field name="Phase discipline">Gate artifacts produced and any premature reference reads disclosed.</field>
    <field name="Next gate">Unlock references/05-quality-gate.md only after this gate is complete.</field>
  </gate_artifact>
</workflow_step>
```
