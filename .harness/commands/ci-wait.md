---
description: 'Wait for CI pipeline completion and report outcome when /ci-wait is explicitly invoked.'
---

# CI Wait

Monitors a CI run until completion and returns a concise status report.

## Workflow

1. Load skill: `ci-wait`
2. Take pipeline/run reference as input when provided.
3. Wait for terminal CI state.
4. Summarize pass/fail and key failures.
5. Return actionable next step.

## Dispatch Model

- Explicit command dispatch only.
- Never auto-trigger from message detection.
