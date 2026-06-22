---
name: skill-authoring
description: "Create, audit, and improve AgentSkills-compatible SKILL.md files through a gated progressive workflow. Use when authoring skills, changing skill structure, validating skill metadata, or deciding what belongs in references/assets/scripts."
---

<skill>
  <purpose>
    Create and maintain `SKILL.md` files through a progressive workflow that loads only the phase guidance needed for the current job.

    Hard constraint: every mandatory runtime behavior must be present in the target `SKILL.md`; supporting files may add detail, examples, templates, or validation logic, but must not be the only place where required behavior is defined.
  </purpose>

  <critical>
    <critical>Never load more than one phase reference file at a time.</critical>
    <critical>Load the next phase reference only after the prior phase gate is satisfied.</critical>
    <critical>Do not pre-read, glob, or scan future `references/` files to prepare.</critical>
    <critical>If a future phase file is needed, write the current gate artifact first, then transition states.</critical>
    <critical>If phase references are loaded out of order or in bulk, report process failure in the final output.</critical>
    <critical>Maintain a phase log: phase name, reference file loaded, gate evidence, and pass/fail result.</critical>
    <critical>World-class mode is the default: after validation, run a quality gate and improve until the skill earns its tokens.</critical>
    - **Preserve AgentSkills portability.** Default to YAML frontmatter plus Markdown-compatible body text; XML-style blocks are allowed as the local semantic layer when they remain readable as Markdown.
    - **Keep routing metadata minimal and precise.** Frontmatter `description` must state what the skill does and when to use it; do not bury activation criteria only in the body.
    - **Avoid hidden dependencies.** Any required script, reference, asset, policy, or platform extension must be named in `SKILL.md`.
    - **Treat skills as privileged artifacts.** Scripts, shell commands, external calls, destructive operations, credentials, and data-exfiltration risks require explicit safety notes and approval boundaries.
    - **Classify claims.** Mark requirements as Loader requirement, Evidence-supported heuristic, or Project convention when the distinction affects portability or enforcement.
  </critical>

  <workflow>
    <step id="1" name="audit">
      State: `audit`.
      Goal: understand the existing skill, adjacent conventions, loader target, and reuse opportunities before writing.

      Unlocked file: read exclusively `references/01-audit-existing.md` when creating a new skill, materially changing an existing skill, or reconciling conventions. Do not read any other file in `references/` during this state. Skip deep audit only for tiny edits to a known skill.

      Gate artifact: `AUDIT-GATE` stating target runtime, target directory/name, adjacent examples, and whether supporting files already exist.
    </step>

    <step id="2" name="design">
      State: `design`.
      Goal: decide skill scope, metadata, body structure, progressive-loading boundaries, safety posture, and AgentSkills compatibility target.

      Unlocked file: read exclusively `references/02-design-skill.md` only after `AUDIT-GATE` exists. `references/compatibility-matrix.md` is also unlocked only if runtime compatibility decisions are needed in this state. Do not read write or validate phase files yet.

      Gate artifact: `DESIGN-GATE` stating exact skill name, description trigger, required body blocks, supporting files, scripts/assets/references, validation plan, and compatibility exceptions.
    </step>

    <step id="3" name="write">
      State: `write`.
      Goal: create or update `SKILL.md` and any referenced supporting files with concise, operational instructions.

      Unlocked file: read exclusively `references/03-write-skill.md` only after `DESIGN-GATE` exists. Do not read the validate phase file yet.

      Gate artifact: `WRITE-GATE` stating written files contain all mandatory behavior, name every referenced dependency, and keep optional detail outside the runtime-critical path.
    </step>

    <step id="4" name="validate">
      State: `validate`.
      Goal: verify metadata, structure, supporting-file reachability, safety notes, and compatibility with the selected runtimes.

      Unlocked file: read exclusively `references/04-validate-skill.md` after `WRITE-GATE` exists. Run `scripts/validate-skill.py` for deterministic checks when Python is available.

      Gate artifact: `VALIDATION-GATE` reporting zero blocking errors or explicitly documenting accepted runtime-specific deviations.
    </step>

    <step id="5" name="quality-gate">
      State: `quality`.
      Goal: judge whether the skill is worth loading, detect description/body drift, and apply the smallest improvements needed for world-class quality.

      Unlocked file: read exclusively `references/05-quality-gate.md` after `VALIDATION-GATE` exists. Do not treat deterministic validation as completion until this quality gate passes.

      Gate artifact: `QUALITY-GATE` reporting description drift, knowledge-delta ratio, pattern fit, rubric score, improvement list, applied/declined fixes, and final pass/fail verdict.
    </step>
  </workflow>

  <phase_state_machine>
    This skill is a locked state machine, not a reading list.

    | Current State | Required Gate Artifact | Only Newly Unlocked File(s) | Locked Until Later |
    |---------------|------------------------|-----------------------------|--------------------|
    | `audit` | none | `references/01-audit-existing.md` | Phase 2, 3, 4, 5 references; compatibility matrix unless audit identifies compatibility conflict |
    | `design` | `AUDIT-GATE` | `references/02-design-skill.md`; `references/compatibility-matrix.md` only if compatibility decisions are required | Phase 3, 4, and 5 references |
    | `write` | `DESIGN-GATE` | `references/03-write-skill.md` | Phase 4 and 5 references |
    | `validate` | `WRITE-GATE` | `references/04-validate-skill.md`; `scripts/validate-skill.py` | Phase 5 reference |
    | `quality` | `VALIDATION-GATE` | `references/05-quality-gate.md` | none |

    If a future file is needed before its gate, the correct action is to write the current gate artifact first, then transition states. Do not shortcut the state machine.
  </phase_state_machine>

  <progressive_loading>
    | Level | Content | Load Timing |
    |-------|---------|-------------|
    | 1 — Metadata | YAML `name`, `description`, and optional compatibility metadata | Always visible to skill router |
    | 2 — Orchestrator | This `SKILL.md`: purpose, critical rules, workflow gates, phase state machine | On skill activation |
    | 3 — Phase references | One workflow phase reference file at a time | Only after that phase's predecessor gate artifact exists |
    | 3 — Compatibility matrix | `references/compatibility-matrix.md` | During design or validation only when runtime compatibility decisions require it |
    | 3 — Scripts | `scripts/validate-skill.py` | During validation only |
    | 3 — Quality gate | `references/05-quality-gate.md` | After deterministic validation passes or deviations are explicitly accepted |

    Prefer discovery patterns over stale inventories. Do not list, glob, or read the full `references/` directory as preparation; use the active state to determine the single unlocked file.
  </progressive_loading>

  <agentskills_compatibility>
    `references/compatibility-matrix.md` is locked until design or validation needs runtime compatibility decisions. Apply these baseline AgentSkills rules unless the target runtime explicitly differs:

    - `SKILL.md` is in a skill directory and begins with YAML frontmatter.
    - `name` is required, lowercase alphanumeric with hyphens, no spaces, max 64 characters, and matches the directory name.
    - `description` is required, max 1024 characters, front-loads trigger keywords, and states both what the skill does and when to use it.
    - Recommended optional metadata includes `license`, `compatibility`, `metadata`, and `allowed-tools` when supported by the target runtime.
    - Supporting files belong in `references/`, `assets/`, or `scripts/`; they must be referenced from `SKILL.md` or the agent may never load them.
    - Keep the main `SKILL.md` concise: target under 500 lines or roughly 5000 tokens unless the runtime has a different measured limit.
    - Prefer one-level relative references from `SKILL.md`; avoid fragile deep paths.
    - Validate with the target runtime validator when available, such as `skills-ref validate`, plus this repository's local checks.
  </agentskills_compatibility>

  <body_format>
    Use YAML frontmatter for loader metadata. Use Markdown-compatible body content for portability.

    Local convention: XML-style semantic blocks such as `&lt;skill&gt;`, `&lt;purpose&gt;`, `&lt;critical&gt;`, `&lt;workflow&gt;`, and `&lt;validation&gt;` may structure the body when they clarify boundaries, sequencing, or trust levels. Do not claim XML is scientifically proven superior to Markdown; treat it as an internal semantic layer.

    Markdown lists, tables, and fenced code blocks are allowed inside XML-style blocks. Phase reference files use fenced XML workflow documents with repeated mandatory execution rules. Escape illustrative tag names in prose as `&lt;tag&gt;` when deterministic tag validation would otherwise treat them as real tags.
  </body_format>

  <phase_lookup>
    Protective lock: these are not startup reading materials. Treat each path as locked unless the workflow state above explicitly unlocks it.

    - Step 1 unlocks `references/01-audit-existing.md`.
    - Step 2 unlocks `references/02-design-skill.md`; it may also unlock `references/compatibility-matrix.md` when compatibility decisions are required.
    - Step 3 unlocks `references/03-write-skill.md`.
    - Step 4 unlocks `references/04-validate-skill.md` and may use `scripts/validate-skill.py`.
    - Step 5 unlocks `references/05-quality-gate.md`.
  </phase_lookup>

  <output_contract>
    When authoring or auditing a skill, finish with:

    - **Changed**: files created or modified.
    - **Compatibility**: target runtimes and any deviations from AgentSkills baseline.
    - **Phase log**: each phase reference loaded, gate evidence, and whether progressive loading passed.
    - **Validation**: checks run and results.
    - **Quality gate**: drift verdict, rubric score, knowledge-delta ratio, applied improvement list, and final pass/fail.
    - **Phase discipline**: gate artifacts produced and any premature reference reads reported.
    - **Follow-up**: only unresolved risks or optional migrations.
  </output_contract>
</skill>
