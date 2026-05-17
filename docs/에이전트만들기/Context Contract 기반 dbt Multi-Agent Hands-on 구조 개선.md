# Context Contract 기반 dbt Multi-Agent Hands-on 구조 개선

# 1. 왜 Context Contract가 필요한가?

기존 multi-agent 구조에서는 다음 문제가 자주 발생한다.

```text
- primary agent가 subagent에게 불완전한 context 전달
- subagent마다 출력 형식이 다름
- primary agent가 결과를 안정적으로 해석하지 못함
- orchestration 품질이 agent 성능에 과도하게 의존함
- subagent 결과 재사용이 어려움
- prompt drift 발생
```

특히 dbt 프로젝트는 상태 기반(stateful) 작업이기 때문에 다음 상태 정보가 지속적으로 변한다.

```text
- raw schema
- source.yml
- staging coverage
- mart coverage
- test coverage
- docs coverage
- lineage
```

따라서 multi-agent 구조에서는:

```text
"context를 어떻게 전달할 것인가"
```

가 핵심 문제가 된다.

이 문제를 해결하기 위해 Context Contract 개념을 도입한다.

---

# 2. Context Contract란?

Context Contract는:

```text
Primary Agent ↔ Subagent 간
입력/출력 context 구조를 표준화한 계약
```

이다.

즉:

```text
- 어떤 context를 입력으로 받을 것인가?
- 어떤 결과를 출력으로 반환할 것인가?
- 어떤 상태를 유지할 것인가?
```

를 명확하게 정의한다.

---

# 3. Context Contract 구조

Hands-on에서는 다음 구조를 사용한다.

```text
Primary Agent
    ↓
Normalized Context
    ↓
Subagent
    ↓
Structured Output
    ↓
Primary Agent State Update
```

즉:

```text
사용자 자연어
→ primary agent 내부 상태 모델
→ subagent 입력 contract
→ 정형화된 출력 contract
→ primary agent 상태 갱신
→ 최종 orchestration
```

흐름으로 동작한다.

---

# 4. 프로젝트 구조 변경

기존 구조:

```text
project/
├── agents/
├── generated/
└── opencode.json
```

개선 구조:

```text
project/
├── agents/
│   ├── primary/
│   ├── subagents/
│   └── shared/
├── contracts/
│   ├── discovery-input.md
│   ├── discovery-output.md
│   ├── staging-input.md
│   ├── staging-output.md
│   ├── review-input.md
│   └── review-output.md
├── context/
│   ├── project-state.schema.yaml
│   └── state-examples/
├── generated/
├── build-prompts.py
└── opencode.json
```

핵심 추가 요소는 다음이다.

```text
contracts/
→ agent 간 input/output 계약 정의

context/
→ primary agent 상태 모델 정의
```

---

# 5. Primary Agent 역할 재정의

기존 정의:

```text
primary agent = subagent 호출기
```

개선 정의:

```text
primary agent = 상태 관리자(state manager)
```

즉 primary agent는:

```text
1. 현재 프로젝트 상태 유지
2. 상태 변화 감지
3. 필요한 subagent 선택
4. context contract 기반 입력 생성
5. subagent 결과 검증
6. 상태 업데이트
7. 다음 액션 결정
```

을 수행한다.

---

# 6. Primary Agent 상태 모델

## context/project-state.schema.yaml

```yaml
project:
  name:
  database:
  schema:

raw:
  tables:
    - name:
      columns: []
      pk_candidates: []
      fk_candidates: []

sources:
  registered_tables: []
  missing_tables: []

staging:
  models:
    - name:
      source:
      status:

marts:
  models:
    - name:
      grain:
      dependencies: []

coverage:
  source_coverage:
  staging_coverage:
  mart_coverage:
  test_coverage:
  docs_coverage:

issues:
  missing_sources: []
  missing_staging: []
  missing_tests: []
  failed_models: []

next_actions: []
```

이 상태 모델이:

```text
primary agent의 내부 context memory
```

역할을 한다.

---

# 7. Context Contract 도입 전 문제

예:

사용자 요청:

```text
orders mart 모델 만들어줘.
```

문제 상황:

```text
- stg_orders 존재 여부 불명확
- raw.order_items 존재 여부 불명확
- grain 불명확
- source 등록 여부 불명확
```

이 상태에서 subagent 호출 시:

```text
subagent가 추론 기반으로 동작
→ hallucination 증가
→ 잘못된 모델 생성 가능
```

---

# 8. Context Contract 도입 후 흐름

## Step 1. Primary Agent 상태 확인

```yaml
coverage:
  staging_coverage: partial

issues:
  missing_staging:
    - stg_order_items
```

---

## Step 2. Contract 기반 입력 생성

## contracts/mart-input.md

```markdown
# Mart Modeling Input Contract

## Required Fields

- target_business_domain
- available_staging_models
- missing_dependencies
- grain_candidates
- join_keys
- current_project_state
```

---

## 실제 입력 예시

```yaml
request:
  target_model: mart_customer_orders

available_staging_models:
  - stg_customers
  - stg_orders

missing_dependencies:
  - stg_order_items

grain_candidates:
  - customer_id

join_keys:
  - customer_id
```

---

## Step 3. Subagent 결과

```yaml
recommended_action:
  - create_stg_order_items_first

blocked_reason:
  - incomplete_staging_coverage

recommended_models:
  - mart_customer_orders
```

---

## Step 4. Primary Agent 상태 업데이트

```yaml
next_actions:
  - create_stg_order_items
  - add_relationship_test
  - create_mart_customer_orders
```

---

# 9. dbt-discoverer Contract 개선

기존:

```text
자유 형식 discovery 결과
```

개선:

```text
contract 기반 discovery output
```

---

# 10. Discovery Input Contract

## contracts/discovery-input.md

```markdown
# Discovery Input Contract

## Required Inputs

### Project Context

- project_name
- database_type
- target_schema
- dbt_project_root

### Current State

- known_raw_tables
- known_sources
- known_staging_models
- known_mart_models

### Discovery Scope

- full_refresh
- changed_tables_only
- target_tables

### Current User Request

- current_goal
- current_priority
```

---

# 11. Discovery Output Contract

## contracts/discovery-output.md

```markdown
# Discovery Output Contract

## Required Sections

### 1. Discovery Summary

- discovered_raw_tables
- discovered_sources
- discovered_staging_models
- discovered_marts

### 2. Coverage Analysis

- source_coverage
- staging_coverage
- mart_coverage
- test_coverage

### 3. Missing Items

- missing_sources
- missing_staging_models
- missing_tests
- missing_descriptions

### 4. Dependency Analysis

- missing_dependencies
- broken_refs
- missing_relationships

### 5. Recommended Next Actions

우선순위 기반 action list
```

---

# 12. dbt-discoverer Prompt 개선

## agents/subagents/dbt-discoverer.md

```markdown
# dbt-discoverer

당신은 PostgreSQL raw schema와 현재 dbt 프로젝트 상태를 탐색하는 subagent이다.

## 목적

Primary agent의 project state model을 업데이트하기 위한 structured discovery result를 생성한다.

## 반드시 준수할 것

- discovery-output contract를 반드시 준수한다.
- 결과는 누락 없이 structured format으로 반환한다.
- 추정과 실제 발견 내용을 구분한다.
- coverage 상태를 반드시 계산한다.
- missing item을 반드시 식별한다.
- next action을 우선순위 기반으로 제안한다.

## 입력

discovery-input contract 기반 context

## 출력

discovery-output contract 기반 structured result
```

---

# 13. Primary Agent Contract 활용 방식

## dbt-orchestrator 동작 흐름

```text
1. 현재 project state 확인
2. 부족한 context 식별
3. 필요한 subagent 선택
4. input contract 생성
5. subagent 호출
6. output contract 검증
7. state update
8. next action 생성
9. 사용자 응답 생성
```

---

# 14. 중요한 변경점

기존:

```text
subagent 호출 자체가 중요
```

개선:

```text
context contract 기반 호출이 중요
```

즉:

```text
좋은 multi-agent 구조 =
좋은 contract architecture
```

이다.

---

# 15. 가장 중요한 설계 원칙

## 원칙 1

```text
subagent는 자유 형식 응답을 하지 않는다.
```

항상:

```text
정형화된 output contract
```

를 반환한다.

---

## 원칙 2

```text
primary agent는 자연어를 직접 subagent에 전달하지 않는다.
```

대신:

```text
normalized context
+ input contract
```

형태로 전달한다.

---

## 원칙 3

```text
primary agent는 subagent 결과를 그대로 사용자에게 전달하지 않는다.
```

대신:

```text
state update
→ orchestration
→ next action generation
```

을 수행한다.

---

# 16. Hands-on 코드 변경 포인트

## 기존 테스트 문구

```text
orders staging 모델 만들어줘.
```

---

## 개선 테스트 흐름

### Step 1. State Refresh

```text
현재 PostgreSQL raw schema와 dbt 프로젝트 상태를 다시 탐색해줘.
```

---

### Step 2. Context-Aware Planning

```text
현재 상태 기준으로
orders 관련 staging coverage를 분석해줘.
```

---

### Step 3. Contract-Based Execution

```text
missing staging model 기준으로
다음 작업 우선순위를 제안해줘.
```

---

### Step 4. Controlled Build

```text
현재 contract state 기준으로
stg_order_items 모델 생성 방향을 설계해줘.
```

---

# 17. 최종 핵심 메시지

Multi-agent의 핵심은 단순한 agent 분리가 아니다.

핵심은:

```text
Context Sharing
+ Structured Contract
+ State Management
```

이다.

그리고 가장 중요한 것은:

```text
Primary agent가
현재 프로젝트 상태 모델을 유지하는 것
```

이다.

즉:

```text
Subagent = 전문 기능
Primary Agent = 상태 관리자
Contract = 상호작용 규칙
```

구조로 이해하는 것이 가장 적절하다.

---

# 18. 정리

이번 개선을 통해 Hands-on 구조는:

```text
단순 Prompt Engineering
```

에서:

```text
Context Architecture 기반
Multi-Agent System 설계
```

로 확장되었다.

핵심 변화는 다음과 같다.

```text
1. Context Contract 도입
2. Primary Agent 상태 모델 도입
3. Structured Input/Output 정의
4. Coverage 기반 orchestration
5. State-aware agent execution
6. Contract 기반 subagent 설계
```

이 구조를 적용하면:

```text
- hallucination 감소
- orchestration 안정성 증가
- subagent 재사용성 증가
- context drift 감소
- prompt duplication 감소
- multi-agent maintainability 증가
```

효과를 얻을 수 있다.
