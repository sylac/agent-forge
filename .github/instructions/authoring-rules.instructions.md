---
name: Authoring Rules
description: Context-engineering invariants for all agent and skill file authoring.
applyTo: '.github/agents/**, .github/skills/**, .github/instructions/**'
---

# Authoring Rules

Non-negotiable CE invariants for every agent definition file and skill file.

## Critical Constraints

- **Audit first** — list `.github/instructions/`, `.github/agents/`, `.github/skills/` before drafting anything
- **Never duplicate** content from auto-applied instruction files; it is already in context
- **Token budgets** — agent files: ≤2000 tokens; skill files: ≤800 tokens (extend to 2000 with explicit justification only)
- **Extract before embed** — content reusable across 2+ agents must become a skill, not inline prose

## Context Engineering Rules

| Rule | Application |
|------|-------------|
| **Primacy** | Role activation, hard constraints, primary workflow go at the top |
| **Recency** | Output format template and validation checklist anchor the bottom |
| **Middle** | Reference tables, decision matrices, taxonomy, and examples occupy the middle |
| **Duplication** | Duplicated content wastes context and creates contradictions — remove entirely |
| **Delimiters** | Use headers and tables; unbroken prose is undifferentiated text |

## Information Placement

| Position | Content |
|----------|---------|
| Top — primacy | Role activation, core responsibilities, critical constraints |
| Middle | Reference tables, decision matrices, taxonomy, code examples |
| Bottom — recency | Output format template, domain-specific validation checklist |

## Writing Rules

| Rule | Do | Don't |
|------|----|-------|
| Imperative voice | "Read the file" | "You should read the file" |
| Specific | "List `.github/agents/`" | "Look at the codebase" |
| Positive constraints | "Always confirm before writing" | "Never write without confirming" |
| Code examples | ≤4 lines, unique concept only | Add imports and scaffolding |
| Prose threshold | Convert >3 sentences to a table | Leave as a paragraph |

## Workspace Audit Pattern

Before any design work:

1. List `.github/instructions/` — mark all content **do not duplicate** (auto-applied on every run)
2. List `.github/agents/` — identify existing agents; eliminate responsibility overlap
3. List `.github/skills/` — find overlapping skills; extend rather than create a duplicate

## Skill Extraction Matrix

| Signal | Decision |
|--------|----------|
| Content appears in ≥2 agent task paths | Extract to skill |
| Content is in auto-applied `.github/instructions/` | Exclude entirely |
| Content is domain-specific, not general model knowledge | Include in skill |
| Content is model-general boilerplate | Exclude — reference by name |
| Content is >10 lines of static reference data | Compress to table in skill |
| Content explains *why* only | Exclude — convert to *what to do* |
