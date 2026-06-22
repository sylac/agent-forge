```xml
<workflow_step id="design-skill" phase="design" gate="DESIGN-GATE">
  <critical>
    MANDATORY EXECUTION RULES:
    - NEVER load multiple step files simultaneously.
    - ALWAYS read the ENTIRE current step file before taking any action.
    - NEVER skip steps or optimize the sequence.
    - NEVER read future step files until this step's gate artifact is complete.
  </critical>

  <sequence_verification>
    <current_state>design</current_state>
    <required_prior_gate>AUDIT-GATE</required_prior_gate>
    <stop_condition>
      If AUDIT-GATE is missing, this file was loaded prematurely. Return to Phase 1,
      produce AUDIT-GATE, and ignore this file until then.
    </stop_condition>
    <unlocked_file>references/02-design-skill.md</unlocked_file>
    <conditional_unlock>references/compatibility-matrix.md only when target runtime compatibility or optional metadata decisions are required.</conditional_unlock>
    <locked_files>
      <file>references/03-write-skill.md</file>
      <file>references/04-validate-skill.md</file>
      <file>references/05-quality-gate.md</file>
    </locked_files>
  </sequence_verification>

  <objective>
    Decide metadata, scope, body format, progressive split, safety boundaries, and validation plan before writing files.
  </objective>

  <steps>
    <step id="1" name="design-frontmatter">
      <rule field="name">Match the directory exactly; use lowercase letters, numbers, and hyphens; keep under 64 characters for AgentSkills portability.</rule>
      <rule field="description">Front-load trigger terms; state what the skill does and when to use it; keep under 1024 characters.</rule>
      <rule field="optional-agent-skills-metadata">Add license, compatibility, metadata, or allowed-tools only when the target runtime supports or benefits from them.</rule>
      <rule field="runtime-specific-metadata">Isolate fields such as argument-hint, user-invocable, disable-model-invocation, model, effort, context, agent, hooks, paths, or shell behind compatibility notes.</rule>
    </step>
    <step id="2" name="design-scope">
      <rule>One skill should cover one capability or workflow.</rule>
      <rule>Avoid generic model behavior; encode only project-specific or domain-specific procedure.</rule>
      <rule>Prefer concrete behaviors and gates over persona language.</rule>
      <rule>Separate always-needed instructions from phase-only detail.</rule>
    </step>
    <step id="3" name="design-progressive-loading">
      <location content="purpose, non-negotiable rules, workflow gates">SKILL.md</location>
      <location content="detailed phase procedure">A named phase reference file, for example references/02-design-skill.md</location>
      <location content="long examples, schemas, specs">references/</location>
      <location content="reusable output templates">assets/</location>
      <location content="deterministic validation or generation">scripts/</location>
      <constraint>Supporting files must be named in SKILL.md. If the agent cannot discover the file from loaded instructions, the split is invalid.</constraint>
    </step>
    <step id="4" name="design-safety">
      <declare>Destructive edits, deletes, resets, migrations, or irreversible actions.</declare>
      <declare>External network calls, credentialed systems, or data exfiltration risks.</declare>
      <declare>Scripts that execute shell commands or modify files.</declare>
      <declare>Trust boundaries for user-provided, external, or tool-output content.</declare>
    </step>
  </steps>

  <gate_artifact name="DESIGN-GATE">
    <requirement>Exact frontmatter fields.</requirement>
    <requirement>Body format: Markdown headings, XML-style semantic blocks, or a documented hybrid.</requirement>
    <requirement>Required references/assets/scripts and why each is not embedded.</requirement>
    <requirement>Validation plan and target runtime compatibility.</requirement>
    <requirement>Quality gate expectations: pattern fit, knowledge delta, description drift, rubric threshold, and improvement loop.</requirement>
  </gate_artifact>
</workflow_step>
```
