# 실행 가능한 Prompt Composition 예시

아래 예시는 실제로 바로 실행 가능한 최소 구조입니다.

목표:

```text id="tn6v0j"
1. shared markdown 재사용
2. @include 지원
3. build-prompts.py 실행
4. generated prompt 생성
5. opencode.json 연결 가능
```

---

# 1. 디렉토리 구조

```text id="v6jx2x"
prompt-demo/
├── build-prompts.py
├── opencode.json
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

---

# 2. build-prompts.py

## build-prompts.py

```python id="77gct0"
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
```

---

# 3. Shared Prompt

## agents/shared/dbt-conventions.md

```markdown id="jlwmv0"
# dbt conventions

- raw 테이블은 source()로 참조한다.
- 모델 간 연결은 ref()를 사용한다.
- select * 사용을 피한다.
- staging 모델은 정제와 표준화에 집중한다.
- mart 모델은 분석 목적의 결과 모델이다.
```

---

## agents/shared/naming-rules.md

```markdown id="jlwmv1"
# naming rules

- staging 모델은 stg_ prefix 사용
- mart 모델은 mart_ prefix 사용
- dimension 모델은 dim_ prefix 사용
- fact 모델은 fct_ prefix 사용
```

---

# 4. Primary Agent Prompt

## agents/primary/dbt-orchestrator.md

```markdown id="jlwmv2"
# dbt-orchestrator

@include ../shared/dbt-conventions.md
@include ../shared/naming-rules.md

## 역할

당신은 PostgreSQL 기반 dbt 프로젝트를 총괄하는 primary agent이다.

## 책임

- 현재 프로젝트 상태 파악
- 필요한 subagent 호출
- source → staging → mart 흐름 유지
- dbt convention 준수
```

---

# 5. Subagent Prompt

## agents/subagents/dbt-discoverer.md

```markdown id="jlwmv3"
# dbt-discoverer

@include ../shared/dbt-conventions.md

## 역할

당신은 PostgreSQL raw schema와 현재 dbt 프로젝트 상태를 탐색하는 subagent이다.

## 산출물 형식

### Discovery Summary

- raw table 수
- source 등록 상태
- staging coverage
- mart coverage

### Missing Items

- missing sources
- missing staging models
- missing tests

### Recommended Next Actions

우선순위 기준으로 다음 작업 제안
```

---

# 6. opencode.json

## opencode.json

```json id="jlwmv4"
{
  "$schema": "https://opencode.ai/config.json",
  "default_agent": "dbt-orchestrator",
  "agent": {
    "dbt-orchestrator": {
      "mode": "primary",
      "prompt": "{file:./generated/dbt-orchestrator.prompt.md}"
    },
    "dbt-discoverer": {
      "mode": "subagent",
      "prompt": "{file:./generated/dbt-discoverer.prompt.md}"
    }
  }
}
```

---

# 7. 실행 방법

## Step 1. 디렉토리 생성

```bash id="jlwmv5"
mkdir -p prompt-demo/agents/primary
mkdir -p prompt-demo/agents/subagents
mkdir -p prompt-demo/agents/shared
mkdir -p prompt-demo/generated
```

---

## Step 2. 파일 저장

위 예시 내용을 각각 파일로 저장합니다.

---

## Step 3. 실행 권한 부여

```bash id="jlwmv6"
chmod +x build-prompts.py
```

---

## Step 4. Prompt Build 실행

```bash id="jlwmv7"
python build-prompts.py
```

예상 출력:

```text id="jlwmv8"
[BUILD] agents/primary/dbt-orchestrator.md
[OUTPUT] generated/dbt-orchestrator.prompt.md

[BUILD] agents/subagents/dbt-discoverer.md
[OUTPUT] generated/dbt-discoverer.prompt.md
```

---

# 8. 생성 결과 확인

## generated/dbt-orchestrator.prompt.md

```markdown id="jlwmv9"
# dbt-orchestrator

<!-- BEGIN INCLUDE: dbt-conventions.md -->

# dbt conventions

- raw 테이블은 source()로 참조한다.
- 모델 간 연결은 ref()를 사용한다.
- select * 사용을 피한다.
- staging 모델은 정제와 표준화에 집중한다.
- mart 모델은 분석 목적의 결과 모델이다.

<!-- END INCLUDE -->

<!-- BEGIN INCLUDE: naming-rules.md -->

# naming rules

- staging 모델은 stg_ prefix 사용
- mart 모델은 mart_ prefix 사용
- dimension 모델은 dim_ prefix 사용
- fact 모델은 fct_ prefix 사용

<!-- END INCLUDE -->

## 역할

당신은 PostgreSQL 기반 dbt 프로젝트를 총괄하는 primary agent이다.
```

---

# 9. 실제 운영 흐름

실제 운영에서는 다음 흐름으로 갑니다.

```text id="jlwmwa"
Markdown Source
    ↓
build-prompts.py
    ↓
generated/*.prompt.md
    ↓
opencode.json
    ↓
OpenCode Agent Runtime
```

---

# 10. 이 구조가 중요한 이유

이 구조를 쓰면:

```text id="jlwmwb"
- 공통 규칙 재사용 가능
- subagent 간 convention 통일 가능
- prompt duplication 제거
- prompt drift 감소
- orchestration rule 중앙 관리 가능
- output schema 공유 가능
```

특히 멀티 에이전트에서 가장 중요한:

```text id="jlwmwc"
“컨텍스트 계약(context contract)”
```

을 안정적으로 유지할 수 있습니다.

---

# 11. 다음 단계 추천

이 다음 단계로는 보통:

```text id="jlwmwd"
1. recursive include 지원
2. circular include 방지
3. output schema import
4. YAML frontmatter
5. prompt lint
6. prompt test
7. prompt versioning
8. generated hash check
9. agent별 context budget 관리
```

까지 확장합니다.

특히 지금 논의 흐름에서는:

```text id="jlwmwe"
Prompt Engineering
→ Prompt Architecture
→ Context Architecture
```

로 이미 넘어간 상태입니다.
