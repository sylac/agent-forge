---
name: skill-authoring
description: "Anatomy template, progressive loading model, and quality checklist for authoring skill files (SKILL.md). Load when creating, auditing, or improving any skill file."
---

# Skill Authoring

This skill provides the canonical structure, progressive loading model, and quality gates for `SKILL.md` files.

**Hard constraint:** all mandatory authoring rules are embedded here; do not rely on platform-specific auto-loaded instruction files.

**Evidence basis** — each rule below is tagged:

- **[Loader]** — required by skill-loader/runtime behavior (Anthropic Claude Code Skills, OpenAI Skills).
- **[Heuristic]** — supported by published prompt-engineering research/vendor guidance, but effects vary.
- **[Convention]** — local project convention for consistency and reviewability; not a universal law.

---

## Skill File Anatomy

Required sections in order:

1. **Frontmatter** [Loader] — `name` (must match directory name), `description` (what it does + when to load); used by the loader for discovery and routing.
2. **H1 + Purpose paragraph** [Convention] — what capability it enables, where it applies, and one hard constraint; add persona/role only when domain behavior or voice materially changes.
3. **Middle reference sections** [Convention] — tables, matrices, examples; lookup material that does not need to fire first.
4. **Final checklist / output contract** [Heuristic] — anchors the end of the file.

---

## Critical Constraints

- **Audit first** [Convention] — for new skills or material changes, inspect existing instruction, agent, and skill folders; for small edits a quick scoped check is sufficient.
- **No hidden dependency** [Loader] — declare every required script, asset, reference, env var, or external resource; do not depend on auto-applied instruction files for required behavior.
- **Privileged artifact** [Loader] — treat skills as executable/instructional artifacts: no untrusted external content, no implicit side effects, require explicit approval steps for risky actions.
- **Context economy** [Heuristic] — keep the main skill concise; move long optional references to supporting files; preserve clarity over aggressive compression.
- **Extract before embed** [Heuristic] — content reusable across 2+ task paths belongs in a skill, not repeated inline; embed the critical execution path, extract long optional references.
- **Avoid accidental duplication** [Heuristic] — duplicated context wastes tokens and creates contradictions; intentionally repeat only safety-critical or routing-critical constraints.
- **Trigger locality** [Loader] — metadata `description` is primary for routing; the body may mention scope only if it affects execution after load.
- **Persona restraint** [Heuristic] — prefer concrete behavior, scope, and constraints over generic identity; use role/persona only for domain-specific framing or required voice.

---

## Context Engineering Rules

| Rule | Basis | Requirement |
|------|-------|-------------|
| Primacy | [Heuristic] | Place critical operating rules early; do not bury essential instructions in long middle sections |
| Recency | [Heuristic] | Place final verification, output contract, or checklist late |
| Middle | [Heuristic] | Reserve middle for lookup tables, matrices, and examples; do not put critical rules there alone |
| Delimiters | [Heuristic] | Use headers, tables, and code fences where boundaries matter |
| Density | [Heuristic] | Prefer concise, explicit instructions over terse instructions |
| Portability | [Convention] | Do not depend on platform-specific path-scoped auto-loading (VS Code/Cursor/OpenCode) |
| Freshness | [Heuristic] | Prefer discovery patterns over static file inventories that go stale |
| Trigger locality | [Loader] | Activation criteria in metadata; execution rules in body |

Information placement:

| Position | Content |
|----------|---------|
| Top — primacy | Purpose, scope, core responsibilities, critical constraints |
| Middle | Reference tables, decision matrices, taxonomy, code examples |
| Bottom — recency | Output format / validation checklist |

---

## Writing Rules

| Rule | Do | Don't |
|------|----|-------|
| Imperative voice | "Read the file" | "You should read the file" |
| Specific | "List `.harness/skills/`" | "Look at the codebase" |
| Affirmative wording | "Confirm before writing" | (reserve explicit prohibitions for safety/destructive actions) |
| Code examples | Minimal canonical example showing the unique construct | Imports, scaffolding, or examples for obvious behavior |
| Tables vs prose | Tables for small structured comparisons | Tables for nested logic or multi-step procedures |
| Long reference prose | Move to supporting files | Inline multi-paragraph background |
| Load triggers | Put in frontmatter `description` | Repeat "load/use when..." in body |
| Persona | "Review OAuth flows for token leakage" | "You are a world-class security guru" |

---

## Workspace Audit Pattern

Tier the audit to the change size:

| Change | Audit |
|--------|-------|
| Small edit to existing skill | Skim the skill and its direct neighbors |
| New skill or major rewrite | List instruction sources, agent definitions, sibling skills; verify target parent folder, name, trigger description, references, assets, scripts |
| Cross-cutting refactor | Full audit + extraction matrix on shared content |

Mark already-loaded content as **do not duplicate**.

---

## Skill Extraction Matrix

Apply for medium/large skills or when content overlaps multiple agents.

| Signal | Decision |
|--------|----------|
| Content appears in ≥2 agent/task paths | Extract to skill |
| Content is already auto-applied by platform | Exclude; cite as loaded context |
| Content is domain-specific, not general model knowledge | Include in skill |
| Content is model-general boilerplate | Exclude; reference by name only |
| Content is a long static reference | Compress to table or move to on-demand reference |
| Content explains *why* only | Convert to operational *what to do* or exclude |

---

## Progressive Loading Model [Loader]

Design every skill for this loading hierarchy:

| Level | Content | When Available |
|-------|---------|----------------|
| 1 — Metadata | `name`, `description` frontmatter | Always in context for routing |
| 2 — SKILL.md body | Workflows, patterns, critical execution path | On skill invocation |
| 3 — `references/` | Detailed docs, schemas | On demand (must be reliably readable) |
| 3 — `assets/` | Templates, output files | On demand |
| 3 — `scripts/` | Executable code | On demand |

Keep the critical execution path in the main skill; level-3 resources must be explicitly named and testable.

Compression patterns:

| Before | After |
|--------|-------|
| 5-sentence prose on one concept | Compact table |
| 12-line code block with scaffolding | Snippet showing only the unique construct |
| Static list of file paths | Discovery pattern: "List `.harness/skills/`" |

---

## Skill Validation

Before publishing a nontrivial skill, run:

1. **Routing test** — confirm the `description` triggers the skill on representative prompts.
2. **Invocation test** — load the skill and verify the body is sufficient without hidden context.
3. **Dependency test** — exercise each referenced file, asset, and script.
4. **Checklist pass** — section below.

---

## Quality Checklist — Skill Files

- [ ] Single topic — exactly one domain or capability
- [ ] `name` matches parent directory name exactly
- [ ] `description` includes what it does + when to load
- [ ] Purpose paragraph present as first paragraph; persona/role omitted unless specifically justified
- [ ] Body does not repeat frontmatter when-to-load or activation criteria
- [ ] Critical constraints in the first third of the file
- [ ] All dependencies declared (scripts, assets, references, env, external resources)
- [ ] No dependency on hidden or auto-applied instruction files
- [ ] Workspace audit appropriate to change size
- [ ] Context Engineering Rules applied
- [ ] Skill Extraction Matrix applied to reusable/large content
- [ ] Writing Rules applied: imperative, specific, affirmative
- [ ] Long reference prose moved to supporting files
- [ ] Tables used for small structured comparisons; procedures kept as steps
- [ ] Code examples are minimal and canonical
- [ ] Skill Validation passed (routing, invocation, dependency)
- [ ] Final checklist / output contract is the last section
