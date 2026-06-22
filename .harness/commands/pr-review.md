---
description: 'Review an open pull request when /pr-review is explicitly invoked with a PR number or URL.'
---

# PR Review

Runs a structured review workflow for an existing pull request.

## Workflow

1. Load skill: `pr-review`
2. Require PR number or PR URL as input.
3. Execute review checks defined by the skill.
4. Summarize findings by severity and action.
5. Return review outcome and recommendation.

## Dispatch Model

- Explicit command dispatch only.
- Never auto-trigger from message detection.
