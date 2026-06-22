#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

HARNESS_ROOT="${REPO_ROOT}/.harness"
OPENCODE_ROOT="${REPO_ROOT}/.opencode"

HARNESS_SKILLS="${HARNESS_ROOT}/skills"
HARNESS_COMMANDS="${HARNESS_ROOT}/commands"

OPENCODE_SKILLS="${OPENCODE_ROOT}/skills"
OPENCODE_COMMANDS="${OPENCODE_ROOT}/commands"

mkdir -p "${OPENCODE_SKILLS}" "${OPENCODE_COMMANDS}"

link_path() {
  local src="$1"
  local dst="$2"

  local dst_dir
  dst_dir="$(dirname "${dst}")"
  mkdir -p "${dst_dir}"

  local rel_src
  rel_src="$(realpath --relative-to="${dst_dir}" "${src}")"

  if [[ -L "${dst}" ]]; then
    local current
    current="$(readlink "${dst}")"
    if [[ "${current}" == "${rel_src}" ]]; then
      return 0
    fi
    rm -f "${dst}"
  elif [[ -e "${dst}" ]]; then
    rm -rf "${dst}"
  fi

  ln -s "${rel_src}" "${dst}"
}

# Link skill directories (category-level directories, not individual skill files)
if [[ -d "${HARNESS_SKILLS}" ]]; then
  for category_path in "${HARNESS_SKILLS}"/*; do
    [[ -d "${category_path}" ]] || continue
    category_name="$(basename "${category_path}")"
    link_path "${category_path}" "${OPENCODE_SKILLS}/${category_name}"
  done
fi

# Link command markdown files
if [[ -d "${HARNESS_COMMANDS}" ]]; then
  for command_path in "${HARNESS_COMMANDS}"/*.md; do
    [[ -f "${command_path}" ]] || continue
    command_name="$(basename "${command_path}")"
    link_path "${command_path}" "${OPENCODE_COMMANDS}/${command_name}"
  done
fi

# Install harness git hooks (Pattern A: copy into .git/hooks/)
HARNESS_HOOKS="${HARNESS_ROOT}/hooks"
GIT_HOOKS_DIR="${REPO_ROOT}/.git/hooks"

if [[ -d "${GIT_HOOKS_DIR}" && -d "${HARNESS_HOOKS}" ]]; then
  for hook_path in "${HARNESS_HOOKS}"/*; do
    [[ -f "${hook_path}" ]] || continue
    hook_name="$(basename "${hook_path}")"
    dst="${GIT_HOOKS_DIR}/${hook_name}"

    if [[ -e "${dst}" || -L "${dst}" ]]; then
      rm -f "${dst}"
    fi

    cp "${hook_path}" "${dst}"
    chmod +x "${dst}"
  done
fi

echo "OpenCode adapter sync complete."
