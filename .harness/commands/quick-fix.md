---
description: 'Apply a minimal bug fix or small scoped change when /quick-fix is explicitly invoked; intended for L0 tasks.'
---

# Quick Fix

Runs a minimal implementation path with low ceremony for small, targeted changes.

## Workflow

1. Load skill: `implement`
2. Keep scope constrained to the stated fix.
3. Dispatch execution to the implementation subagent flow.
4. Verify build or equivalent validation passes.
5. Return concise change summary.

## Dispatch Model

- Explicit command dispatch only.
- Never auto-trigger from message detection.
