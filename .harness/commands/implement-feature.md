---
description: 'Implement a feature from an existing spec when /implement-feature is explicitly invoked; skips ideation and spec creation.'
---

# Implement Feature

Executes the delivery loop from an existing feature spec through completion artifacts.

## Workflow

1. Load skill: `implement`
2. Require existing feature spec as input.
3. Load skill: `test`
4. Load skill: `review`
5. Load skill: `spec-reconciliation`
6. Load skill: `finalize`
7. Report implementation, verification, and finalization status.

## Dispatch Model

- Explicit command dispatch only.
- Never auto-trigger from message detection.
