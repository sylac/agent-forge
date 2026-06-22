# Create PRD — Step 4: User approval

Dispatch a subagent using task() to present outcomes; do not finalize silently.

## Dispatch subagent
- Goal: Present the PRD summary and obtain explicit user approval or revision requests.
- Context files: final PRD file in docs/prd/, PRD review findings from step 3.
- Constraints: Require explicit approval signal before marking complete.

## Verify
- User decision is captured as approved or changes requested.
- If changes are requested, include actionable notes and route back to drafting/review flow.
- If verification fails, re-dispatch to restate summary and ask a direct approval question.
- If user intent is unclear, use ask_question to clarify decision.

## Output
- Approval decision with next action recorded.
