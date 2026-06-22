---
name: hotfix
description: 'Coordinate an emergency hotfix workflow from issue identification through minimal fix, verification, and PR creation to target branch.'
---

# Hotfix

## Purpose
Coordinate fast emergency remediation using delegated subagents while enforcing minimal-change and regression-safety checks.

## Orchestration

Never execute hotfix tasks directly. Use task() to dispatch subagents for every step, verify outputs with explicit criteria, re-dispatch with feedback when checks fail, and use ask_question when genuinely stuck.

### Step 1: Identify the issue
**Dispatch subagent:**
- Goal: Capture a precise hotfix target from user description or issue reference.
- Context files: .harness/project-constitution.md
- Constraints: If issue details are incomplete, use ask_question to obtain missing reproduction or impact context.

**Verify:**
- Issue scope, impact, and target behavior are clearly defined.
- If fail → re-dispatch with feedback
- If pass → update state, advance

### Step 2: Create hotfix branch from latest release tag
**Dispatch subagent:**
- Goal: Create a dedicated hotfix branch starting from the latest release tag.
- Context files: .harness/project-constitution.md
- Constraints: Branch must originate from latest release tag, not from main by default.

**Verify:**
- Branch name and source tag are confirmed and correct.
- If fail → re-dispatch with feedback
- If pass → update state, advance

### Step 3: Implement minimal fix
**Dispatch subagent:**
- Goal: Apply the smallest safe code change that resolves the hotfix issue.
- Context files: .harness/project-constitution.md
- Constraints: Keep blast radius minimal; avoid unrelated refactors.

**Verify:**
- Changes directly address issue scope with minimal unrelated modifications.
- If fail → re-dispatch with feedback
- If pass → update state, advance

### Step 4: Verify fix and regressions
**Dispatch subagent:**
- Goal: Validate issue resolution and confirm no critical regressions.
- Context files: .harness/project-constitution.md
- Constraints: Run targeted verification for the defect plus essential regression checks.

**Verify:**
- Evidence shows defect fixed and regression checks passing.
- If fail → re-dispatch with feedback
- If pass → update state, advance

### Step 5: Create pull request to target branch
**Dispatch subagent:**
- Goal: Open PR from hotfix branch to the correct target branch with issue and verification summary.
- Context files: .harness/project-constitution.md
- Constraints: Target main unless a release branch is explicitly required by release policy.

**Verify:**
- PR URL is provided with correct source and target branches.
- If fail → re-dispatch with feedback
- If pass → update state, advance

## Completion
Delete state file. Report summary.
