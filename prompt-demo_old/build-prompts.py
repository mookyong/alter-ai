#!/usr/bin/env python3

from pathlib import Path
import re

ROOT_DIR = Path(__file__).parent.resolve()

AGENTS_DIR = ROOT_DIR / "agents"
GENERATED_DIR = ROOT_DIR / "generated"

INCLUDE_PATTERN = re.compile(
    r"^\s*@include\s+(.+?)\s*$",
    re.MULTILINE,
)


def read_file(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def write_file(path: Path, content: str):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def resolve_includes(file_path: Path):
    content = read_file(file_path)

    def replace_include(match):
        include_target = match.group(1).strip()

        include_file = (
            file_path.parent / include_target
        ).resolve()

        included_content = read_file(include_file)

        return (
            f"\n"
            f"<!-- BEGIN INCLUDE: {include_file.name} -->\n"
            f"{included_content}\n"
            f"<!-- END INCLUDE -->\n"
        )

    return re.sub(
        INCLUDE_PATTERN,
        replace_include,
        content,
    )


def build_prompt(md_file: Path):
    print(f"[BUILD] {md_file}")

    resolved = resolve_includes(md_file)

    output_name = md_file.stem + ".prompt.md"
    output_path = GENERATED_DIR / output_name

    write_file(output_path, resolved)

    print(f"[OUTPUT] {output_path}")


def main():
    GENERATED_DIR.mkdir(exist_ok=True)

    targets = [
        AGENTS_DIR / "primary" / "dbt-orchestrator.md",
        AGENTS_DIR / "subagents" / "dbt-discoverer.md",
    ]

    for target in targets:
        build_prompt(target)


if __name__ == "__main__":
    main()
    