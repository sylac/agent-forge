```xml
<workflow_step id="quality-gate" phase="quality" gate="QUALITY-GATE">
  <critical>
    MANDATORY EXECUTION RULES:
    - NEVER load multiple step files simultaneously.
    - ALWAYS read the ENTIRE current step file before taking any action.
    - NEVER skip this phase for new skills or material skill changes.
    - NEVER treat parser validation as proof of skill quality.
    - NEVER apply bundled improvements without an explicit numbered list and per-item evidence.
  </critical>

  <sequence_verification>
    <current_state>quality</current_state>
    <required_prior_gate>VALIDATION-GATE</required_prior_gate>
    <stop_condition>
      If VALIDATION-GATE is missing, this file was loaded prematurely. Return to Phase 4,
      produce VALIDATION-GATE, and ignore this file until then.
    </stop_condition>
    <unlocked_file>references/05-quality-gate.md</unlocked_file>
    <process_warning>Report any earlier premature phase-reference read, even when the final skill is structurally valid.</process_warning>
  </sequence_verification>

  <objective>
    Raise the skill from valid to world-class by judging whether it earns its tokens, routes correctly, avoids drift, and captures expert-only knowledge.
  </objective>

  <quality_principles>
    <principle name="knowledge-delta">Skill value equals expert knowledge minus what the base model already knows.</principle>
    <principle name="description-is-routing">The description is the only field visible before activation; weak descriptions make strong bodies invisible.</principle>
    <principle name="body-is-ground-truth">Compare frontmatter claims against actual body behavior and references.</principle>
    <principle name="anti-patterns-need-replacements">Every NEVER or prohibition must include a concrete alternative and non-obvious reason when the risk is not self-evident.</principle>
    <principle name="continuous-refinement">A skill is not done when it parses; it is done when review finds no blocking quality gaps.</principle>
  </quality_principles>

  <quality_sequence>
    <step id="1" name="recap-and-drift">
      Read the finished SKILL.md body and independently summarize what it actually does before looking back at the description.
      Compare body behavior to frontmatter description for WHAT, WHEN, keywords, and scope.
      Classify drift as Aligned, Minor drift, or Significant drift.
    </step>

    <step id="2" name="knowledge-delta-scan">
      Mark each major section as Expert, Activation, or Redundant.
      Target at least 70% Expert content. Delete or compress redundant default-model guidance.
    </step>

    <step id="3" name="pattern-fit">
      Classify the skill pattern as Mindset, Navigation, Philosophy, Process, or Tool.
      Verify the chosen structure matches task fragility and freedom level.
    </step>

    <step id="4" name="rubric-score">
      Score the skill on a 100-point world-class gate:
      - Description activation quality: 20
      - Specification and portability compliance: 15
      - Progressive disclosure and dependency reachability: 15
      - Knowledge/instruction delta: 20
      - Anti-pattern quality with Instead/Why where needed: 10
      - Practical usability, examples, and edge cases: 15
      - Safety and trust boundaries: 5
      Passing threshold: 85. Scores below 85 require improvements or an explicit user-approved exception.
    </step>

    <step id="5" name="numbered-improvements">
      Produce a numbered improvement list sorted by impact. Each item must include the evidence, smallest sufficient change, and expected score or behavior improvement.
      Apply improvements one at a time. After each change, verify the finding is false before moving to the next.
      If user approval is required for scope, destructive edits, external calls, or commits, stop and request approval. Do not commit unless explicitly asked.
    </step>
  </quality_sequence>

  <failure_patterns>
    <pattern name="tutorial">Explains basics the model already knows. Fix: keep only expert decisions, trade-offs, edge cases, and local constraints.</pattern>
    <pattern name="dump">Loads all detail in SKILL.md. Fix: keep the critical path in SKILL.md and move conditional detail to referenced files.</pattern>
    <pattern name="orphan-references">References exist but no workflow step names when to read them. Fix: add explicit load triggers and Do Not Load guidance.</pattern>
    <pattern name="invisible-skill">Description lacks WHAT, WHEN, or trigger keywords. Fix: front-load routing terms in description.</pattern>
    <pattern name="vague-warning">Says be careful without naming failure mode. Fix: add specific rule, Instead, and Why.</pattern>
    <pattern name="freedom-mismatch">Over-constrains creative work or under-specifies fragile work. Fix: recalibrate structure to pattern and risk.</pattern>
  </failure_patterns>

  <gate_artifact name="QUALITY-GATE">
    <field name="Description drift">Aligned, Minor drift, or Significant drift with evidence.</field>
    <field name="Knowledge ratio">Expert / Activation / Redundant estimate and major deletions or compressions.</field>
    <field name="Pattern fit">Chosen pattern and freedom calibration.</field>
    <field name="Rubric score">Score out of 100 and pass/fail against 85 threshold.</field>
    <field name="Improvements">Numbered list, applied/declined status, and verification result.</field>
    <field name="Final verdict">World-class pass, conditional pass, or blocked.</field>
  </gate_artifact>
</workflow_step>
```
