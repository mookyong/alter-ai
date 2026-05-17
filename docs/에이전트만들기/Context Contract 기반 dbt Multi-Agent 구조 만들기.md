# 따라하기 Hands-on

# Context Contract 기반 dbt Multi-Agent 구조 만들기

# 1. Hands-on 목표

이번 Hands-on에서는 다음 구조를 실제로 직접 만들어본다.

```text
사용자
    ↓
Primary Agent (dbt-orchestrator)
    ↓
Context Contract
    ↓
Subagent (dbt-discoverer)
    ↓
Structured Output
    ↓
Primary Agent State Update
```

최종 목표:

```text
1. Prompt Composition 구조 만들기
2. Shared Prompt 재사용하기
3. Context Contract 설계하기
4. Primary Agent 상태 관리자 구조 이해하기
5. Structured Output 기반 orchestration 이해하기
6. OpenCode에서 실행하기
```

이번 Hands-on은 PostgreSQL + dbt 프로젝트를 예시로 진행한다.

---

# 2. 사전 준비

## 필요한 환경

```text
- Python 3.10+
- OpenCode CLI
- PostgreSQL (선택)
- dbt Core (선택)
- VSCode 추천
```

이번 Hands-on은 실제 PostgreSQL 없이도 구조 테스트가 가능하다.

---

# 3. 프로젝트 생성

## Step 1. 디렉토리 생성

터미널에서 실행:

```bash
mkdir prompt-demo
cd prompt-demo
```

---

# 4. 디렉토리 구조 생성

## Step 2. 기본 구조 만들기

```bash
mkdir -p agents/primary
mkdir -p agents/subagents
mkdir -p agents/shared
mkdir -p contracts
mkdir -p context
mkdir -p generated
```

---

## Step 3. 구조 확인

```bash
tree .
```

예상 결과:

```text
.
├── agents
│   ├── primary
│   ├── shared
│   └── subagents
├── contracts
├── context
└── generated
```

---

# 5. Prompt Builder 만들기

## Step 4. build-prompts.py 생성

프로젝트 루트에:

```text
build-prompts.py
```

파일 생성.

---

## Step 5. 아래 코드 붙여넣기

```python
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

# 6. Shared Prompt 만들기

## Step 6. dbt convention prompt 생성

파일:

```text
agents/shared/dbt-conventions.md
```

내용:

```markdown
# dbt conventions

- raw 테이블은 source()로 참조한다.
- 모델 간 연결은 ref()를 사용한다.
- select * 사용을 피한다.
- staging 모델은 정제와 표준화에 집중한다.
- mart 모델은 분석 목적의 결과 모델이다.
```

---

## Step 7. naming rule prompt 생성

파일:

```text
agents/shared/naming-rules.md
```

내용:

```markdown
# naming rules

- staging 모델은 stg_ prefix 사용
- mart 모델은 mart_ prefix 사용
- dimension 모델은 dim_ prefix 사용
- fact 모델은 fct_ prefix 사용
```

---

## Step 8. orchestration rule 생성

파일:

```text
agents/shared/orchestration-rules.md
```

내용:

```markdown
# orchestration rules

다음 상황에서는 dbt-discoverer를 먼저 호출한다.

- 현재 상태 기준 요청
- source.yml 생성 전
- staging 모델 생성 전
- mart 모델 생성 전
- dbt run 실패 후
- dependency가 불확실한 경우
```

---

# 7. Context Contract 만들기

## Step 9. discovery input contract 생성

파일:

```text
contracts/discovery-input.md
```

내용:

```markdown
# Discovery Input Contract

## Required Fields

### Project Context

- project_name
- database_type
- target_schema

### Current State

- known_raw_tables
- known_sources
- known_staging_models

### Discovery Scope

- full_refresh
- target_tables

### Current User Request

- current_goal
```

---

## Step 10. discovery output contract 생성

파일:

```text
contracts/discovery-output.md
```

내용:

```markdown
# Discovery Output Contract

## Required Sections

### 1. Discovery Summary

### 2. Coverage Analysis

### 3. Missing Items

### 4. Dependency Analysis

### 5. Recommended Next Actions
```

---

# 8. Primary Agent 만들기

## Step 11. dbt-orchestrator 생성

파일:

```text
agents/primary/dbt-orchestrator.md
```

내용:

```markdown
# dbt-orchestrator

@include ../shared/dbt-conventions.md
@include ../shared/naming-rules.md
@include ../shared/orchestration-rules.md
@include ../../contracts/discovery-input.md
@include ../../contracts/discovery-output.md

## 역할

당신은 PostgreSQL 기반 dbt 프로젝트를 총괄하는 primary agent이다.

## 핵심 책임

- 현재 프로젝트 상태 모델을 유지한다.
- 필요한 subagent를 선택한다.
- context contract 기반 입력을 생성한다.
- subagent 결과를 검증한다.
- 상태를 업데이트한다.
- 최종 orchestration 결과를 생성한다.

## 중요한 규칙

- subagent에 자연어를 그대로 전달하지 않는다.
- normalized context 기반으로 호출한다.
- structured output contract를 반드시 검증한다.
- 결과를 그대로 사용자에게 전달하지 않는다.
- next action을 생성한다.
```

---

# 9. Subagent 만들기

## Step 12. dbt-discoverer 생성

파일:

```text
agents/subagents/dbt-discoverer.md
```

내용:

```markdown
# dbt-discoverer

@include ../shared/dbt-conventions.md
@include ../../contracts/discovery-input.md
@include ../../contracts/discovery-output.md

## 역할

당신은 PostgreSQL raw schema와 현재 dbt 프로젝트 상태를 탐색하는 subagent이다.

## 목적

Primary agent의 상태 모델을 업데이트하기 위한 structured discovery result를 생성한다.

## 규칙

- discovery-output contract를 반드시 준수한다.
- coverage 계산 필수
- missing item 식별 필수
- dependency 분석 필수
- next action 제안 필수

## 출력 형식

### 1. Discovery Summary

### 2. Coverage Analysis

### 3. Missing Items

### 4. Dependency Analysis

### 5. Recommended Next Actions
```

---

# 10. 상태 모델 만들기

## Step 13. project-state schema 생성

파일:

```text
context/project-state.schema.yaml
```

내용:

```yaml
project:
  name:
  database:
  schema:

raw:
  tables:
    - name:
      columns: []

sources:
  registered_tables: []

staging:
  models:
    - name:
      source:

marts:
  models:
    - name:
      grain:

coverage:
  source_coverage:
  staging_coverage:
  mart_coverage:

issues:
  missing_sources: []
  missing_staging: []

next_actions: []
```

---

# 11. OpenCode 설정

## Step 14. opencode.json 생성

파일:

```text
opencode.json
```

내용:

```json
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
  },
  "command": {
    "discover": {
      "description": "Refresh PostgreSQL raw schema and dbt project state",
      "agent": "dbt-discoverer"
    }
  }
}
```

---

# 12. Prompt Build 실행

## Step 15. Prompt Build 실행

터미널에서:

```bash
python build-prompts.py
```

예상 결과:

```text
[BUILD] agents/primary/dbt-orchestrator.md
[OUTPUT] generated/dbt-orchestrator.prompt.md

[BUILD] agents/subagents/dbt-discoverer.md
[OUTPUT] generated/dbt-discoverer.prompt.md
```

---

# 13. Generated Prompt 확인

## Step 16. generated 확인

```bash
ls generated
```

예상 결과:

```text
dbt-discoverer.prompt.md
dbt-orchestrator.prompt.md
```

---

## Step 17. generated prompt 열어보기

```bash
cat generated/dbt-orchestrator.prompt.md
```

중요 포인트:

```text
@include가 실제 markdown으로 merge 되었는지 확인
```

---

# 14. OpenCode 실행

## Step 18. OpenCode 실행

```bash
opencode
```

---

# 15. 테스트하기

## 테스트 1. Discovery 테스트

```text
현재 PostgreSQL raw schema와 dbt 프로젝트 상태를 다시 탐색해줘.
```

기대 결과:

```text
- structured discovery output
- coverage 분석
- missing item 식별
- next action 추천
```

---

## 테스트 2. Orchestration 테스트

```text
현재 상태 기준으로
orders 관련 staging coverage를 분석해줘.
```

중요 포인트:

```text
discoverer 결과를
primary agent가 orchestration 하는가?
```

---

## 테스트 3. 상태 기반 planning 테스트

```text
현재 상태 기준으로
orders mart 모델 생성 전에 필요한 작업을 정리해줘.
```

좋은 결과 특징:

```text
- dependency 분석
- missing staging 식별
- next action 생성
- 상태 기반 planning
```

---

## 테스트 4. Context Refresh 테스트

```text
raw.payments 테이블이 추가되었어.
현재 상태 기준으로 다음 작업을 추천해줘.
```

중요 포인트:

```text
primary agent가
context refresh 필요성을 인식하는가?
```

---

# 16. Hands-on 핵심 이해 포인트

## 핵심 1

```text
Primary Agent = 상태 관리자
```

Primary Agent의 핵심은:

```text
subagent 호출
❌ 아니다

현재 상태 유지
⭕ 핵심
```

이다.

---

## 핵심 2

```text
Subagent = structured result generator
```

Subagent는:

```text
자유 응답 생성기
❌ 아니다

contract 기반 결과 생성기
⭕ 맞다
```

---

## 핵심 3

```text
멀티 에이전트 핵심 = Context Contract
```

즉:

```text
좋은 multi-agent 구조
=
좋은 context architecture
```

이다.

---

# 17. 최종 정리

이번 Hands-on을 통해 다음 구조를 직접 만들었다.

```text
Context Sharing
+ Structured Contract
+ State Management
```

그리고 가장 중요한 설계 철학은 다음이다.

```text
Subagent = 전문 기능
Primary Agent = 상태 관리자
Contract = 상호작용 규칙
```

이다.

이 구조는 이후 다음 단계로 확장 가능하다.

```text
- contract validator
- prompt lint
- output schema validation
- state persistence
- orchestration memory
- retry strategy
- context budget control
- workflow graph
- agent telemetry
```

즉 이번 Hands-on은 단순 prompt engineering 예제가 아니라:

```text
State-aware Multi-Agent Architecture
```

입문 예제이다.
