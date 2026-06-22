# Create UX Design — Step 1: Gather UX inputs

Dispatch a subagent using task() and do not perform analysis directly.

## Dispatch subagent
- Goal: Collect UX-relevant inputs from PRD and feature specifications and summarize design constraints.
- Context files: docs/prd/, docs/features/, .harness/project-constitution.md.
- Constraints: Use artifacts as source of truth; flag missing prerequisites explicitly.

## Verify
- Summary references concrete PRD and feature artifacts.
- Summary includes user goals, scope boundaries, and unresolved UX questions.
- If verification fails, re-dispatch with specific missing coverage.
- If inputs are genuinely missing, use ask_question to request only required artifacts.

## Output
- Validated UX input summary for design drafting.
