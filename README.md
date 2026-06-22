# agent-forge

Portable **Agent Skills** — reusable `SKILL.md` instructions you can install into any project, for any agent tool (Claude Code, opencode, Cursor, Copilot, pi, …). Edit a skill here once; consumers pull the change with one command.

## Skills

| Skill | What it does |
|-------|--------------|
| `handoff` | Compact the current session into a handoff doc for the next agent. |
| `caveman` | Strip a response down to blunt, minimal-token output. |
| `grill-me` | Adversarially interrogate a plan/decision before you commit to it. |
| `grill-with-docs` | Pressure-test work against authoritative docs (ADR/CONTEXT formats). |
| `improve-codebase-architecture` | Deepen modules, fix interfaces, language & structure; emits an HTML report. |
| `skill-authoring` | Write or refactor a `SKILL.md` in this repo's house style. |
| `tdd-with-specs` | Spec-driven TDD — derive failing tests from each requirement, then implement. |
| `to-design-doc` | Turn context into a design document. |
| `to-prd` | Synthesize a PRD / scope brief from a conversation. |
| `to-spec` | Turn a PRD/decisions into a declarative feature spec. |
| `to-issues` | Break a spec/plan into trackable issues. |
| `address-copilot-review` | Triage and resolve Copilot / PR review comments. |

---

## Install

### Universal — `npx skills` (recommended, no clone)

Works for [72+ agents](https://skills.sh). The CLI fetches this repo, auto-detects which agent(s) you have, and installs each skill into the right place — you never clone anything.

```bash
npx skills add sylac/agent-forge        # into the current project
npx skills add sylac/agent-forge -g     # global: available in all your projects
```

Manage them:

```bash
npx skills list                 # what's installed (add -g for global, -a to filter by agent)
npx skills update               # pull latest for everything (or: npx skills update <skill>)
npx skills remove <skill>       # uninstall
npx skills find <query>         # search
```

`skills` symlinks into its own managed cache by default (so `npx skills update` refreshes every project). Pass `--copy` if your tool can't follow symlinks.

### Claude Code — native plugin (alternative)

If you'd rather use Claude Code's built-in plugin system:

```bash
/plugin marketplace add sylac/agent-forge      # once per machine
/plugin install agent-forge@agent-forge        # once per project (or globally)
```

Skills appear as `/agent-forge:handoff`, `/agent-forge:to-prd`, etc.

### Offline / no-Node fallback — symlink or copy

When you can't run `npx` (air-gapped, no Node), clone once and use the bundled script:

```bash
git clone https://github.com/sylac/agent-forge ~/agent-forge
~/agent-forge/scripts/install.sh ~/code/myapp/.agents/skills   # or .claude/skills, .opencode/skills, …
```

Add `--copy` for tools that can't follow symlinks. Update with `git -C ~/agent-forge pull`.

---

## Keeping skills updated

**Edit once → update everywhere.** Edit a `SKILL.md` here, commit, push:

```bash
git commit -am "Improve handoff skill" && git push
```

How each consumer pulls it:

| Installed via | Update command |
|---------------|----------------|
| `npx skills` | `npx skills update` (any tool, any project) |
| Claude Code plugin | `/plugin marketplace update agent-forge` → `/plugin update agent-forge@agent-forge`, or enable auto-update: `/plugin marketplace enable-autoupdate agent-forge`. No `version` is set in `plugin.json`, so each push (new commit SHA) is treated as a new version. |
| Offline script | `git -C ~/agent-forge pull` (symlinked projects update instantly; re-run `install.sh --copy` if you copied) |

---

## What a skill is

Each skill is a folder containing `SKILL.md` (optionally with supporting `.md` files and `scripts/`). The frontmatter needs `name` + `description`:

```markdown
---
name: handoff
description: One line describing when the agent should load this skill.
---

# Handoff
...instructions...
```

This format is shared across tools — only the directory each tool scans differs, which is exactly what `npx skills` handles for you.

## Adding a skill

1. `mkdir -p skills/my-skill` and write `skills/my-skill/SKILL.md` (use the `skill-authoring` skill for house style), or scaffold with `npx skills init my-skill`.
2. Commit and push.
3. Consumers run `npx skills update` (or their plugin-update path). New skills are discovered automatically — no manifest edit needed.

## Layout

```
agent-forge/
├── skills/                # the skills — one folder per skill, each with SKILL.md
│   ├── handoff/SKILL.md
│   └── ...
├── .claude-plugin/        # optional: native Claude Code plugin/marketplace compat
│   ├── marketplace.json
│   └── plugin.json        # no version → SHA-based auto-update
├── scripts/install.sh     # offline symlink/copy installer
└── README.md
```
