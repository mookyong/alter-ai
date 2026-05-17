
# build-prompts.py 코드 구현

```python
#!/usr/bin/env python3
"""
build-prompts.py

Markdown 기반 Agent Prompt Composition Builder

기능:
- @include 상대경로 지원
- recursive include 지원
- circular include 방지
- generated/*.prompt.md 생성
- agents/**/*.md 대상으로 처리 가능

예시:
    python build-prompts.py

입력 구조:
    agents/
    ├── primary/
    │   └── dbt-orchestrator.md
    ├── subagents/
    │   └── dbt-discoverer.md
    └── shared/
        ├── dbt-conventions.md
        └── naming-rules.md

출력 구조:
    generated/
    ├── dbt-orchestrator.prompt.md
    └── dbt-discoverer.prompt.md
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import Set

# =========================================================
# CONFIG
# =========================================================

ROOT_DIR = Path(__file__).parent.resolve()

AGENTS_DIR = ROOT_DIR / "agents"
GENERATED_DIR = ROOT_DIR / "generated"

INCLUDE_PATTERN = re.compile(
    r"^\s*@include\s+(.+?)\s*$",
    re.MULTILINE,
)

# shared는 독립 prompt 생성 대상 제외
EXCLUDE_DIRS = {"shared"}

# =========================================================
# HELPERS
# =========================================================


def read_file(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def write_file(path: Path, content: str):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def normalize_include_path(base_file: Path, include_path: str) -> Path:
    """
    상대 include 경로를 절대 Path로 변환
    """
    include_path = include_path.strip()

    # 따옴표 제거
    include_path = include_path.strip("\"'")
    resolved = (base_file.parent / include_path).resolve()

    return resolved


# =========================================================
# CORE
# =========================================================


def resolve_includes(
    file_path: Path,
    visited: Set[Path] | None = None,
    depth: int = 0,
) -> str:
    """
    recursive include 처리
    """

    if visited is None:
        visited = set()

    file_path = file_path.resolve()

    if file_path in visited:
        raise RuntimeError(
            f"[ERROR] Circular include detected:\n"
            f" -> {file_path}"
        )

    if not file_path.exists():
        raise FileNotFoundError(
            f"[ERROR] Include file not found:\n"
            f" -> {file_path}"
        )

    visited.add(file_path)

    content = read_file(file_path)

    def replace_include(match):
        include_target = match.group(1)

        include_file = normalize_include_path(
            file_path,
            include_target,
        )

        print(
            f"{'  ' * depth}[INCLUDE] "
            f"{file_path.name} -> {include_file.name}"
        )

        included_content = resolve_includes(
            include_file,
            visited=visited.copy(),
            depth=depth + 1,
        )

        return (
            f"\n"
            f"<!-- BEGIN INCLUDE: {include_file.relative_to(ROOT_DIR)} -->\n"
            f"{included_content}\n"
            f"<!-- END INCLUDE: {include_file.relative_to(ROOT_DIR)} -->\n"
        )

    resolved_content = re.sub(
        INCLUDE_PATTERN,
        replace_include,
        content,
    )

    return resolved_content


# =========================================================
# BUILD
# =========================================================


def should_build(md_file: Path) -> bool:
    """
    shared 디렉토리 제외
    """

    relative_parts = md_file.relative_to(AGENTS_DIR).parts

    if relative_parts[0] in EXCLUDE_DIRS:
        return False

    return True


def build_prompt(md_file: Path):
    """
    단일 prompt build
    """

    print(f"\n[BUILD] {md_file.relative_to(ROOT_DIR)}")

    resolved = resolve_includes(md_file)

    output_name = md_file.stem + ".prompt.md"
    output_path = GENERATED_DIR / output_name

    write_file(output_path, resolved)

    print(f"[OUTPUT] {output_path.relative_to(ROOT_DIR)}")


def build_all():
    """
    전체 prompt build
    """

    GENERATED_DIR.mkdir(exist_ok=True)

    md_files = sorted(AGENTS_DIR.rglob("*.md"))

    build_targets = [
        f for f in md_files
        if should_build(f)
    ]

    print("=" * 60)
    print("Prompt Build Started")
    print("=" * 60)

    for md_file in build_targets:
        build_prompt(md_file)

    print("\n" + "=" * 60)
    print("Prompt Build Completed")
    print("=" * 60)


# =========================================================
# MAIN
# =========================================================

if __name__ == "__main__":
    build_all()
```

예시 사용 구조:

```text id="gqexf9"
project/
├── build-prompts.py
├── agents/
│   ├── primary/
│   │   └── dbt-orchestrator.md
│   ├── subagents/
│   │   └── dbt-discoverer.md
│   └── shared/
│       ├── dbt-conventions.md
│       └── naming-rules.md
└── generated/
```

예시 source prompt:

## agents/primary/dbt-orchestrator.md

```markdown id="5t9s77"
# dbt-orchestrator

@include ../shared/dbt-conventions.md
@include ../shared/naming-rules.md

## 역할

당신은 PostgreSQL 기반 dbt 프로젝트를 총괄하는 primary agent이다.
```

## agents/shared/dbt-conventions.md

```markdown id="w9yqz0"
# dbt conventions

- raw 테이블은 source()로 참조한다.
- 모델 간 연결은 ref()를 사용한다.
- select * 사용을 피한다.
```

생성 결과:

## generated/dbt-orchestrator.prompt.md

```markdown id="2i3ytm"
# dbt-orchestrator

<!-- BEGIN INCLUDE: agents/shared/dbt-conventions.md -->

# dbt conventions

- raw 테이블은 source()로 참조한다.
- 모델 간 연결은 ref()를 사용한다.
- select * 사용을 피한다.

<!-- END INCLUDE: agents/shared/dbt-conventions.md -->

<!-- BEGIN INCLUDE: agents/shared/naming-rules.md -->

...

<!-- END INCLUDE -->

## 역할

당신은 PostgreSQL 기반 dbt 프로젝트를 총괄하는 primary agent이다.
```

그리고 opencode.json은 generated 파일을 참조합니다.

```json id="k18kg4"
{
  "agent": {
    "dbt-orchestrator": {
      "prompt": "{file:./generated/dbt-orchestrator.prompt.md}"
    }
  }
}
```

이 구조의 장점:

```text id="2kzjlwm"
1. shared rule 재사용 가능
2. prompt duplication 제거
3. prompt drift 감소
4. agent behavior 중앙 관리 가능
5. orchestration 규칙 공유 가능
6. output schema 재사용 가능
7. generated artifact 기반 운영 가능
8. Git diff 가독성 향상
```

그리고 중요한 철학은 이겁니다.

```text id="jlwmm0"
Prompt도 “소스 코드”처럼
모듈화 + 빌드 + 생성물 관리
구조로 가야 한다.
```
