#!/usr/bin/env bash
#
# Install agent-forge skills into a project by symlinking each skill.
# Symlinks (not copies) mean `git -C <this-repo> pull` updates every project at once.
#
# Usage:
#   scripts/install.sh <target-skills-dir>
#
# Examples (project-level):
#   scripts/install.sh ~/code/myapp/.claude/skills     # Claude Code
#   scripts/install.sh ~/code/myapp/.opencode/skills   # opencode
#   scripts/install.sh ~/code/myapp/.agents/skills     # pi / tool-agnostic (opencode reads this too)
#
# Examples (global / user-level):
#   scripts/install.sh ~/.claude/skills                # Claude Code, all projects
#   scripts/install.sh ~/.config/opencode/skills       # opencode, all projects
#
# Pass --copy to copy instead of symlink (use when the tool can't follow symlinks,
# or the target lives on a different filesystem).

set -euo pipefail

MODE="link"
if [[ "${1:-}" == "--copy" ]]; then MODE="copy"; shift; fi

TARGET="${1:?Usage: scripts/install.sh [--copy] <target-skills-dir>}"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/../skills" && pwd)"

mkdir -p "$TARGET"

for skill in "$SRC"/*/; do
  name="$(basename "$skill")"
  if [[ "$MODE" == "copy" ]]; then
    rm -rf "${TARGET:?}/$name"
    cp -r "$skill" "$TARGET/$name"
    echo "copied  $name -> $TARGET/$name"
  else
    ln -sfn "$skill" "$TARGET/$name"
    echo "linked  $name -> $TARGET/$name"
  fi
done

echo
if [[ "$MODE" == "link" ]]; then
  echo "Done. To update all linked projects later:  git -C \"$(dirname "$SRC")\" pull"
else
  echo "Done (copied). Re-run this script after pulling to refresh copies."
fi
