#!/usr/bin/env python3
"""Lightweight validator for AgentSkills metadata and local semantic bodies.

This intentionally supports a simple YAML frontmatter subset so it can run
without third-party dependencies in constrained agent environments.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path


NAME_RE = re.compile(r"^[a-z0-9][a-z0-9-]{0,63}$")
TAG_RE = re.compile(r"</?([a-zA-Z][a-zA-Z0-9_-]*)(?:\s[^<>]*)?>")
VOID_TAGS = {"br", "hr", "img", "input", "meta", "link"}
REFERENCE_RE = re.compile(r"`((?:references|assets|scripts)/[^`]+)`")
MARKDOWN_LINK_RE = re.compile(r"\[[^\]]+\]\(((?:references|assets|scripts)/[^)\s]+)\)")
FENCED_CODE_RE = re.compile(r"```.*?```", re.DOTALL)
INLINE_CODE_RE = re.compile(r"`[^`]*`")


def fail(message: str) -> None:
    print(f"ERROR: {message}")


def warn(message: str) -> None:
    print(f"WARN: {message}")


def parse_frontmatter(text: str) -> tuple[dict[str, str], str, list[str]]:
    errors: list[str] = []
    if not text.startswith("---\n"):
        return {}, text, ["missing YAML frontmatter fence at start of file"]

    end = text.find("\n---", 4)
    if end == -1:
        return {}, text, ["missing closing YAML frontmatter fence"]

    raw = text[4:end]
    body = text[end + len("\n---") :].lstrip("\n")
    data: dict[str, str] = {}
    for index, line in enumerate(raw.splitlines(), start=1):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if ":" not in stripped:
            errors.append(f"frontmatter line {index} is not key: value")
            continue
        key, value = stripped.split(":", 1)
        value = value.strip().strip('"').strip("'")
        data[key.strip()] = value
    return data, body, errors


def check_tags(body: str) -> list[str]:
    errors: list[str] = []
    stack: list[str] = []
    visible_body = strip_markdown_code(body)
    for match in TAG_RE.finditer(visible_body):
        full = match.group(0)
        tag = match.group(1)
        if tag.lower() in VOID_TAGS or full.endswith("/>"):
            continue
        if full.startswith("</"):
            if not stack:
                errors.append(f"closing tag </{tag}> without opener")
            elif stack[-1] != tag:
                errors.append(f"closing tag </{tag}> does not match <{stack[-1]}> ({' > '.join(stack)})")
            else:
                stack.pop()
        else:
            stack.append(tag)
    if stack:
        errors.append(f"unclosed tag stack: {' > '.join(stack)}")
    return errors


def strip_markdown_code(text: str) -> str:
    without_fences = FENCED_CODE_RE.sub("", text)
    return INLINE_CODE_RE.sub("", without_fences)


def normalize_reference(raw_ref: str) -> str:
    return raw_ref.split()[0].rstrip(".,;:").split("#", 1)[0]


def is_under_directory(path: Path, directory: Path) -> bool:
    try:
        path.relative_to(directory)
    except ValueError:
        return False
    return True


def collect_supporting_references(body: str) -> set[str]:
    refs = set(REFERENCE_RE.findall(body))
    refs.update(MARKDOWN_LINK_RE.findall(body))
    return {normalize_reference(ref) for ref in refs if normalize_reference(ref)}


def check_references(skill_file: Path, body: str) -> list[str]:
    errors: list[str] = []
    base_dir = skill_file.parent.resolve()
    for ref in sorted(collect_supporting_references(body)):
        ref_path = Path(ref)
        if ref_path.is_absolute() or ".." in ref_path.parts:
            errors.append(f"referenced supporting file must stay inside the skill directory: {ref}")
            continue
        path = (base_dir / ref_path).resolve()
        if not is_under_directory(path, base_dir):
            errors.append(f"referenced supporting file escapes the skill directory: {ref}")
            continue
        if not path.exists():
            errors.append(f"referenced supporting file does not exist: {ref}")
    return errors


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: validate-skill.py path/to/SKILL.md")
        return 2

    skill_file = Path(sys.argv[1]).resolve()
    if not skill_file.exists():
        fail(f"file does not exist: {skill_file}")
        return 1
    if skill_file.name != "SKILL.md":
        fail("target file must be named SKILL.md")
        return 1

    text = skill_file.read_text(encoding="utf-8")
    frontmatter, body, errors = parse_frontmatter(text)

    name = frontmatter.get("name", "")
    description = frontmatter.get("description", "")
    directory_name = skill_file.parent.name

    if not name:
        errors.append("frontmatter is missing required name")
    elif not NAME_RE.match(name):
        errors.append("name must be lowercase alphanumeric/hyphen and max 64 characters")
    elif name != directory_name:
        errors.append(f"name '{name}' does not match directory '{directory_name}'")

    if not description:
        errors.append("frontmatter is missing required description")
    elif "<" in description or ">" in description:
        errors.append("description must not contain XML angle brackets")
    elif len(description) > 1024:
        errors.append("description exceeds 1024 characters")
    elif len(description.split()) < 6:
        warn("description may be too short to explain what and when")

    if len(text.splitlines()) > 500:
        warn("SKILL.md exceeds 500 lines; consider moving detail to references")

    if "<skill>" in body or "</skill>" in body:
        errors.extend(check_tags(body))
        if "<purpose>" not in body:
            errors.append("semantic body uses <skill> but is missing <purpose>")
        if "<critical>" not in body:
            errors.append("semantic body uses <skill> but is missing <critical>")

    errors.extend(check_references(skill_file, body))

    if errors:
        for message in errors:
            fail(message)
        return 1

    print(f"OK: {skill_file} passes baseline AgentSkills and local semantic checks")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
