---
name: skill-authoring
description: "Anatomy template, progressive loading model, and quality checklist for authoring skill files (SKILL.md). Load when creating, auditing, or improving any skill file."
---

# Skill Authoring

This skill provides the canonical structure, progressive loading model, and quality gates for `SKILL.md` files. Load it whenever the task involves creating, auditing, or improving a skill file.

**CE rules (primacy/recency, token budgets, extraction matrix, workspace audit) are in `authoring-rules.instructions.md` — auto-applied, do not reproduce here.**

---

## Skill File Anatomy

Required sections in order:

1. **Frontmatter** — `name` (required, must match directory name), `description` (required; what it does + trigger conditions)
2. **H1 + Identity paragraph** — what it enables, one hard constraint
3. **Middle reference sections** — tables, matrices, examples
4. **`## Validation Checklist`** — anchors the bottom

---

## Progressive Loading Model

Design every skill for this loading hierarchy:

| Level | Content | When Available |
|-------|---------|----------------|
| 1 — Metadata | `name`, `description` frontmatter | Always in context |
| 2 — SKILL.md body | Workflows, patterns, references (≤800 tokens) | On skill load |
| 3 — `references/` | Detailed docs, schemas | On demand |
| 3 — `assets/` | Templates, output files | On demand |
| 3 — `scripts/` | Executable code | On demand |

Compression patterns:

| Before | After |
|--------|-------|
| 5-sentence prose on one concept | 3-row table |
| 12-line code block with scaffolding | 3-line snippet showing only the unique construct |
| Static list of file paths | Discovery pattern: "List `.github/agents/`" |

---

## Quality Checklist — Skill Files

- [ ] Single topic — exactly one domain or capability
- [ ] `name` matches parent directory name exactly
- [ ] `description` includes trigger conditions (when to load)
- [ ] Identity paragraph present as first paragraph
- [ ] Critical constraints in the first third of the file
- [ ] No auto-applied instruction content duplicated
- [ ] No prose block exceeds 8 continuous lines without a table or list break
- [ ] Tables used for decisions with ≥2 attributes per option
- [ ] All code examples ≤4 lines
- [ ] Token target met: ≤800 tokens (extension to 2000 must be explicitly justified)
- [ ] Validation checklist is the last section
