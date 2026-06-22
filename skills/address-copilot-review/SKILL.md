---
name: address-copilot-review
description: Triage GitHub Copilot PR review threads on the current branch and answer each with a reasoned accept or reject. Use when addressing Copilot review comments, review threads, or "resolve copilot comments".
---

Work each Copilot review thread on the current branch's PR to a decision with a written rationale, and only resolve a thread after the corresponding fix is pushed. DO NOT accept a suggestion because Copilot is confident — judge it against the actual code; many Copilot notes are wrong, out of context, or stylistic noise.

## Anti-Pattern: Rubber-Stamp Acceptance

- Replying "Fixed" or "Good catch" without inspecting the cited code.
- Treating every thread as actionable — Copilot flags non-issues; rejecting with a reason is a valid outcome.
- Resolving a thread before the fix is committed and pushed (the reply then points at code that isn't on the branch).

## Process

All commands run from the repo root via the bundled driver:
`node .agents/skills/address-copilot-review/scripts/driver.mjs <cmd>`

### 1. Enumerate

`node .agents/skills/address-copilot-review/scripts/driver.mjs list`

Lists every Copilot thread with `#index`, OPEN/RESOLVED, outdated flag, and location. Work only the unresolved ones.

### 2. Read each thread in full

`… driver.mjs show <#index>`

Open the cited `path:line` in the repo and verify Copilot's claim against the real code, not its paraphrase.

### 3. Decide and reply

For each thread, conclude **accept** or **reject** with a one-paragraph rationale grounded in the code:

`… driver.mjs reply <#index> --body "Reject: line 42 already guards null via the early return above; suggestion would double-check. Leaving as-is."`

Use `--body-file` or stdin for multi-line rationales. Accepted threads: make the code change now, batched with the others.

### 4. Confirm, push, then resolve

Replies and resolves are public and the push rewrites the branch — checkpoint with the user first: "Accepted #2, #5; rejected #1, #3. Ready to post replies, commit + push the fixes, then resolve all four?"

On approval, post the replies, commit and push all accepted fixes FIRST, then resolve every triaged thread:

`… driver.mjs resolve <#index>`

Resolve both accepted (fix pushed) and rejected (rationale posted) threads. Do not resolve anything before the push lands.

## Done when

```
[ ] Every unresolved Copilot thread has an accept/reject reply with code-grounded rationale
[ ] All accepted fixes are committed and pushed
[ ] Every triaged thread is resolved
```
