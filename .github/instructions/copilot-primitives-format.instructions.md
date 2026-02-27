---
name: Copilot Primitives Format
description: Exact YAML frontmatter schemas for .agent.md, SKILL.md, .instructions.md, and .prompt.md. Enforces only officially supported fields and valid built-in tool names.
applyTo: '.github/agents/**, .github/skills/**, .github/instructions/**'
---

# Copilot Primitives Format

This file encodes the official YAML frontmatter schemas for GitHub Copilot's four authoring primitives, sourced from VS Code documentation (last updated 2026-02).

**Hard constraint:** Only fields listed below are officially supported. Unknown fields are silently ignored. Invalid tool names (e.g., slash-notation like `read/readFile`) are silently dropped at runtime.

---

## `.agent.md` — Custom Agent

**Location:** `.github/agents/<name>.agent.md`

| Field | Req | Type | Notes |
|-------|-----|------|-------|
| `name` | No | string | Display name; default: filename |
| `description` | No | string | Chat input placeholder text |
| `argument-hint` | No | string | Hint shown in chat input field |
| `tools` | No | string[] | Tool/tool-set names; `<server>/*` for all tools from one MCP server |
| `agents` | No | string[] | Allowed subagent names; `*` = all; `[]` = none; requires `agent` in `tools` |
| `model` | No | string \| string[] | First available model wins; format: `Model Name (vendor)` |
| `user-invokable` | No | bool | Default `true`; `false` hides from agents dropdown |
| `disable-model-invocation` | No | bool | Default `false`; `true` blocks subagent invocation |
| `target` | No | string | `vscode` or `github-copilot` |
| `mcp-servers` | No | object[] | MCP server config JSON; only active when `target: github-copilot` |
| `handoffs` | No | object[] | Suggested follow-up transitions |
| `infer` | — | — | ⚠️ **DEPRECATED** — replace with `user-invokable` + `disable-model-invocation` |

**Handoffs sub-fields:** `label` (string), `agent` (string), `prompt` (string), `send` (bool, default `false`), `model` (string, format: `Name (vendor)`)

```yaml
# .agent.md example
---
name: Planner
description: Generates implementation plans without making code edits.
tools: ['fetch', 'codebase', 'search']
model: ['Claude Sonnet 4.5 (copilot)', 'GPT-4o (copilot)']
handoffs:
  - label: Implement Plan
    agent: agent
    prompt: Implement the plan above.
    send: false
---
```

---

## `SKILL.md` — Agent Skill

**Location:** `.github/skills/<name>/SKILL.md` — directory name **must equal** the `name` field value

| Field | Req | Type | Notes |
|-------|-----|------|-------|
| `name` | **Yes** | string | Lowercase, hyphens for spaces; ≤64 chars; must match parent dir name |
| `description` | **Yes** | string | What it does and when to use it; ≤1024 chars; drives auto-loading decision |
| `argument-hint` | No | string | Hint when invoked as `/name` slash command |
| `user-invokable` | No | bool | Default `true`; `false` = hidden from `/` menu, still auto-loaded |
| `disable-model-invocation` | No | bool | Default `false`; `true` = manual `/name` invocation only, no auto-load |
| `allowed-tools` | No | string[] | Valid per Agent Skills spec; VS Code validator may warn incorrectly (bug #14131) |
| `metadata` | No | nested object | Extra metadata; avoid placing last in frontmatter when targeting Copilot CLI (CLI bug #951) |

**Visibility matrix:**

| Configuration | In `/` menu | Auto-loaded |
|---------------|-------------|-------------|
| Both omitted (default) | ✓ | ✓ |
| `user-invokable: false` | ✗ | ✓ |
| `disable-model-invocation: true` | ✓ | ✗ |
| Both set to restrict | ✗ | ✗ |

---

## `.instructions.md` — Custom Instructions

**Location:** `.github/instructions/<name>.instructions.md`

| Field | Req | Type | Notes |
|-------|-----|------|-------|
| `name` | No | string | Display name in UI; default: filename |
| `description` | No | string | Shown on hover in Chat view; also used for semantic matching |
| `applyTo` | No | glob string | Auto-applies when matched; `**` = all files; omit = manual attach only |

> Files in `.claude/rules/` use `paths: []` (array) instead of `applyTo` for glob patterns.

---

## `.prompt.md` — Prompt File / Slash Command

**Location:** `.github/prompts/<name>.prompt.md`

| Field | Req | Type | Notes |
|-------|-----|------|-------|
| `name` | No | string | Invoked via `/name`; default: filename |
| `description` | No | string | Short description |
| `argument-hint` | No | string | Hint text in chat input |
| `agent` | No | string | `ask`, `agent`, `plan`, or custom agent name; defaults to `agent` when `tools` is set |
| `model` | No | string | Language model to use |
| `tools` | No | string[] | Tool/tool-set names; takes priority over agent's tool list |

---

## Built-in Tool Names

Use exact names below in `tools:` fields. Unrecognised names are silently dropped.

| Tool name | What it does |
|-----------|-------------|
| `agent` | Invoke subagents (also add `agents:` to specify which) |
| `changes` | Source control staged/unstaged diffs |
| `codebase` | Semantic code search across workspace |
| `editFiles` | Apply edits to workspace files |
| `fetch` | Fetch content from a URL |
| `fileSearch` | Find files by glob pattern |
| `githubRepo` | Code search in a GitHub repository |
| `listDirectory` | List contents of a directory |
| `problems` | Workspace diagnostics / Problems panel |
| `readFile` | Read file contents |
| `runInTerminal` | Run shell commands in integrated terminal |
| `runSubagent` | Execute task in an isolated subagent context |
| `runTests` | Run unit tests |
| `runVscodeCommand` | Execute a VS Code command by ID |
| `textSearch` | Find text in files (regex-capable) |
| `todos` | Track todo list for multi-step tasks |
| `usages` | Find all references, implementations, definitions |
| `VSCodeAPI` | Answer questions about VS Code extension API |

**Built-in tool sets** (activate multiple tools with one name):

| Set name | Coverage |
|----------|----------|
| `edit` | `editFiles` + related file modification tools |
| `search` | `fileSearch` + `codebase` |
| `runCommands` | `runInTerminal` + `getTerminalOutput` |
| `runTasks` | `runTask` + `getTaskOutput` |
| `runNotebooks` | `runCell` + notebook editing tools |

---

## Common Errors

| Wrong | Correct | Rule |
|-------|---------|------|
| `read/readFile` | `readFile` | No slash notation in tool names |
| `read/problems` | `problems` | — |
| `todo` | `todos` | Exact name match required |
| `infer: true` | `user-invokable: true` | `infer` is deprecated |
| `infer: false` | `user-invokable: false` | — |
| `handoffs[].send: "false"` | `handoffs[].send: false` | Boolean, not string |
| `applyTo: ['**/*.ts']` | `applyTo: '**/*.ts'` | Glob string, not array (for `.instructions.md`) |

---

## Validation Checklist

- [ ] `SKILL.md`: `name` and `description` are both present (required)
- [ ] `SKILL.md`: `name` value matches parent directory name exactly
- [ ] `SKILL.md`: `name` is lowercase with hyphens only, ≤64 chars
- [ ] `.agent.md`: `agents:` field present whenever `agent` is in `tools:`
- [ ] `model` values use qualified format: `Model Name (vendor)` (e.g., `Claude Sonnet 4.5 (copilot)`)
- [ ] No deprecated `infer` field present
- [ ] All tool names are exact matches from the Built-in Tool Names table above
- [ ] `handoffs[].send` is a boolean (`true`/`false`), not a quoted string
- [ ] `.instructions.md` `applyTo` is a single glob string, not an array
- [ ] `.prompt.md` `agent` is one of: `ask`, `agent`, `plan`, or a named custom agent
