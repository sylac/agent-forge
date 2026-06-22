---
name: create-prd
description: 'Create a complete Product Requirements Document from user intent and project artifacts through delegated subagent execution with verification and approval.'
---

# Create PRD

## Purpose
Create a complete, internally consistent Product Requirements Document ready for user approval.

## State Management
State file: .harness/state/create-prd--feature-name.yaml
On start: no file → copy template | status: completed → delete + fresh | status: in_progress → ask resume/restart

## Orchestration

Never do the work directly: dispatch subagents via task() for all work, verify outputs against explicit criteria, re-dispatch with feedback on failure, and use ask_question when genuinely stuck.

### Step 1: Gather requirements
**Dispatch subagent:**
- Goal: Consolidate requirements from user description, existing docs, and brainstorming outputs into one brief.
- Context files: .harness/project-constitution.md, docs/features/, docs/architecture/, any referenced brainstorming artifacts.
- Constraints: Do not implement or design; preserve source intent; call out ambiguities explicitly.

**Verify:**
- Requirements brief includes problem statement context, target users, constraints, assumptions, and open questions.
- If fail → re-dispatch with feedback
- If pass → update state, advance

### Step 2: Draft PRD
**Dispatch subagent:**
- Goal: Draft PRD containing problem statement, target users, user stories, success metrics, scope in/out, and constraints.
- Context files: Step 1 requirements brief, .harness/project-constitution.md, docs/features/, docs/architecture/.
- Constraints: Keep requirements technology-agnostic and testable; write a markdown output file under docs/prd/.

**Verify:**
- PRD file exists under docs/prd/ and includes all required PRD sections.
- If fail → re-dispatch with feedback
- If pass → update state, advance

### Step 3: Validate PRD completeness and consistency
**Dispatch subagent:**
- Goal: Review PRD for completeness, consistency, and traceability to gathered requirements.
- Context files: Draft PRD in docs/prd/, Step 1 requirements brief, .harness/project-constitution.md.
- Constraints: Reviewer returns explicit findings and required edits; no silent rewriting.

**Verify:**
- Review output explicitly confirms each required section and flags any contradictions or gaps.
- If fail → re-dispatch with feedback
- If pass → update state, advance

### Step 4: Present for user approval
**Dispatch subagent:**
- Goal: Present PRD summary and request explicit user approval or revisions.
- Context files: Reviewed PRD in docs/prd/, Step 3 findings.
- Constraints: Do not mark approved without explicit user confirmation.

**Verify:**
- User response is captured as approved or revision requested with actionable notes.
- If fail → re-dispatch with feedback
- If pass → update state, advance

## Completion
Delete state file. Report summary.
