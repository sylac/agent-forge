---
description: 'Run the full harness pipeline from idea to PR when /autopilot is explicitly invoked; supports resume from interrupted state.'
---

# Autopilot

Primary entry point for end-to-end delivery: idea → spec → implement → test → review → PR.

## Workflow

1. Load skill: `autopilot`
2. Pass user goal as pipeline input.
3. Let the skill orchestrate all required inner phases.
4. If prior state exists, resume instead of restarting.
5. Return final outcome summary and next action.

## Dispatch Model

- Explicit command dispatch only.
- Never auto-trigger from message detection.
