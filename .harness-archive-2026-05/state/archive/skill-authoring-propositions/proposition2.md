---
name: skill-authoring
description: "Anatomy template, progressive loading model, and quality checklist for authoring skill files (SKILL.md). Load when creating, auditing, or improving any skill file."
---

# Skill Authoring

This skill provides the canonical structure, progressive loading model, and quality gates for `SKILL.md` files.

**Hard constraint:** all mandatory authoring rules are embedded here; do not rely on platform-specific auto-loaded instruction files.

Use the evidence labels below:

- **Loader requirement** — required by the target skill runtime or repository convention.
- **Evidence-supported heuristic** — supported by official provider guidance or empirical prompt/context research, but not universal.
- **Project convention** — local maintainability rule; change only with explicit repository agreement.

---

## Skill File Anatomy

Recommended sections in order:

1. **Frontmatter** — `name` (required, must match directory name), `description` (required; what it does + trigger conditions)
2. **H1 + Purpose paragraph** — what capability it enables, where it applies, and one hard constraint; add persona/role only when domain behavior or voice materially changes
3. **Reference sections** — workflows, tables, matrices, examples, and links to optional supporting files
4. **`## Quality Checklist`** — final observable checks near the end

---

## Critical Constraints

- **Proportional audit** — before creating or materially changing a skill, inspect existing instruction, agent, and skill conventions; use a quick local check for small edits.
- **No hidden dependency** — do not depend on auto-applied instruction files for required behavior.
- **Context economy** — keep the main skill concise; move long optional details to supporting files, but never compress away required behavior.
- **Extract before embed** — content reusable across 2+ task paths belongs in a skill or shared reference, not repeated inline prose; keep the runtime-critical path in `SKILL.md`.
- **Intentional repetition only** — duplicated context wastes tokens and creates contradictions; repeat only safety-critical or routing-critical constraints deliberately.
- **Trigger locality** — frontmatter `description` is primary routing metadata; body scope notes are allowed only when they change execution after load.
- **Persona restraint** — prefer concrete behavior, scope, and constraints over generic identity; use role/persona only for domain-specific framing or required voice.
- **Skill safety** — declare scripts, external resources, sensitive actions, and trust assumptions; require explicit approval for destructive or data-exfiltrating actions.

---

## Context Engineering Rules

| Rule | Evidence | Requirement |
|------|----------|-------------|
| Primacy | Evidence-supported heuristic | Put purpose, scope, hard constraints, and primary workflow near the top |
| Recency | Evidence-supported heuristic | Put final output contract or checklist near the end |
| Middle | Evidence-supported heuristic | Do not bury critical instructions in long middle sections; use the middle for lower-priority references |
| Delimiters | Evidence-supported heuristic | Use headers, lists, or tables where boundaries matter |
| Density | Evidence-supported heuristic | Prefer concise, explicit instructions over terse or lossy compression |
| Portability | Project convention | Do not depend on VS Code/Cursor/OpenCode path-scoped auto-loading unless the target runtime is explicitly platform-specific |
| Freshness | Evidence-supported heuristic | Prefer discovery patterns over static file inventories that go stale |
| Trigger locality | Loader requirement | Put activation criteria in metadata when the loader routes by metadata; put execution rules in the body |

Information placement:

| Position | Content |
|----------|---------|
| Top — primacy | Purpose, scope, core responsibilities, critical constraints |
| Middle | Lower-priority reference tables, decision matrices, taxonomy, compact examples |
| Bottom — recency | Output format template, domain-specific quality checklist |

---

## Writing Rules

| Rule | Do | Don't |
|------|----|-------|
| Imperative voice | "Read the file" | "You should read the file" |
| Specific | "List `.harness/skills/`" | "Look at the codebase" |
| Constraints | Prefer affirmative instructions; use explicit prohibitions for high-risk actions | Hide safety constraints in vague guidance |
| Code examples | Minimal canonical snippet showing the unique concept | Add imports and scaffolding unless required |
| Long prose | Move background/reference detail to lists, tables, or supporting files | Compress so aggressively that procedure becomes ambiguous |
| Load triggers | Put routing criteria in frontmatter `description` | Repeat generic "load/use when..." boilerplate in body |
| Persona | "Review OAuth flows for token leakage" | "You are a world-class security guru" |

---

## Workspace Audit Pattern

Use audit depth proportional to change size:

1. **Small edit** — inspect the target skill and adjacent examples.
2. **New or material skill change** — list instruction sources, existing agent definitions, and existing skills; extend rather than duplicate.
3. **Before release** — verify target parent folder, skill name, trigger description, references, assets, scripts, and risky actions.

---

## Skill Extraction Matrix

| Signal | Decision |
|--------|----------|
| Content appears in ≥2 agent/task paths | Extract to skill |
| Content is already auto-applied by platform | Exclude from generated file; cite as loaded context |
| Content is domain-specific, not general model knowledge | Include in skill |
| Content is model-general boilerplate | Exclude; reference by name only |
| Content is long static reference data | Compress to a clear table or move to on-demand reference |
| Content explains *why* only | Convert to operational *what to do* or exclude |

---

## Progressive Loading Model

Design every skill for this loading hierarchy when the target runtime supports skill metadata and supporting files:

| Level | Content | When Available |
|-------|---------|----------------|
| 1 — Metadata | `name`, `description` frontmatter | Always in context |
| 2 — SKILL.md body | Workflows, critical path, compact references | On skill load |
| 3 — `references/` | Detailed docs, schemas | On demand |
| 3 — `assets/` | Templates, output files | On demand |
| 3 — `scripts/` | Executable code | On demand |

Core instructions must remain in `SKILL.md`; supporting files are for optional detail only and must be named explicitly.

Compression patterns:

| Before | After |
|--------|-------|
| 5-sentence prose on one concept | 3-row table |
| 12-line code block with scaffolding | 3-line snippet showing only the unique construct |
| Static list of file paths | Discovery pattern: "List the target skill or agent directory" |

---

## Evidence Basis

| Claim Area | Basis | Use In This Skill |
|------------|-------|-------------------|
| Skill metadata and progressive loading | Loader requirement in skill runtimes that route by frontmatter description | Keep `name`, routing-focused `description`, and explicit supporting-file references |
| Clear, specific instructions and delimiters | Evidence-supported heuristic from provider prompt guidance | Use headers, lists, and tables where they clarify boundaries |
| Primacy/recency and middle-risk | Evidence-supported heuristic from long-context position-bias research | Place critical rules early and final checks late; avoid burying essentials |
| Persona/role prompting | Mixed evidence; useful for style/domain framing, unreliable for objective accuracy gains | Prefer purpose and constraints; add persona only with justification |
| Numeric size limits and formatting thresholds | Project convention unless measured against the runtime | Treat as review guidance, not universal law |
| Safety and dependency disclosure | Platform safety guidance and engineering reliability | Declare scripts/resources/risky actions and require approval for sensitive operations |

---

## Validation / Eval Pattern

For nontrivial skills, verify:

1. **Routing test** — the `description` clearly distinguishes when this skill should and should not load.
2. **Invocation test** — after load, the body gives enough instructions to execute without hidden files.
3. **Dependency test** — every referenced script, asset, or reference file exists or has a fallback.
4. **Safety test** — destructive, external, credentialed, or data-exfiltrating actions require explicit approval.
5. **Maintenance test** — volatile facts are discovered from source-of-truth files instead of embedded statically.

---

## Quality Checklist — Skill Files

- [ ] Single topic — exactly one domain or capability
- [ ] `name` matches parent directory name exactly
- [ ] `description` includes trigger conditions (when to load)
- [ ] Purpose paragraph present as first paragraph; persona/role omitted unless specifically justified
- [ ] Body avoids generic load-trigger boilerplate; any scope note changes execution after load
- [ ] Critical constraints in the first third of the file
- [ ] No dependency on hidden or auto-applied instruction files
- [ ] Audit depth matched change size: local for small edits, full for new/material changes
- [ ] Context Engineering Rules section applied
- [ ] Skill Extraction Matrix applied to reusable or long reference content
- [ ] Writing Rules applied: imperative, specific, bounded, compact
- [ ] Long prose is structured without losing required procedure or caveats
- [ ] Tables used only where they clarify comparisons or decisions
- [ ] Code examples are minimal and canonical
- [ ] Main skill is concise; long optional detail moved to explicit supporting files
- [ ] Referenced scripts, assets, and references are declared and reachable
- [ ] Risky actions and trust assumptions are explicit
- [ ] Validation / Eval Pattern applied for nontrivial skills
- [ ] Quality checklist is near the end
