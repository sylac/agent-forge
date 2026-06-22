---
description: 'Cut a release when /release is explicitly invoked, including changelog, tagging, and deployment handoff.'
---

# Release

Coordinates release activities and reports the release artifact status.

## Workflow

1. Load skill: `release`
2. Gather target version or release scope.
3. Generate/update changelog.
4. Create and verify release tag.
5. Execute deployment release flow.
6. Return release summary and follow-up checks.

## Dispatch Model

- Explicit command dispatch only.
- Never auto-trigger from message detection.
