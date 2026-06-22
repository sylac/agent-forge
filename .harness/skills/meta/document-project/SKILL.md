---
name: document-project
description: 'Generate or update project documentation by reconciling repository structure and behavior with README, API docs, and setup guidance.'
---

# Document Project

## Purpose
Generate and maintain project documentation that accurately reflects the current codebase structure, APIs, and setup workflow.

## Orchestration
### Step 1: Scan project structure and documentation surface
**Dispatch subagent:** Analyze repository layout, key modules, interfaces, and existing documentation artifacts.
**Verify:** Confirm the scan identifies core entry points, build/test commands, and public interfaces. Re-dispatch if coverage of major components is incomplete.

### Step 2: Draft documentation updates
**Dispatch subagent:** Generate or update README, API docs, and setup guide content based on the discovered project state.
**Verify:** Confirm documentation language is clear, operationally accurate, and aligned with actual commands, paths, and module names. Re-dispatch for mismatches or missing sections.

### Step 3: Cross-check docs against code state
**Dispatch subagent:** Validate generated documentation against current implementation details and identify stale, contradictory, or speculative content.
**Verify:** Confirm all documented instructions are executable and all described interfaces exist. Re-dispatch when inconsistencies or unsupported claims are detected.

### Step 4: Finalize documentation package
**Dispatch subagent:** Consolidate updates into coherent project docs with changelog-style summary of what was updated and why.
**Verify:** Confirm final docs are internally consistent, complete for onboarding, and synchronized to current code behavior. Ask_question if unresolved ambiguity requires maintainer intent.

## Completion
Return updated project documentation set covering README, API docs, and setup guidance verified against current code state. This skill is stateless.
