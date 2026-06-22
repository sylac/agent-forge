---
name: skill-authoring
description: Author or refactor a SKILL.md in this repo's house style. Use when the user says "write a skill for X", wants to turn current context into a skill, or wants to fix an existing skill.
---

Write a skill as a recipe with a stop condition, not an essay.

## Audience

The reader is a peer — a state-of-the-art coding agent. It already knows how to read files, talk to users, ground claims, and not hallucinate. The skill carries only what that reader can't already know:

- **Project-specific facts** — paths, IDs, naming conventions, template shapes, frontmatter rules, scripts
- **Load-bearing rules** with concrete failure scars from this project
- **The terminating condition**

Cut everything else. No generic warnings, no rationale tails, no concept lectures.
## Never include

Preambles, changelogs, "about this skill", emoji, tool-call examples, harness internals, rationale essays, or restatements of the frontmatter.

## When editing an existing skill

Keep the new rule proportional to its weight in the whole skill. DO NOT add a dedicated section, anti-pattern, or multi-bullet block for a sub-rule that fits in one line of an existing list. Litmus: if the edit is longer than the rule it constrains, collapse it.

## Anti-Pattern: The Explainer Skill

A skill is not documentation. Warning signs: paragraphs the agent could skip without losing an instruction, hedging ("you should consider…"), no terminating condition, no embedded artefact.

## Process

### 1. Pin down trigger, anti-trigger, terminating action

Ask the user if any are unclear. If you can't name a concrete terminating action, the skill is too vague — narrow it.

### 2. Draft frontmatter

```yaml
---
name: <kebab-case>
description: <20–40 words: what it does. Use when <trigger phrasings>.>
---
```

Description is a routing signal only — no output format, file paths, or internal steps.

### 3. Write the body

- **Opening sentence**: purpose + sharpest constraint, before any heading.
- **Anti-pattern section**: `## Anti-Pattern: <Memorable Name>` — name a directional drift the model actually has under pressure (e.g. agreeableness, over-eager edits), not the logical negation of the opening sentence. If every warning sign just inverts a rule you already stated, cut the section. 1–3 signs; stop when they stop adding a *new* failure.
- **Steps**: imperative verbs, one quoted example utterance per user-facing step, user checkpoint before irreversible actions.
- **Templates/artefacts**: at the bottom in XML-ish fences (`<template-name>`). Copy-targets, not paraphrased.
- **Terminating condition**: `## Done when` — one checklist OR one criterion. Not both.

Shape: default to mixed (1-paragraph stance + numbered process). Pure process for linear jobs. Pure stance for ongoing postures.

### 4. Review with user

Show the draft, ask:

- "Does the trigger phrasing match how you actually ask for this?"
- "Is the anti-pattern the right one?"
- "Anything that's explanation rather than instruction?"

Write to `.agents/skills/<name>/SKILL.md` only after approval.

### 5. Subagent review

Spawn a fresh subagent as "strict skill-authoring reviewer" — read the SKILL.md against the Done-when checklist below, report failures. Fix and re-run until clean.

## Sibling files

Default to a single `SKILL.md`. Add siblings only when they own a distinct concern:

- `REFERENCE.md` — load-bearing concept with its own depth
- `scripts/` — deterministic operations the agent would otherwise regenerate each run

## Done when

```
[ ] User approved trigger phrasing and named anti-pattern
[ ] Description: 20–40 words, pure routing signal, ends in "Use when …"
[ ] Every rule traces to a project-specific failure scar — no generic warnings
[ ] No paternalistic prose, no rationale tails, no concept lectures, no anti-pattern that merely negates the opening sentence
[ ] One terminating condition with user checkpoint before irreversible action
[ ] Subagent review: zero failures
```

<skill-skeleton>

---
name: <kebab-case>
description: <capability sentence>. Use when <trigger phrasings>.
---

<One sentence: purpose + sharpest constraint.>

## Anti-Pattern: <Memorable Name>

<2–4 warning signs.>

## Process

### 1. <Verb> <object>

…

### N. <Terminating action>

## Done when

<Checklist or single criterion.>

<template-name>

<Artefact body.>

</template-name>

</skill-skeleton>
