```xml
<locked_reference id="agentskills-compatibility-matrix">
  <critical>
    MANDATORY EXECUTION RULES:
    - NEVER load this file as a startup reference.
    - NEVER load this file during audit or write unless the active step explicitly unlocks it.
    - ALWAYS read the ENTIRE file before applying compatibility guidance.
    - Treat vendor guidance as runtime compatibility evidence, not proof that one instruction format universally improves model performance.
  </critical>

  <sequence_verification>
    <allowed_states>
      <state>design</state>
      <state>validate</state>
    </allowed_states>
    <design_use>Load only when target runtime compatibility, optional metadata, or publishing portability decisions are required.</design_use>
    <validate_use>Load only to verify declared compatibility or runtime-specific deviations.</validate_use>
    <premature_load_recovery>If loaded during audit or write, ignore it until an allowed state and report the premature read in VALIDATION-GATE.</premature_load_recovery>
  </sequence_verification>

  <baseline_agentskills_rules>
    <rule area="container" status="loader requirement">Skill is a directory with SKILL.md.</rule>
    <rule area="frontmatter" status="loader requirement">YAML frontmatter starts the file.</rule>
    <rule area="name" status="loader requirement">Required; lowercase alphanumeric plus hyphen; max 64; matches directory.</rule>
    <rule area="description" status="loader requirement">Required; max 1024; says what the skill does and when to use it.</rule>
    <rule area="body" status="loader requirement">Markdown-compatible instructions.</rule>
    <rule area="supporting files" status="loader requirement">references/, assets/, and scripts/ load on demand.</rule>
    <rule area="file references" status="loader requirement">Supporting files must be referenced from SKILL.md.</rule>
    <rule area="size" status="evidence-supported heuristic / convention">Prefer SKILL.md under 500 lines or about 5000 tokens.</rule>
    <rule area="paths" status="portability convention">Prefer simple one-level relative references.</rule>
    <rule area="validation" status="loader requirement when available">Use target runtime validator, e.g. skills-ref validate, when available.</rule>
  </baseline_agentskills_rules>

  <optional_metadata>
    <field name="license">Use when publishing or redistributing a skill.</field>
    <field name="compatibility">Use when declaring supported runtimes or versions.</field>
    <field name="metadata">Use when runtime needs structured package metadata.</field>
    <field name="allowed-tools">Use when runtime supports tool permission hints.</field>
    <field name="argument-hint">Use when invocation UI benefits from user-visible arguments.</field>
    <field name="user-invocable">Use when runtime supports hiding or disabling explicit invocation.</field>
    <field name="disable-model-invocation">Use when runtime supports preventing automatic model invocation.</field>
  </optional_metadata>

  <runtime_notes>
    <runtime name="AgentSkills open standard">
      <strong_alignment>Directory bundle, YAML frontmatter, Markdown body, progressive disclosure.</strong_alignment>
      <watchout>XML-style body is acceptable only if Markdown-compatible and parser-neutral.</watchout>
    </runtime>
    <runtime name="Anthropic Claude / Claude Code">
      <strong_alignment>Skills use SKILL.md, frontmatter, Markdown body, optional scripts/resources; Anthropic prompt docs support XML tags for boundaries.</strong_alignment>
      <watchout>Public skill templates are Markdown-first; do not claim XML body is the Anthropic skill norm.</watchout>
    </runtime>
    <runtime name="OpenAI Codex skills">
      <strong_alignment>AgentSkills-compatible; progressive disclosure; description quality is important; supports optional agents/openai.yaml.</strong_alignment>
      <watchout>Keep descriptions concise and trigger-front-loaded; test invocation prompts.</watchout>
    </runtime>
    <runtime name="GitHub / VS Code Copilot skills">
      <strong_alignment>AgentSkills-compatible; project and personal skill locations; additional files must be referenced.</strong_alignment>
      <watchout>Invalid names may fail silently in some tools; review shared scripts for security.</watchout>
    </runtime>
    <runtime name="Harness / OpenCode local convention">
      <strong_alignment>YAML frontmatter plus XML-style semantic body for high-rigor internal skills.</strong_alignment>
      <watchout>Must remain adapter-compatible and should not be claimed as repo-wide until migrated.</watchout>
    </runtime>
  </runtime_notes>

  <compatibility_decision_rule>
    <rule>If publishing outside this repo, optimize for YAML frontmatter plus conventional Markdown body unless XML-style blocks are accepted by the target runtime.</rule>
    <rule>If staying inside Harness/OpenCode, XML-style semantic blocks may be used for boundary clarity, but preserve Markdown readability.</rule>
    <rule>If a runtime has a stricter parser, follow the runtime over local style.</rule>
  </compatibility_decision_rule>
</locked_reference>
```
