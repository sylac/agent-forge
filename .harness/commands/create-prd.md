---
description: 'Create a product requirements document when /create-prd is explicitly invoked.'
---

# Create PRD

Produces a product requirements document for a new initiative or major enhancement.

## Workflow

1. Load skill: `create-prd`
2. Take product scope/context as input.
3. Generate PRD in `docs/prd/`.
4. Ensure required PRD sections are present.
5. Return created file path and completion summary.

## Dispatch Model

- Explicit command dispatch only.
- Never auto-trigger from message detection.
