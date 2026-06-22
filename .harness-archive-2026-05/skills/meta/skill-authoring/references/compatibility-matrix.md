# AgentSkills Compatibility Matrix

Use this reference during design and validation. Treat vendor guidance as runtime compatibility evidence, not proof that one instruction format universally improves model performance.

## Baseline AgentSkills Rules

| Area | Rule | Status |
|------|------|--------|
| Container | Skill is a directory with `SKILL.md` | Loader requirement |
| Frontmatter | YAML frontmatter starts the file | Loader requirement |
| `name` | Required; lowercase alphanumeric plus hyphen; max 64; matches directory | Loader requirement |
| `description` | Required; max 1024; says what the skill does and when to use it | Loader requirement |
| Body | Markdown-compatible instructions | Loader requirement |
| Supporting files | `references/`, `assets/`, `scripts/` loaded on demand | Loader requirement |
| File references | Supporting files must be referenced from `SKILL.md` | Loader requirement |
| Size | Prefer `SKILL.md` under 500 lines or about 5000 tokens | Evidence-supported heuristic / convention |
| Paths | Prefer simple one-level relative references | Portability convention |
| Validation | Use target runtime validator, e.g. `skills-ref validate`, when available | Loader requirement when available |

## Optional Metadata

| Field | Use When |
|-------|----------|
| `license` | Publishing or redistributing a skill |
| `compatibility` | Declaring supported runtimes or versions |
| `metadata` | Runtime needs structured package metadata |
| `allowed-tools` | Runtime supports tool permission hints |
| `argument-hint` | Invocation UI benefits from user-visible arguments |
| `user-invocable` | Runtime supports hiding/disabling explicit invocation |
| `disable-model-invocation` | Runtime supports preventing automatic model invocation |

## Runtime Notes

| Runtime | Strong Alignment | Watchouts |
|---------|------------------|-----------|
| AgentSkills open standard | Directory bundle, YAML frontmatter, Markdown body, progressive disclosure | XML-style body is acceptable only if Markdown-compatible and parser-neutral |
| Anthropic Claude / Claude Code | Skills use `SKILL.md`, frontmatter, Markdown body, optional scripts/resources; Anthropic prompt docs support XML tags for boundaries | Public skill templates are Markdown-first; do not claim XML body is the Anthropic skill norm |
| OpenAI Codex skills | AgentSkills-compatible; progressive disclosure; description quality is important; supports optional `agents/openai.yaml` | Keep descriptions concise and trigger-front-loaded; test invocation prompts |
| GitHub / VS Code Copilot skills | AgentSkills-compatible; project and personal skill locations; additional files must be referenced | Invalid names may fail silently in some tools; review shared scripts for security |
| Harness / OpenCode local convention | YAML frontmatter plus XML-style semantic body for high-rigor internal skills | Must remain adapter-compatible and should not be claimed as repo-wide until migrated |

## Compatibility Decision Rule

- If publishing outside this repo, optimize for YAML frontmatter plus conventional Markdown body unless XML-style blocks are accepted by the target runtime.
- If staying inside Harness/OpenCode, XML-style semantic blocks may be used for boundary clarity, but preserve Markdown readability.
- If a runtime has a stricter parser, follow the runtime over local style.
