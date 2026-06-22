# OpenCode Platform Adapter

This adapter exposes Harness skills and commands to OpenCode by creating symlinks in `.opencode/` that point to `.harness/` assets.

## What `setup.sh` does

- Creates `.opencode/skills/` and `.opencode/commands/` if missing.
- Creates/updates symlinks from:
  - `.harness/skills/<category>/` → `.opencode/skills/<category>`
  - `.harness/commands/*.md` → `.opencode/commands/*.md`
- Replaces stale links or existing conflicting files/directories.
- Is idempotent: safe to run repeatedly.

## Why this shape

- Skills are linked as directories (category-level), so updates under `.harness/skills/` propagate automatically.
- Commands are linked as markdown files for explicit command dispatch entry points.

## Usage

From repository root:

```bash
bash .harness/platform-adapters/opencode/setup.sh
```

Re-run after adding or renaming Harness skills/commands.
