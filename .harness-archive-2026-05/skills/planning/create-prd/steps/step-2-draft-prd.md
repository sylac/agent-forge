# Create PRD — Step 2: Draft PRD

Dispatch a subagent using task() and do not write PRD content directly.

## Dispatch subagent
- Goal: Draft a PRD containing problem statement, target users, user stories, success metrics, scope in/out, and constraints.
- Context files: requirements brief from step 1, .harness/project-constitution.md, docs/features/, docs/architecture/.
- Constraints: Keep requirements testable and technology-agnostic; write output to a descriptive markdown file under docs/prd/.

## Verify
- PRD file exists in docs/prd/.
- PRD contains all required sections and no contradictions with source documents.
- If verification fails, re-dispatch with explicit missing or incorrect sections.
- If genuinely blocked by unresolved ambiguity, use ask_question for targeted clarification.

## Output
- Draft PRD artifact in docs/prd/ ready for review.
