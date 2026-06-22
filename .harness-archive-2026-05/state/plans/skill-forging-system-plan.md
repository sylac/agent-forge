# Harness Skill Forging System Plan

## Status

Planning artifact. This document defines the target design for making skill authoring, hardening, and benchmarking part of the Harness system. It does not by itself implement the workflow.

## Goal

Create a Harness-native skill forging flow that lets a user work inside OpenCode, explicitly load the relevant skill/workflow, improve skills through a SkillForge-like review loop, and prove whether changes improve or regress behavior across model candidates.

The user should not manually write benchmark YAML, fixture schemas, or model-comparison boilerplate. The agent should generate those artifacts from skill changes, real session feedback, and explicit benchmark requests.

## Core Architecture

```text
thin commands = explicit doors into the workflow
skill-authoring = single canonical forge workflow
05-quality-gate.md = quality judge, HITL improvement loop, regression gate
.harness/evals = generated evidence, cases, reports, and model matrix
```

Do not create separate skills for create/update/audit/harden/benchmark. Keep `skill-authoring` as the canonical workflow and use thin command entrypoints only for explicit routing.

## Existing Foundation

The current `.harness/skills/meta/skill-authoring/SKILL.md` already defines the right lifecycle:

```text
audit -> design -> write/update -> validate -> quality-gate
```

The existing `references/05-quality-gate.md` already includes the correct SkillForge-like base:

- recap and description/body drift check
- knowledge-delta scan
- pattern-fit review
- 100-point rubric with 85-point threshold
- numbered improvements with evidence
- smallest sufficient change principle

Therefore, the correct implementation is an extension/refactor of `skill-authoring`, not a parallel `skill-hardening` system.

## Command Entry Points

Commands are convenience launchers. They must not duplicate skill logic.

Recommended command files:

```text
.harness/commands/create-skill.md
.harness/commands/update-skill.md
.harness/commands/audit-skill.md
.harness/commands/harden-skill.md
.harness/commands/benchmark-skill.md
```

Each command should only declare:

1. Load skill: `skill-authoring`
2. Entry intent
3. Required starting phase
4. Required stopping condition
5. Required opening announcement

Example command contract:

```md
# Harden Skill

1. Load skill: `skill-authoring`.
2. Entry intent: harden an existing skill from observed failure.
3. Start phase: `audit`.
4. Continue through validation, quality gate, and regression gate.
5. User provides plain-language failure description.
6. Announce loaded skill, entry intent, target skill, and starting phase before proceeding.
```

Expected OpenCode interaction:

```text
/harden-skill scientific-web-research "It stopped after one source and did not iterate."
```

Required agent announcement:

```text
Loaded skill: skill-authoring
Entry intent: harden existing skill from observed failure
Target skill: scientific-web-research
Starting phase: audit
```

## Skill Workflow Semantics

`skill-authoring` should remain one coherent capability:

> Create, audit, improve, harden, and regression-prove Harness/OpenCode skills through a gated skill-forging workflow.

Avoid representing create/update/audit/harden/benchmark as separate internal modes. Treat them as entry intents that select the earliest required phase and required stopping condition.

| Entry intent | Start phase | Required stopping condition |
| --- | --- | --- |
| create new skill | audit | quality gate passes |
| update existing skill | audit or design, depending on scope | quality gate passes |
| audit skill | audit | quality verdict produced |
| harden from failure | audit | quality gate and regression gate pass |
| benchmark skill/model | validate | regression report produced |

For material skill changes, validation alone is insufficient. The workflow must reach the quality gate. For feedback-driven changes, the workflow must also produce regression evidence.

## Required `skill-authoring` Refactor

Update `.harness/skills/meta/skill-authoring/SKILL.md` to clarify:

- command entrypoints may invoke this skill with an entry intent
- entry intent chooses the earliest required phase
- all material edits must pass validation and quality gate
- feedback-driven edits must capture regression evidence
- benchmark requests use the same workflow and do not become a separate skill
- command entrypoints are routing only; `skill-authoring` remains canonical

The phase state machine should remain intact. Do not weaken the existing progressive-loading rule that only one phase reference is loaded at a time.

## Required `05-quality-gate.md` Extension

Extend `references/05-quality-gate.md` with a new `behavioral-regression-gate` section.

The regression gate is required when any of these conditions are true:

- the user reports a real skill failure
- the skill behavior changes materially
- the user asks whether a change made the skill better or worse
- the user asks to benchmark a skill against models
- the user asks whether a model still satisfies the skill requirements

Regression gate sequence:

1. Capture observed failure from user feedback and, when available, OpenCode session evidence.
2. Distill the failure into a stable behavioral requirement.
3. Generate one or more regression cases automatically.
4. Identify expected behavior, forbidden behavior, and rubric criteria.
5. Run or prepare the benchmark against configured model candidates.
6. Compare current skill behavior against proposed skill behavior when applicable.
7. Include regression result in the final `QUALITY-GATE` verdict.

The user should approve skill edits through the existing numbered improvement loop. The user should not manually author regression YAML.

## Generated Evaluation Artifacts

Generated artifacts should live under `.harness/evals`.

Recommended structure:

```text
.harness/evals/
  models.yaml
  skills/
    <skill-name>/
      captures/
      cases/
      reports/
      proposals/
```

Artifact roles:

- `models.yaml`: checked-in model registry for baseline, candidate, canary, and retired models.
- `captures/`: raw or summarized evidence from OpenCode sessions and user feedback.
- `cases/`: generated regression cases derived from failures or requirements.
- `reports/`: benchmark and comparison outputs.
- `proposals/`: candidate skill patches or improvement plans before application.

Example generated case content:

```yaml
requirement: "Research skill must continue iterating when evidence gaps remain."
observed_failure: "Stopped after one source."
expected_behavior: "Identify evidence gap, search again, compare sources, and state limits."
forbidden_behavior: "Final answer after a single weak source when the task requires synthesis."
source: opencode-session
```

This YAML is generated by the workflow. It is not user-authored.

## SkillForge Ideas to Adopt

Adopt these patterns from SkillForge:

- recap before editing
- judge before declaring done
- knowledge-delta scoring
- every non-obvious `NEVER` needs an `INSTEAD` and `WHY`
- numbered improvements sorted by impact
- one-change-at-a-time HITL approval
- audit reports sorted by severity
- skills are continuously refined, not considered finished just because they parse

Do not adopt these SkillForge assumptions:

- Claude-specific plugin layout
- global `~/.claude/skills` as source of truth
- judge-only quality as final proof
- skill quality without behavioral regression evidence

Harness adds the missing layer:

- `.harness/skills` remains source of truth
- OpenCode session evidence can feed regression cases
- Promptfoo/Inspect-compatible benchmark artifacts can be generated
- model comparison is part of the workflow
- commands are thin OpenCode entrypoints, not standalone systems

## Benchmark Backend Strategy

Promptfoo should be the first benchmark backend for skill/model regression because it supports local configs, model matrices, deterministic assertions, model-graded rubrics, and CI gates.

Inspect AI should be introduced for deeper multi-step, tool-use, sandboxed, or trajectory-heavy benchmarks after the Promptfoo path is working.

Backend selection should remain hidden behind Harness artifacts and skill workflow. The user interacts with OpenCode and the skill authoring flow, not directly with backend config files.

## Implementation Phases

### Phase 1: Skill-first Forge UX

- Add thin command entrypoints for create/update/audit/harden/benchmark.
- Update `skill-authoring` to define entry intents and required stopping conditions.
- Preserve existing phase-gated progressive loading.
- Require opening announcement of loaded skill, entry intent, target, and phase.

### Phase 2: Quality Gate Refactor

- Extend `05-quality-gate.md` with behavioral regression gate rules.
- Add requirement that feedback-driven changes produce regression evidence.
- Add explicit SkillForge-style HITL wording for numbered improvements.
- Ensure `QUALITY-GATE` reports both quality score and regression status.

### Phase 3: Generated Eval Artifacts

- Create `.harness/evals` structure.
- Define `models.yaml` registry.
- Generate captures, cases, reports, and proposals from feedback-driven hardening.
- Keep generated artifacts reviewable but not manually authored.

### Phase 4: Promptfoo Integration

- Generate Promptfoo-compatible cases from `.harness/evals/skills/<skill>/cases`.
- Run skill-vs-skill and model-vs-model comparisons.
- Store reports under `.harness/evals/skills/<skill>/reports`.
- Fail quality gate when regression score drops below threshold.

### Phase 5: Inspect AI for Complex Skills

- Add Inspect AI only for skills requiring multi-step tool execution, sandboxing, or trajectory scoring.
- Keep Promptfoo as the default fast regression gate.

## Non-Goals

- Do not create a second skill-hardening skill.
- Do not require the user to write YAML by hand.
- Do not make Promptfoo or Inspect the user-facing workflow.
- Do not make `.opencode/skills` source of truth.
- Do not weaken existing phase-gated progressive loading.
- Do not treat parser validation as proof of skill quality.

## Definition of Done

The skill forging system is ready when:

- a user can invoke a clear OpenCode command such as `/harden-skill ...`
- the agent announces loaded skill, entry intent, target, and phase
- `skill-authoring` remains the only canonical workflow
- material changes pass validation and quality gate
- feedback-driven changes generate regression evidence automatically
- benchmark reports can compare skill versions and model candidates
- generated artifacts are stored in `.harness/evals`
- the user can decide in chat whether to apply numbered improvements
