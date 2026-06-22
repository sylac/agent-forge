```xml
<workflow_step id="audit-existing-context" phase="audit" gate="AUDIT-GATE">
  <critical>
    MANDATORY EXECUTION RULES:
    - NEVER load multiple step files simultaneously.
    - ALWAYS read the ENTIRE current step file before taking any action.
    - NEVER skip steps or optimize the sequence.
    - NEVER read future step files until this step's gate artifact is complete.
  </critical>

  <sequence_verification>
    <current_state>audit</current_state>
    <unlocked_file>references/01-audit-existing.md</unlocked_file>
    <locked_files>
      <file>references/02-design-skill.md</file>
      <file>references/03-write-skill.md</file>
      <file>references/04-validate-skill.md</file>
      <file>references/05-quality-gate.md</file>
      <file>references/compatibility-matrix.md</file>
    </locked_files>
    <strict_inhibition>
      Do not read design, write, validate, or compatibility guidance until AUDIT-GATE is produced,
      except when audit exposes an immediate runtime compatibility conflict that cannot be stated without the matrix.
    </strict_inhibition>
    <premature_load_recovery>
      If any later phase is already loaded, treat it as locked, continue audit from this file only,
      and report the premature read in final validation.
    </premature_load_recovery>
  </sequence_verification>

  <objective>
    Establish the target runtime, target path, existing conventions, dependencies, and migration risks before design.
  </objective>

  <steps>
    <step id="1" name="identify-runtime">
      Identify the target skill runtime: Harness/OpenCode, AgentSkills, Claude, OpenAI Codex,
      GitHub Copilot, VS Code Copilot, or a runtime-specific adapter.
    </step>
    <step id="2" name="confirm-target">
      Confirm the target skill directory and intended name before editing.
    </step>
    <step id="3" name="inspect-local-conventions">
      Inspect the current SKILL.md, adjacent skills in the same category, and adapter or symlink conventions.
    </step>
    <step id="4" name="discover-supporting-files">
      Find supporting directories: references/, assets/, scripts/, and runtime-specific metadata files.
    </step>
    <step id="5" name="detect-conflicts">
      Detect older propositions, drafts, duplicated instructions, or naming collisions that could conflict with the canonical skill.
    </step>
  </steps>

  <proportional_audit>
    <case change="small edit to one existing skill">Read the target SKILL.md and one adjacent skill.</case>
    <case change="new skill">Inspect parent category, naming patterns, and at least two adjacent skills.</case>
    <case change="material authoring-standard change">Inspect authoring skills, adapters/symlinks, repo instruction files, and examples across categories.</case>
    <case change="cross-runtime compatibility change">Inspect target runtime docs or local compatibility notes before declaring support.</case>
  </proportional_audit>

  <extraction_signals>
    <signal condition="same procedure appears in 2+ skills" decision="extract to shared skill or reference" />
    <signal condition="detail is needed only in one phase" decision="move to a phase reference" />
    <signal condition="detail is deterministic and repetitive" decision="prefer a script" />
    <signal condition="detail is runtime-critical" decision="keep it in SKILL.md" />
    <signal condition="detail is volatile file inventory" decision="replace with discovery instructions" />
    <signal condition="detail is platform-specific" decision="mark as runtime-specific and avoid making it universal" />
  </extraction_signals>

  <gate_artifact name="AUDIT-GATE">
    <requirement>Target runtime(s).</requirement>
    <requirement>Target path and expected directory name.</requirement>
    <requirement>Existing style to preserve or intentionally change.</requirement>
    <requirement>Dependencies and supporting files that must remain reachable.</requirement>
    <requirement>Known conflicts or migration risks.</requirement>
  </gate_artifact>
</workflow_step>
```
