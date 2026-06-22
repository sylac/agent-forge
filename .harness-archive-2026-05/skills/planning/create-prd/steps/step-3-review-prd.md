# Create PRD — Step 3: Review PRD quality

Dispatch a reviewer subagent using task() and do not review manually.

## Dispatch subagent
- Goal: Validate PRD completeness and internal consistency against gathered requirements.
- Context files: drafted PRD file in docs/prd/, step 1 requirements brief, .harness/project-constitution.md.
- Constraints: Reviewer must return explicit findings and correction requests; no silent rewrites.

## Verify
- Review result explicitly evaluates each required PRD section.
- Findings include severity and concrete remediation guidance.
- If verification fails, re-dispatch with feedback and require a structured review report.
- If review detects unresolved external dependency, use ask_question for the required decision.

## Output
- Validated PRD review report with pass/fail outcome and required edits if any.
