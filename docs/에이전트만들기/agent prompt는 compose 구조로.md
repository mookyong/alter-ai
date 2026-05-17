# agent prompt는 compose 구조로

 예:

 ```text
 # dbt-orchestrator

@include ../shared/dbt-conventions.md
@include ../shared/naming-rules.md

## 역할

...
```

이 구조의 가장 큰 장점은 아래와 같습니다.

- 설정은 중앙화
- 행동 규칙은 모듈화

---

```text
@include ../shared/dbt-conventions.md
```

위 구문은 Markdown 자체 기능이 아닙니다.

별도의 Markdown 전처리(preprocess) 프로그램이 필요합니다.


# Prompt 합성

합성 전 프롬프트 예시:

```text
agents/
├── primary/
│   └── dbt-orchestrator.md
├── shared/
│   ├── dbt-conventions.md
│   └── naming-rules.md
```

----

실행:

```bash
python build_prompt.py

```

---

추천 폴더 구조:

```text
agents/
├── primary/
│   └── dbt-orchestrator.md
├── shared/
│   ├── dbt-conventions.md
│   ├── naming-rules.md
│   └── orchestration-rules.md
└── build/
    └── build-prompts.py
```

---

build-prompts.py 역할:

1. @include 읽기
1. shared markdown merge
2. 최종 prompt 생성
3. generated prompt 저장

---

generated 폴더:

```text
generated/
├── dbt-orchestrator.prompt.md
├── dbt-discoverer.prompt.md
└── dbt-reviewer.prompt.md
```

opencode.jsonc는 generated 폴더를 바라보도록 설정합니다.

```json
{
  "agent": {
    "dbt-orchestrator": {
      "prompt": "{file:./generated/dbt-orchestrator.prompt.md}"
    }
  }
}
```

---

```text
Prompt source 
→ Prompt build step
→ Generated prompt
→ opencode.json 연결
```

---

최종 폴더 구조:

```text
agents/
├── primary/
│   └── dbt-orchestrator.md
├── shared/
│   ├── dbt-conventions.md
│   ├── naming-rules.md
│   └── orchestration-rules.md
├── build/
│   └── build-prompts.py
└── generated/
    ├── dbt-orchestrator.prompt.md
    ├── dbt-discoverer.prompt.md
    └── dbt-reviewer.prompt.md
```

# Prompt Engineering의 다음 단계

결국 이렇게 진화합니다.

```text
1단계
단일 prompt

2단계
Prompt template

3단계
Prompt composition

4단계
Shared context architecture

5단계
Context contract system
```

