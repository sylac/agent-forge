---
name: tech-debt-assess
description: 'Assess technical debt by scanning code and delivery signals, then prioritize findings by severity, impact, and estimated remediation effort.'
---

# Tech Debt Assess

## Purpose
Identify, classify, and prioritize technical debt across code quality, type safety, test coverage, and dependency hygiene.

## Orchestration
### Step 1: Discover debt signals across the codebase
**Dispatch subagent:** Scan for TODO/FIXME/HACK comments, type safety issues, missing tests around critical paths, and outdated dependencies.
**Verify:** Confirm findings include evidence references (file paths, package names, issue details) and are grouped by debt signal type. Re-dispatch when scan coverage is incomplete.

### Step 2: Normalize and deduplicate findings
**Dispatch subagent:** Consolidate overlapping findings into a canonical list with clear problem statements and affected components.
**Verify:** Confirm duplicates are removed and each item is independently actionable. Re-dispatch when findings remain redundant or unclear.

### Step 3: Categorize and prioritize
**Dispatch subagent:** Classify items by severity, risk, and effort estimate, then propose remediation sequence based on impact versus cost.
**Verify:** Confirm prioritization logic is explicit and consistent across categories. Re-dispatch if severity or effort estimates are unsupported.

### Step 4: Produce technical debt report
**Dispatch subagent:** Generate a report with categorized findings, severity, effort ranges, and recommended execution plan.
**Verify:** Confirm report includes both quick wins and strategic debt items with rationale. Ask_question if business constraints are needed to finalize prioritization.

## Completion
Return a technical debt assessment report with prioritized findings, severity levels, and effort estimates. This skill is stateless.
