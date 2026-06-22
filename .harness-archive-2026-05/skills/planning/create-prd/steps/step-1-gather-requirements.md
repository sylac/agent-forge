# Create PRD — Step 1: Gather requirements

Dispatch a subagent using task() and do not perform requirement analysis directly.

## Dispatch subagent
- Goal: Produce a consolidated requirements brief from user input, existing docs, and any brainstorming outputs.
- Context files: .harness/project-constitution.md, docs/features/, docs/architecture/, user-provided description and references.
- Constraints: Preserve source intent; identify ambiguities instead of guessing; do not draft the PRD yet.

## Verify
- Brief includes problem context, target users or personas, constraints, assumptions, and open questions.
- Brief references concrete source artifacts.
- If verification fails, re-dispatch with precise feedback and request corrections.
- If genuinely blocked by missing inputs, use ask_question to request only the minimum missing information.

## Output
- A validated requirements brief ready for PRD drafting in the next step.
