---
description: 'Create a feature specification from a feature description when /create-spec is explicitly invoked.'
---

# Create Spec

Generates a new SDD-compliant feature specification in the project feature docs.

## Workflow

1. Load skill: `create-spec`
2. Take feature description as input.
3. Generate spec in `docs/features/`.
4. Enforce required SDD structure and REQ-ID coverage.
5. Return created file path and validation summary.

## Dispatch Model

- Explicit command dispatch only.
- Never auto-trigger from message detection.
