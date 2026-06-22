---
name: create-ux-design
description: 'Create a UX design specification from PRD and feature specifications through delegated subagent drafting and validation.'
---

# Create UX Design

## Purpose
Create a UX design specification aligned to product intent and implementation planning needs.

## Orchestration

Never do the work directly: dispatch subagents via task() for all work, verify outputs against explicit criteria, re-dispatch with feedback on failure, and use ask_question when genuinely stuck.

### Step 1: Gather PRD and feature inputs
**Dispatch subagent:**
- Goal: Read PRD and feature specs and produce a UX input summary with constraints.
- Context files: docs/prd/, docs/features/, .harness/project-constitution.md.
- Constraints: Use source docs as truth; identify missing prerequisites explicitly.

**Verify:**
- Input summary references concrete PRD and feature spec artifacts and captures UX constraints.
- If fail → re-dispatch with feedback
- If pass → update state, advance

### Step 2: Draft UX design specification
**Dispatch subagent:**
- Goal: Create UX spec including user flows, wireframe descriptions, interaction patterns, and accessibility requirements.
- Context files: Step 1 input summary, docs/prd/, docs/features/, .harness/project-constitution.md.
- Constraints: Keep content technology-agnostic and testable; write a markdown output file under docs/ux/.

**Verify:**
- UX spec file exists under docs/ux/ and includes all required UX sections.
- If fail → re-dispatch with feedback
- If pass → update state, advance

### Step 3: Validate UX spec against PRD
**Dispatch subagent:**
- Goal: Review UX spec for consistency with PRD goals, scope, stories, and constraints.
- Context files: UX spec in docs/ux/, related PRD in docs/prd/, Step 1 input summary.
- Constraints: Reviewer must return explicit alignment findings and corrections; no silent edits.

**Verify:**
- Review report states pass/fail and lists concrete PRD alignment evidence or mismatches.
- If fail → re-dispatch with feedback
- If pass → update state, advance

## Completion
Report summary.
