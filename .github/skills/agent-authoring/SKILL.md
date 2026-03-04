---
name: agent-authoring
description: "Anatomy template and quality checklist for authoring agent definition files (.agent.md). Load when creating, auditing, or improving any agent definition file."
---

# Agent Authoring

This skill provides the canonical structure and quality gates for `.agent.md` files. Load it whenever the task involves creating, auditing, or improving an agent definition file.

**CE rules (primacy/recency, token budgets, extraction matrix, workspace audit) are in `authoring-rules.instructions.md` — auto-applied, do not reproduce here.**

---

## Agent File Anatomy

Required sections in order:

1. **Frontmatter** — `name`, `description` (one-line, actionable), `tools` (minimal), `agents` (required if `agent` in `tools`), `handoffs`
2. **H1 + Role activation paragraph** — who the agent is, primary action, key constraint
3. **`## Core Responsibilities`** — 3–6 numbered verb-object items
4. **`## Workflow`** — ordered phases, each producing a named artifact
5. **`## Benchmark Tasks`** — 3–5 concrete input → expected output criteria
6. **`## Output Format`** — explicit template (recency position)
7. **`## Validation Checklist`** — domain-specific gates, anchors the bottom

---

## Quality Checklist — Agent Definition Files

- [ ] Role activation is the first paragraph after H1
- [ ] Core Responsibilities: 3–6 numbered items in verb-object format
- [ ] No continuous prose block exceeds 10 lines
- [ ] Tables used for all decisions with ≥2 attributes per option
- [ ] Benchmark tasks: 3–5 items with concrete input → output criteria
- [ ] Output format template present and explicit
- [ ] Validation checklist anchors the bottom
- [ ] Critical instructions present at top and bottom (primacy + recency)
- [ ] No content duplicating auto-applied instruction files
- [ ] All code examples ≤4 lines
- [ ] Skill extraction matrix applied; skills extracted before agent finalized
- [ ] File under 2000 tokens
- [ ] `agents:` field present if `agent` is in `tools:`
- [ ] All tool names use valid built-in names (see copilot-primitives-format instructions)
