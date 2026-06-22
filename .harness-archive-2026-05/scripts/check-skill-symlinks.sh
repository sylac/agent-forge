#!/usr/bin/env bash
# check-skill-symlinks.sh
#
# Enforces the source-of-truth contract:
#   .harness/skills/<category>/   = canonical source
#   .opencode/skills/<category>   = symlink -> ../../.harness/skills/<category>
#
# Fails (exit 1) on any of these drift modes:
#   1. Category in .harness/skills/ has no entry in .opencode/skills/
#   2. Entry in .opencode/skills/ is a real file/dir instead of a symlink
#   3. Entry in .opencode/skills/ is a symlink pointing somewhere unexpected
#   4. Entry in .opencode/skills/ has no matching .harness/skills/ source
#
# Run manually:   bash .harness/scripts/check-skill-symlinks.sh
# Run via hook:   wired in .harness/hooks/pre-commit (installed by setup.sh)
# Run via CI:     .github/workflows/skills-check.yml

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

HARNESS_SKILLS="${REPO_ROOT}/.harness/skills"
OPENCODE_SKILLS="${REPO_ROOT}/.opencode/skills"

errors=0

err() {
  printf '  ✗ %s\n' "$1" >&2
  errors=$((errors + 1))
}

if [[ ! -d "${HARNESS_SKILLS}" ]]; then
  echo "ERROR: ${HARNESS_SKILLS} does not exist" >&2
  exit 2
fi

if [[ ! -d "${OPENCODE_SKILLS}" ]]; then
  echo "ERROR: ${OPENCODE_SKILLS} does not exist (run platform-adapters/opencode/setup.sh)" >&2
  exit 2
fi

echo "Checking skill symlinks: .harness/skills <-> .opencode/skills"

# Check 1+2+3: every .harness/skills/<category> must have a correct symlink in .opencode/skills/
for category_path in "${HARNESS_SKILLS}"/*; do
  [[ -d "${category_path}" ]] || continue
  category_name="$(basename "${category_path}")"
  link_path="${OPENCODE_SKILLS}/${category_name}"

  if [[ ! -e "${link_path}" && ! -L "${link_path}" ]]; then
    err "missing: .opencode/skills/${category_name} (expected symlink to .harness/skills/${category_name})"
    continue
  fi

  if [[ ! -L "${link_path}" ]]; then
    err "drift:   .opencode/skills/${category_name} is a real file/dir, not a symlink (delete it and re-run setup.sh)"
    continue
  fi

  raw_target="$(readlink "${link_path}")"

  if [[ ! -e "${link_path}" ]]; then
    err "broken:  .opencode/skills/${category_name} is a dangling symlink to '${raw_target}'"
    continue
  fi

  resolved_target="$(readlink -f "${link_path}")"
  resolved_expected="$(readlink -f "${category_path}")"
  if [[ "${resolved_target}" != "${resolved_expected}" ]]; then
    err "wrong:   .opencode/skills/${category_name} resolves to '${resolved_target}' (expected '${resolved_expected}')"
    continue
  fi
done

# Check 4: every entry in .opencode/skills/ must have a matching source
for entry_path in "${OPENCODE_SKILLS}"/*; do
  [[ -e "${entry_path}" || -L "${entry_path}" ]] || continue
  entry_name="$(basename "${entry_path}")"
  source_path="${HARNESS_SKILLS}/${entry_name}"

  if [[ ! -d "${source_path}" ]]; then
    err "orphan:  .opencode/skills/${entry_name} has no source at .harness/skills/${entry_name}"
  fi
done

if [[ ${errors} -gt 0 ]]; then
  echo "" >&2
  echo "FAILED: ${errors} skill symlink issue(s) detected." >&2
  echo "Fix: edit .harness/skills/, then run: bash .harness/platform-adapters/opencode/setup.sh" >&2
  exit 1
fi

echo "OK: all skill symlinks consistent."
