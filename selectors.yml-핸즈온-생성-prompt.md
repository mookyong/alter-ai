#--------------------

아료 자료기반으로 postgres 전용 교육용 핸즈용 dbt 프로젝트를 만들어줘. 절차는 다음 같습니다.

- 프로젝트를 dbt Core + Postgres 기준으로 여부 질문?
- 예시 도메인은 질문(예:주문/고객/상품)?
- 일반적인 dbt 프로젝트 형식으로 생성
- 도메인에 맞춘 샘플 데이터 목록 제시 및 사용자 선택
- 샘플 데이터 생성(seed용 csv 또는 insert sql)
- 도메인 및 샘플 데이터에 맞춘 모델 생성
- docker compose 파일 생성
- 프로젝트 실행 방법 제시

#--------------------



좋습니다. 1차로 **기본 사용법 + 실무에서 제일 자주 쓰는 selector 예시**만 설명드릴게요.

먼저 파일명은 보통 **`selector.yml`이 아니라 `selectors.yml`** 입니다.
`dbt_project.yml`과 같은 최상위 위치에 둡니다.

```text
my_dbt_project/
├─ dbt_project.yml
├─ selectors.yml
├─ models/
│  ├─ staging/
│  ├─ marts/
│  └─ intermediate/
```

`selectors.yml`은 복잡한 `--select` 조건을 이름 붙여 저장해두는 파일입니다. dbt 공식 문서에서도 selector는 최상위 `selectors.yml` 파일에 저장하고, 각 selector는 `name`과 `definition`을 가져야 한다고 설명합니다. ([docs.getdbt.com][1])

---

## 1. selector를 왜 쓰는가?

원래는 이렇게 실행합니다.

```bash
dbt build --select "tag:daily"
```

그런데 조건이 길어지면 매번 치기 귀찮고, Airflow나 CI/CD에 넣기도 지저분해집니다.

그래서 `selectors.yml`에 이렇게 이름을 붙입니다.

```yaml
selectors:
  - name: daily
    description: "매일 실행할 모델"
    definition:
      method: tag
      value: daily
```

이제 실행할 때는 이렇게 씁니다.

```bash
dbt build --selector daily
```

즉,

```bash
dbt build --select "tag:daily"
```

와 비슷한 의미를

```bash
dbt build --selector daily
```

로 바꿔 쓰는 겁니다.

---

## 2. 기본 예시: daily 태그가 붙은 모델만 실행

### 모델에 태그 달기

예를 들어 `models/marts/fct_orders.sql`에 태그를 붙입니다.

```sql
{{ config(
    materialized='table',
    tags=['daily']
) }}

select *
from {{ ref('stg_orders') }}
```

또는 `schema.yml`에서 모델에 태그를 줄 수도 있습니다.

```yaml
models:
  - name: fct_orders
    config:
      tags: ['daily']
```

dbt에서는 `tag:` selector method로 특정 태그가 붙은 모델을 선택할 수 있습니다. 공식 문서 예시도 `dbt run --select "tag:nightly"`처럼 태그 기반 실행을 보여줍니다. ([docs.getdbt.com][2])

### selectors.yml

```yaml
selectors:
  - name: daily
    description: "daily 태그가 붙은 모델 실행"
    definition:
      method: tag
      value: daily
```

### 실행

```bash
dbt ls --selector daily
```

먼저 `ls`로 어떤 모델이 잡히는지 확인합니다.

```bash
dbt build --selector daily
```

실제 실행은 이렇게 합니다.

여기서 핵심은 이겁니다.

```yaml
method: tag
value: daily
```

이건 CLI로 치면 아래와 같습니다.

```bash
--select "tag:daily"
```

---

## 3. 경로 기준 selector: marts 폴더만 실행

실무에서는 보통 폴더 구조가 이렇게 나뉩니다.

```text
models/
├─ staging/
├─ intermediate/
└─ marts/
   ├─ finance/
   └─ marketing/
```

이때 `models/marts` 아래 모델만 실행하고 싶으면 selector를 이렇게 만들 수 있습니다.

```yaml
selectors:
  - name: marts
    description: "models/marts 하위 모델 실행"
    definition:
      method: path
      value: models/marts
```

실행:

```bash
dbt ls --selector marts
dbt build --selector marts
```

이건 CLI로 보면 대략 아래와 같은 의미입니다.

```bash
dbt build --select "path:models/marts"
```

dbt의 selector method는 `method:value` 형식으로 리소스를 선택하며, 여러 selector method를 조합할 수도 있습니다. ([docs.getdbt.com][2])

---

## 4. 경로 + 태그를 같이 쓰기: marts 중 daily만 실행

이게 `selectors.yml`을 쓰는 진짜 이유에 가깝습니다.

예를 들어 조건이 이렇다고 합시다.

> `models/marts` 아래에 있으면서, `daily` 태그가 붙은 모델만 실행하고 싶다.

CLI로 쓰면 이런 느낌입니다.

```bash
dbt build --select "models/marts,tag:daily"
```

근데 이걸 매번 쓰기 귀찮으니까 selector로 뺍니다.

```yaml
selectors:
  - name: daily_marts
    description: "marts 폴더 안에 있고 daily 태그가 붙은 모델"
    definition:
      intersection:
        - method: path
          value: models/marts
        - method: tag
          value: daily
```

실행:

```bash
dbt ls --selector daily_marts
dbt build --selector daily_marts
```

여기서 중요한 문법은 `intersection`입니다.

```yaml
intersection:
  - method: path
    value: models/marts
  - method: tag
    value: daily
```

뜻은:

```text
models/marts 아래에 있는 모델
AND
daily 태그가 붙은 모델
```

입니다.

반대로 `union`은 OR입니다.

```yaml
union:
  - method: tag
    value: daily
  - method: tag
    value: hourly
```

뜻은:

```text
daily 태그 모델
OR
hourly 태그 모델
```

입니다.

dbt 공식 문서에서도 `union`, `intersection`으로 여러 선택 조건을 구성할 수 있다고 설명합니다. ([docs.getdbt.com][1])

---

## 여기까지 정리

`selectors.yml`은 쉽게 말하면 이겁니다.

```text
긴 dbt --select 조건에 이름을 붙여두는 파일
```

자주 쓰는 패턴은 이 세 가지입니다.

```yaml
# 1. 태그 기준
method: tag
value: daily

# 2. 경로 기준
method: path
value: models/marts

# 3. AND 조건
intersection:
  - method: path
    value: models/marts
  - method: tag
    value: daily
```

실무에서는 보통 이렇게 확인 후 실행합니다.

```bash
dbt ls --selector daily_marts
dbt build --selector daily_marts
```

다음 단계에서는 **exclude 사용법**을 설명드리면 좋습니다. 예를 들면 “daily는 돌리되, 너무 무거운 backfill 모델은 제외하기” 같은 실무형 패턴입니다.

[1]: https://docs.getdbt.com/reference/node-selection/yaml-selectors "YAML Selectors | dbt Developer Hub"
[2]: https://docs.getdbt.com/reference/node-selection/methods "Node selector methods | dbt Developer Hub"


좋습니다. 이번에는 **`exclude` 사용법**만 보겠습니다.

핵심은 이겁니다.

```text
먼저 실행 대상을 고르고,
그중에서 제외할 대상을 뺀다.
```

dbt에서도 `--exclude`는 `--select`로 선택된 대상 집합에서 특정 모델을 제거하는 방식으로 동작합니다. ([docs.getdbt.com][1])

---

## 1. CLI에서 먼저 이해하기

예를 들어 daily 태그가 붙은 모델은 실행하되,

```bash
dbt build --select "tag:daily"
```

그중에서 backfill 태그가 붙은 무거운 모델은 제외하고 싶다면 이렇게 합니다.

```bash
dbt build --select "tag:daily" --exclude "tag:backfill"
```

뜻은 이겁니다.

```text
daily 태그가 붙은 모델을 실행한다.
단, backfill 태그가 붙은 모델은 제외한다.
```

---

## 2. selectors.yml로 바꾸기

위 명령어를 `selectors.yml`에 저장하면 이렇게 됩니다.

```yaml
selectors:
  - name: daily_without_backfill
    description: "daily 태그 모델 중 backfill 태그 모델은 제외"
    definition:
      method: tag
      value: daily
      exclude:
        - method: tag
          value: backfill
```

실행은 이렇게 합니다.

```bash
dbt ls --selector daily_without_backfill
dbt build --selector daily_without_backfill
```

먼저 `dbt ls`로 어떤 모델이 선택되는지 확인하고, 그 다음 `dbt build`를 실행하는 습관이 좋습니다.

---

## 3. 예시 모델 구조

예를 들어 모델들이 이렇게 있다고 해보겠습니다.

```text
models/
├─ marts/
│  ├─ fct_orders.sql          # daily
│  ├─ fct_sales.sql           # daily
│  ├─ fct_order_history.sql   # daily, backfill
│  └─ fct_user_snapshot.sql   # daily, backfill
```

각 모델 설정이 이렇게 되어 있다고 합시다.

```sql
-- fct_orders.sql
{{ config(
    materialized='table',
    tags=['daily']
) }}

select *
from {{ ref('stg_orders') }}
```

```sql
-- fct_order_history.sql
{{ config(
    materialized='table',
    tags=['daily', 'backfill']
) }}

select *
from {{ ref('stg_order_history') }}
```

이 상태에서 아래 selector를 실행하면,

```yaml
selectors:
  - name: daily_without_backfill
    description: "daily 태그 모델 중 backfill 태그 모델은 제외"
    definition:
      method: tag
      value: daily
      exclude:
        - method: tag
          value: backfill
```

선택 결과는 대략 이렇게 됩니다.

```text
선택됨:
- fct_orders
- fct_sales

제외됨:
- fct_order_history
- fct_user_snapshot
```

---

## 4. path와 exclude 같이 쓰기

이번에는 이런 조건을 생각해보겠습니다.

> `models/marts` 아래 모델을 실행하되, `backfill` 태그는 제외한다.

```yaml
selectors:
  - name: marts_without_backfill
    description: "marts 모델 중 backfill 태그는 제외"
    definition:
      method: path
      value: models/marts
      exclude:
        - method: tag
          value: backfill
```

실행:

```bash
dbt ls --selector marts_without_backfill
dbt build --selector marts_without_backfill
```

CLI로 쓰면 아래와 비슷합니다.

```bash
dbt build --select "path:models/marts" --exclude "tag:backfill"
```

---

## 5. daily + marts + backfill 제외

조금 더 실무형으로 가보겠습니다.

조건은 이렇습니다.

```text
models/marts 아래에 있고
daily 태그가 붙어 있으며
backfill 태그는 제외한다.
```

이건 `intersection`과 `exclude`를 같이 쓰면 됩니다.

```yaml
selectors:
  - name: daily_marts_without_backfill
    description: "marts 폴더의 daily 모델 중 backfill 모델 제외"
    definition:
      intersection:
        - method: path
          value: models/marts
        - method: tag
          value: daily
      exclude:
        - method: tag
          value: backfill
```

실행:

```bash
dbt ls --selector daily_marts_without_backfill
dbt build --selector daily_marts_without_backfill
```

해석하면 이렇습니다.

```text
1. models/marts 아래 모델을 고른다.
2. 그중 daily 태그가 붙은 모델만 남긴다.
3. 그중 backfill 태그가 붙은 모델은 뺀다.
```

dbt의 YAML selector에서는 `union`, `intersection`, `exclude` 같은 구조로 여러 선택 조건을 조합할 수 있습니다. ([docs.getdbt.com][2])

---

## 6. 여러 개 제외하기

예를 들어 daily 실행에서 아래 모델들을 제외하고 싶다고 합시다.

```text
- backfill 태그 모델
- experimental 태그 모델
- 특정 모델 하나
```

그러면 이렇게 쓸 수 있습니다.

```yaml
selectors:
  - name: safe_daily
    description: "daily 실행 대상 중 무거운 모델과 실험 모델 제외"
    definition:
      method: tag
      value: daily
      exclude:
        - method: tag
          value: backfill
        - method: tag
          value: experimental
        - method: fqn
          value: fct_legacy_orders
```

실행:

```bash
dbt build --selector safe_daily
```

뜻은 이겁니다.

```text
daily 태그 모델 실행
단, backfill 태그 제외
단, experimental 태그 제외
단, fct_legacy_orders 모델 제외
```

---

## 7. 실무에서 추천하는 태그 설계

저라면 이렇게 태그를 나눕니다.

```text
daily       : 매일 실행
hourly      : 시간 단위 실행
weekly      : 주간 실행
backfill    : 과거 데이터 대량 재처리용
heavy       : 실행 비용이 큰 모델
experimental: 검증 중인 모델
manual      : 수동 실행 전용
```

그러면 selector를 이렇게 만들 수 있습니다.

```yaml
selectors:
  - name: daily_normal
    description: "일반 daily 배치용. 무거운 모델과 수동 모델 제외"
    definition:
      method: tag
      value: daily
      exclude:
        - method: tag
          value: backfill
        - method: tag
          value: heavy
        - method: tag
          value: manual
```

Airflow에서는 이렇게 호출하면 됩니다.

```bash
dbt build --selector daily_normal
```

---

## 핵심 정리

`exclude`는 이렇게 이해하면 됩니다.

```yaml
definition:
  method: tag
  value: daily
  exclude:
    - method: tag
      value: backfill
```

뜻:

```text
daily는 실행한다.
하지만 backfill은 뺀다.
```

실무적으로는 이 패턴이 제일 자주 쓰입니다.

```yaml
selectors:
  - name: daily_normal
    definition:
      method: tag
      value: daily
      exclude:
        - method: tag
          value: heavy
        - method: tag
          value: backfill
        - method: tag
          value: manual
```

다음 단계로는 **`+` 그래프 연산자와 selector 조합**을 보면 좋습니다. 예를 들어 “선택한 marts 모델과 그 upstream staging 모델까지 같이 실행하기” 같은 패턴입니다.

[1]: https://docs.getdbt.com/reference/node-selection/exclude?utm_source=chatgpt.com "Exclude models from your run | dbt Developer Hub"
[2]: https://docs.getdbt.com/reference/node-selection/yaml-selectors?utm_source=chatgpt.com "YAML Selectors | dbt Developer Hub"

좋습니다. 이번 단계는 **`+` 그래프 연산자와 selector 조합**입니다.

핵심은 이겁니다.

```text
선택한 모델만 실행할지,
선택한 모델의 upstream/downstream까지 같이 실행할지 정하는 기능
```

dbt 공식 문서 기준으로 `+` 연산자는 선택한 리소스의 **상위 의존성 ancestors / upstream** 또는 **하위 의존성 descendants / downstream**까지 선택 범위를 확장합니다. ([docs.getdbt.com][1])

---

# 1. 먼저 CLI에서 `+` 이해하기

예를 들어 모델 흐름이 이렇게 있다고 해보겠습니다.

```text
stg_orders
   ↓
int_orders
   ↓
fct_orders
   ↓
mart_sales_summary
```

## 특정 모델만 실행

```bash
dbt build --select fct_orders
```

선택 결과:

```text
fct_orders
```

---

## upstream까지 같이 실행

```bash
dbt build --select +fct_orders
```

선택 결과:

```text
stg_orders
int_orders
fct_orders
```

즉, `+`가 **앞에 붙으면 부모 모델까지 포함**합니다.

dbt 공식 문서에서도 `+my_model`은 해당 모델과 모든 ancestors를 선택한다고 설명합니다. ([docs.getdbt.com][1])

---

## downstream까지 같이 실행

```bash
dbt build --select fct_orders+
```

선택 결과:

```text
fct_orders
mart_sales_summary
```

즉, `+`가 **뒤에 붙으면 자식 모델까지 포함**합니다.

공식 문서 기준으로 `my_model+`은 해당 리소스와 모든 descendants를 선택합니다. ([docs.getdbt.com][1])

---

## upstream + downstream 모두 실행

```bash
dbt build --select +fct_orders+
```

선택 결과:

```text
stg_orders
int_orders
fct_orders
mart_sales_summary
```

즉, 앞뒤에 `+`를 붙이면 부모와 자식이 모두 포함됩니다.

---

# 2. selectors.yml에서 `+` 표현하기

`selectors.yml`에서는 두 가지 방식이 있습니다.

## 방식 1: CLI-style로 그대로 쓰기

가장 직관적인 방식입니다.

```yaml
selectors:
  - name: fct_orders_with_parents
    description: "fct_orders와 upstream 모델까지 실행"
    definition: "+fct_orders"
```

실행:

```bash
dbt ls --selector fct_orders_with_parents
dbt build --selector fct_orders_with_parents
```

이 방식은 CLI의 `+fct_orders`를 그대로 selector에 저장한 것입니다.

dbt 공식 문서에 따르면 YAML selector의 CLI-style 정의는 `+`, `@`, `*` 같은 graph operator를 지원합니다. ([docs.getdbt.com][2])

---

## 방식 2: Full YAML 방식으로 쓰기

조금 더 명시적으로 쓰고 싶으면 이렇게 합니다.

```yaml
selectors:
  - name: fct_orders_with_parents
    description: "fct_orders와 upstream 모델까지 실행"
    definition:
      method: fqn
      value: fct_orders
      parents: true
```

이건 CLI로 보면 아래와 같습니다.

```bash
dbt build --select +fct_orders
```

여기서 핵심은 이 부분입니다.

```yaml
parents: true
```

뜻:

```text
선택한 모델의 부모 모델까지 포함한다.
```

dbt 공식 문서에서도 YAML selector의 full YAML 방식에서 `parents`, `children`, `parents_depth`, `children_depth`를 사용할 수 있다고 설명합니다. ([docs.getdbt.com][2])

---

# 3. downstream까지 포함하기

이번에는 `fct_orders`와 그 아래 자식 모델까지 실행한다고 해보겠습니다.

CLI:

```bash
dbt build --select fct_orders+
```

selectors.yml:

```yaml
selectors:
  - name: fct_orders_with_children
    description: "fct_orders와 downstream 모델까지 실행"
    definition:
      method: fqn
      value: fct_orders
      children: true
```

뜻:

```text
fct_orders를 선택하고,
fct_orders를 참조하는 하위 모델까지 같이 실행한다.
```

예상 선택 결과:

```text
fct_orders
mart_sales_summary
```

---

# 4. upstream + downstream 모두 포함하기

CLI:

```bash
dbt build --select +fct_orders+
```

selectors.yml:

```yaml
selectors:
  - name: fct_orders_full_lineage
    description: "fct_orders의 upstream과 downstream을 모두 포함"
    definition:
      method: fqn
      value: fct_orders
      parents: true
      children: true
```

뜻:

```text
fct_orders 기준으로
위쪽 모델도 실행하고
아래쪽 모델도 실행한다.
```

예상 선택 결과:

```text
stg_orders
int_orders
fct_orders
mart_sales_summary
```

---

# 5. depth 제한하기

`+`를 쓰면 기본적으로 연결된 부모나 자식을 끝까지 따라갈 수 있습니다.

그런데 실무에서는 이렇게 하고 싶을 때가 있습니다.

```text
바로 위 부모까지만 실행하고 싶다.
전체 upstream까지는 너무 무겁다.
```

이때는 `parents_depth`를 씁니다.

```yaml
selectors:
  - name: fct_orders_one_parent
    description: "fct_orders와 1단계 upstream만 실행"
    definition:
      method: fqn
      value: fct_orders
      parents: true
      parents_depth: 1
```

모델 흐름이 이렇다면:

```text
raw_orders
   ↓
stg_orders
   ↓
int_orders
   ↓
fct_orders
```

선택 결과는 대략 이렇게 됩니다.

```text
int_orders
fct_orders
```

즉, `parents_depth: 1`은 **바로 위 부모만 포함**합니다.

CLI로 쓰면 비슷하게:

```bash
dbt build --select 1+fct_orders
```

공식 문서에서도 `2+my_model`, `my_model+1`, `3+my_model+4`처럼 숫자로 그래프 탐색 깊이를 제한할 수 있다고 설명합니다. ([docs.getdbt.com][1])

---

# 6. daily marts + upstream staging까지 실행

이제 실무형 예시입니다.

조건:

```text
models/marts 아래에 있고
daily 태그가 붙은 모델을 실행한다.
그리고 그 모델들이 의존하는 upstream 모델도 같이 실행한다.
단, backfill 모델은 제외한다.
```

selectors.yml:

```yaml
selectors:
  - name: daily_marts_with_parents
    description: "daily marts 모델과 필요한 upstream 모델 실행, backfill 제외"
    definition:
      intersection:
        - method: path
          value: models/marts
        - method: tag
          value: daily
          parents: true
      exclude:
        - method: tag
          value: backfill
```

그런데 이 방식은 약간 주의가 필요합니다.

위 selector는 `tag: daily` 조건에 `parents: true`가 붙어 있습니다.
즉, **daily 태그가 붙은 모델의 부모까지 확장**하는 의미입니다.

조금 더 의도를 분명히 하려면 이렇게도 쓸 수 있습니다.

```yaml
selectors:
  - name: daily_marts_with_parents
    description: "marts daily 모델과 upstream 모델 실행, backfill 제외"
    definition:
      intersection:
        - method: path
          value: models/marts
        - method: tag
          value: daily
      parents: true
      exclude:
        - method: tag
          value: backfill
```

다만 `parents: true`를 어디에 붙이느냐에 따라 적용 범위가 달라질 수 있기 때문에, 실무에서는 반드시 먼저 확인해야 합니다.

```bash
dbt ls --selector daily_marts_with_parents
```

그 다음 실행합니다.

```bash
dbt build --selector daily_marts_with_parents
```

---

# 7. 추천하는 안전한 방식

처음에는 Full YAML보다 CLI-style이 더 직관적일 수 있습니다.

예를 들어:

```yaml
selectors:
  - name: daily_marts_with_parents
    description: "daily marts 모델과 upstream 모델 실행"
    definition:
      intersection:
        - "+tag:daily"
        - "path:models/marts"
      exclude:
        - "tag:backfill"
```

하지만 selector가 복잡해지면 저는 아래처럼 **Full YAML 방식**을 추천합니다.

```yaml
selectors:
  - name: daily_marts_with_parents
    description: "daily marts 모델과 upstream 모델 실행, backfill 제외"
    definition:
      intersection:
        - method: tag
          value: daily
          parents: true
        - method: path
          value: models/marts
      exclude:
        - method: tag
          value: backfill
```

이유는 간단합니다.

```text
나중에 Airflow, CI/CD, 운영 배치에서 봤을 때
무엇을 선택하고 무엇을 제외하는지 더 읽기 쉽습니다.
```

---

# 8. 오늘 핵심 정리

```bash
dbt build --select +fct_orders
```

YAML:

```yaml
definition:
  method: fqn
  value: fct_orders
  parents: true
```

---

```bash
dbt build --select fct_orders+
```

YAML:

```yaml
definition:
  method: fqn
  value: fct_orders
  children: true
```

---

```bash
dbt build --select +fct_orders+
```

YAML:

```yaml
definition:
  method: fqn
  value: fct_orders
  parents: true
  children: true
```

---

실무에서는 이 패턴을 많이 씁니다.

```yaml
selectors:
  - name: daily_with_parents
    description: "daily 모델과 필요한 upstream 모델 실행"
    definition:
      method: tag
      value: daily
      parents: true
      exclude:
        - method: tag
          value: backfill
        - method: tag
          value: manual
```

실행:

```bash
dbt ls --selector daily_with_parents
dbt build --selector daily_with_parents
```

다음 단계는 **`@` operator**를 보면 좋습니다.
특히 CI/CD에서 “변경된 모델과 그 downstream을 빌드하되, downstream을 빌드하는 데 필요한 부모까지 보장”할 때 나옵니다.

[1]: https://docs.getdbt.com/reference/node-selection/graph-operators "Graph operators | dbt Developer Hub"
[2]: https://docs.getdbt.com/reference/node-selection/yaml-selectors "YAML Selectors | dbt Developer Hub"

좋습니다. 이번 단계는 **`@` operator**입니다.

`@`는 처음 보면 어렵지만, 한 문장으로 정리하면 이겁니다.

```text
선택한 모델 + 그 downstream 모델들 + downstream 모델을 빌드하는 데 필요한 부모 모델들까지 포함
```

dbt 공식 문서에 따르면 `@`는 `+`와 비슷하지만, 선택된 모델의 **모든 descendants의 ancestors까지 포함**합니다. 특히 CI 환경에서 downstream까지 빌드하고 싶은데, 그 downstream 모델들이 의존하는 부모 모델이 아직 임시 스키마에 없을 때 유용합니다. ([docs.getdbt.com][1])

---

# 1. `+`와 `@` 차이

예를 들어 모델 구조가 이렇게 있다고 해보겠습니다.

```text
stg_orders
   ↓
int_orders
   ↓
fct_orders
   ↓
mart_sales_summary
```

이 경우에는 `fct_orders+`와 `@fct_orders`가 비슷해 보일 수 있습니다.

```bash
dbt build --select fct_orders+
```

선택 결과:

```text
fct_orders
mart_sales_summary
```

```bash
dbt build --select @fct_orders
```

선택 결과:

```text
fct_orders
mart_sales_summary
```

여기까지만 보면 차이가 없어 보입니다.

---

# 2. `@`가 필요한 상황

문제는 downstream 모델이 **다른 부모 모델도 참조할 때** 생깁니다.

```text
stg_orders
   ↓
fct_orders
   ↓
mart_sales_summary
   ↑
dim_customers
```

`mart_sales_summary`가 `fct_orders`뿐만 아니라 `dim_customers`도 참조한다고 해보겠습니다.

```sql
select
    o.order_id,
    c.customer_name
from {{ ref('fct_orders') }} o
join {{ ref('dim_customers') }} c
  on o.customer_id = c.customer_id
```

이때 아래처럼 실행하면:

```bash
dbt build --select fct_orders+
```

선택되는 것은 보통 이렇게 됩니다.

```text
fct_orders
mart_sales_summary
```

그런데 `mart_sales_summary`를 빌드하려면 `dim_customers`도 필요합니다.

만약 현재 개발/CI 스키마에 `dim_customers`가 없다면 `mart_sales_summary` 빌드가 실패할 수 있습니다.

이때 `@`를 씁니다.

```bash
dbt build --select @fct_orders
```

그러면 선택 범위가 이렇게 됩니다.

```text
fct_orders
mart_sales_summary
dim_customers
```

즉, `@fct_orders`는 단순히 자식만 가져오는 게 아니라,

```text
fct_orders의 downstream을 찾고,
그 downstream을 빌드하는 데 필요한 부모 모델까지 가져온다.
```

입니다.

---

# 3. `+`, `@` 비교표

| 명령어            | 의미                                         |
| -------------- | ------------------------------------------ |
| `fct_orders`   | `fct_orders`만 선택                           |
| `+fct_orders`  | `fct_orders`와 upstream 선택                  |
| `fct_orders+`  | `fct_orders`와 downstream 선택                |
| `+fct_orders+` | upstream + 본인 + downstream 선택              |
| `@fct_orders`  | 본인 + downstream + downstream 빌드에 필요한 부모 선택 |

dbt 공식 문서에서도 `@my_model`은 해당 모델, 그 descendants, 그리고 descendants의 ancestors를 선택한다고 설명합니다. 또한 `@`는 모델명 앞에만 붙일 수 있습니다. ([docs.getdbt.com][1])

---

# 4. selectors.yml에서 `@` 쓰기: CLI-style

가장 간단한 방식입니다.

```yaml
selectors:
  - name: fct_orders_buildable_downstream
    description: "fct_orders와 downstream, downstream 빌드에 필요한 부모 모델까지 실행"
    definition: "@fct_orders"
```

실행:

```bash
dbt ls --selector fct_orders_buildable_downstream
dbt build --selector fct_orders_buildable_downstream
```

`selectors.yml`의 CLI-style 정의는 `+`, `@`, `*` 같은 graph operator를 지원합니다. ([docs.getdbt.com][2])

---

# 5. selectors.yml에서 `@` 쓰기: Full YAML 방식

Full YAML 방식에서는 `childrens_parents: true`를 씁니다.

```yaml
selectors:
  - name: fct_orders_buildable_downstream
    description: "fct_orders와 downstream, downstream 빌드에 필요한 부모 모델까지 실행"
    definition:
      method: fqn
      value: fct_orders
      childrens_parents: true
```

이건 CLI로 보면 아래와 같습니다.

```bash
dbt build --select @fct_orders
```

공식 문서의 YAML selector 설명에서도 `childrens_parents: true`가 `@` operator에 대응한다고 나옵니다. ([docs.getdbt.com][2])

---

# 6. 실무형 예시: 변경된 mart 모델 기준으로 안전하게 downstream 빌드

예를 들어 `models/marts` 아래 특정 모델을 기준으로 downstream까지 검증하고 싶다고 해보겠습니다.

```yaml
selectors:
  - name: marts_buildable_downstream
    description: "marts 모델과 downstream, downstream 빌드에 필요한 부모까지 포함"
    definition:
      method: path
      value: models/marts
      childrens_parents: true
```

실행:

```bash
dbt ls --selector marts_buildable_downstream
dbt build --selector marts_buildable_downstream
```

의미:

```text
models/marts 아래 모델을 선택한다.
그 모델들의 downstream을 선택한다.
그 downstream을 빌드하는 데 필요한 다른 부모 모델도 포함한다.
```

---

# 7. `@` + exclude 조합

예를 들어 downstream은 검증하고 싶지만, 무거운 backfill 모델은 제외하고 싶다면 이렇게 쓸 수 있습니다.

```yaml
selectors:
  - name: marts_buildable_downstream_safe
    description: "marts downstream 검증용. backfill, heavy 모델 제외"
    definition:
      method: path
      value: models/marts
      childrens_parents: true
      exclude:
        - method: tag
          value: backfill
        - method: tag
          value: heavy
```

실행:

```bash
dbt ls --selector marts_buildable_downstream_safe
dbt build --selector marts_buildable_downstream_safe
```

다만 이건 조심해야 합니다.

`@`는 downstream을 빌드 가능하게 만들려고 필요한 부모를 포함하는데, `exclude`로 필요한 부모를 빼버리면 다시 빌드 실패가 날 수 있습니다.

예를 들어:

```text
mart_sales_summary가 dim_customers를 필요로 함
그런데 dim_customers에 heavy 태그가 있음
selector에서 tag:heavy를 exclude함
```

그러면 `mart_sales_summary` 빌드가 실패할 수 있습니다.

그래서 `@`와 `exclude`를 같이 쓸 때는 반드시 먼저 확인해야 합니다.

```bash
dbt ls --selector marts_buildable_downstream_safe
```

---

# 8. `@`는 언제 쓰면 좋은가?

저는 이렇게 구분해서 씁니다.

```text
일반 운영 배치:
+ 또는 tag/path selector 중심

개발자가 특정 모델 수정 후 영향 범위 확인:
model_name+

CI/CD에서 변경된 모델의 downstream까지 안전하게 빌드:
@model_name 또는 @state:modified
```

특히 `@`는 이런 상황에서 유용합니다.

```text
내가 fct_orders를 수정했다.
그 영향을 받는 downstream 모델도 테스트하고 싶다.
그런데 downstream 모델이 참조하는 다른 부모 모델이 CI 스키마에 없을 수 있다.
그래서 downstream 빌드에 필요한 부모까지 같이 준비해야 한다.
```

이럴 때:

```bash
dbt build --select @fct_orders
```

를 씁니다.

---

# 9. 오늘 핵심 정리

`+`는 이렇게 생각하면 됩니다.

```text
+fct_orders    → 위쪽 부모까지
fct_orders+    → 아래쪽 자식까지
+fct_orders+   → 위아래 모두
```

`@`는 이렇게 생각하면 됩니다.

```text
@fct_orders
→ fct_orders
→ fct_orders의 downstream
→ 그 downstream을 빌드하는 데 필요한 부모들
```

selectors.yml에서는 이렇게 씁니다.

```yaml
selectors:
  - name: fct_orders_buildable_downstream
    definition: "@fct_orders"
```

또는:

```yaml
selectors:
  - name: fct_orders_buildable_downstream
    definition:
      method: fqn
      value: fct_orders
      childrens_parents: true
```

실무적으로는 `@`를 매일 배치용으로 남발하기보다는, **CI/CD나 영향도 검증용 selector**로 쓰는 편이 더 안전합니다.

[1]: https://docs.getdbt.com/reference/node-selection/graph-operators "Graph operators | dbt Developer Hub"
[2]: https://docs.getdbt.com/reference/node-selection/yaml-selectors "YAML Selectors | dbt Developer Hub"

좋습니다. 이번 단계는 **`state:modified` selector**입니다.

이건 dbt에서 정말 실무적으로 중요합니다. 특히 **CI/CD**, **배포 전 검증**, **변경된 모델만 실행**할 때 많이 씁니다.

---

# 1. `state:modified`가 뭐냐?

한 문장으로 말하면 이겁니다.

```text
이전 manifest.json과 현재 프로젝트를 비교해서,
변경된 dbt 리소스만 선택하는 방법
```

dbt의 state selection은 현재 프로젝트와 이전 실행 결과물의 상태를 비교해서 새로 생기거나 수정된 리소스를 식별하는 기능입니다. 이때 비교 기준으로 보통 이전 실행의 `manifest.json` 같은 dbt artifact를 사용합니다. ([docs.getdbt.com][1])

예를 들어 어제 운영 배포 기준의 dbt 프로젝트 상태가 있고, 오늘 내가 `fct_orders.sql`을 수정했다고 해보겠습니다.

```text
어제 manifest.json
현재 dbt 프로젝트
```

이 둘을 비교해서 dbt가 이렇게 판단합니다.

```text
fct_orders가 수정됨
```

그러면 아래 명령어로 수정된 모델만 실행할 수 있습니다.

```bash
dbt build --select state:modified --state path/to/previous/artifacts
```

---

# 2. 왜 필요한가?

원래 전체 실행은 이렇게 합니다.

```bash
dbt build
```

하지만 모델이 많아지면 전체 실행은 오래 걸립니다.

그래서 CI/CD에서는 보통 이렇게 하고 싶습니다.

```text
전체 모델을 다 돌리지 말고,
이번 PR 또는 이번 배포에서 바뀐 모델만 검증하자.
```

이때 쓰는 게:

```bash
dbt build --select state:modified --state path/to/artifacts
```

입니다.

---

# 3. 가장 기본 CLI 예시

예를 들어 이전 운영 배포 artifact가 아래 경로에 있다고 합시다.

```text
state/prod/manifest.json
```

그러면 이렇게 실행합니다.

```bash
dbt ls --select state:modified --state state/prod
```

먼저 어떤 모델이 선택되는지 확인합니다.

그 다음 실행합니다.

```bash
dbt build --select state:modified --state state/prod
```

주의할 점은 이겁니다.

```text
state:modified만 쓰면 부족하고,
비교할 이전 상태 경로를 --state로 같이 넘겨야 한다.
```

dbt 문서에서도 state와 defer 관련 설정은 CLI flag 또는 환경 변수로 지정할 수 있고, `--state`는 artifact 경로를 지정하는 데 사용됩니다. ([docs.getdbt.com][2])

---

# 4. selectors.yml로 바꾸기

CLI로 매번 이렇게 치는 건 귀찮습니다.

```bash
dbt build --select state:modified --state state/prod
```

그래서 `selectors.yml`에 selector를 만들어둘 수 있습니다.

```yaml
selectors:
  - name: modified
    description: "이전 state와 비교했을 때 수정된 리소스만 선택"
    definition:
      method: state
      value: modified
```

실행은 이렇게 합니다.

```bash
dbt ls --selector modified --state state/prod
```

```bash
dbt build --selector modified --state state/prod
```

중요합니다.

`selectors.yml`에는 **무엇을 선택할지**만 적습니다.

```yaml
method: state
value: modified
```

하지만 **무엇과 비교할지**는 실행 시점에 넘겨야 합니다.

```bash
--state state/prod
```

즉, 둘 다 필요합니다.

```bash
dbt build --selector modified --state state/prod
```

---

# 5. `state:modified+` 패턴

실무에서는 `state:modified`만 쓰기보다 아래를 더 자주 씁니다.

```bash
dbt build --select state:modified+ --state state/prod
```

뜻은 이겁니다.

```text
수정된 모델을 실행하고,
그 모델의 downstream 모델까지 같이 실행한다.
```

왜 downstream까지 실행하냐면, 내가 수정한 모델을 참조하는 하위 모델이 깨질 수도 있기 때문입니다.

예를 들어:

```text
stg_orders
   ↓
fct_orders
   ↓
mart_sales_summary
```

내가 `fct_orders`를 수정했다면 `fct_orders`만 검증하면 부족할 수 있습니다.

```bash
dbt build --select state:modified --state state/prod
```

이건 `fct_orders`만 잡을 수 있습니다.

하지만 아래처럼 하면:

```bash
dbt build --select state:modified+ --state state/prod
```

대략 이런 식으로 잡힙니다.

```text
fct_orders
mart_sales_summary
```

dbt 공식 워크플로우 예시에서도 변경된 모델과 그 하위 모델을 실행하는 패턴으로 `state:modified+`를 사용합니다. ([docs.getdbt.com][3])

---

# 6. selectors.yml에서 `state:modified+`

CLI-style로 쓰면 가장 간단합니다.

```yaml
selectors:
  - name: modified_with_children
    description: "수정된 리소스와 downstream 리소스 선택"
    definition: "state:modified+"
```

실행:

```bash
dbt ls --selector modified_with_children --state state/prod
```

```bash
dbt build --selector modified_with_children --state state/prod
```

Full YAML 방식으로 쓰면 이렇게 됩니다.

```yaml
selectors:
  - name: modified_with_children
    description: "수정된 리소스와 downstream 리소스 선택"
    definition:
      method: state
      value: modified
      children: true
```

실행은 동일합니다.

```bash
dbt build --selector modified_with_children --state state/prod
```

---

# 7. 수정된 모델 + 부모까지 실행

이번에는 반대로 이런 경우입니다.

```text
수정된 모델을 실행하려면,
그 모델이 의존하는 upstream 모델도 같이 빌드하고 싶다.
```

CLI:

```bash
dbt build --select +state:modified --state state/prod
```

selectors.yml:

```yaml
selectors:
  - name: modified_with_parents
    description: "수정된 리소스와 upstream 리소스 선택"
    definition:
      method: state
      value: modified
      parents: true
```

예시:

```text
stg_orders
   ↓
int_orders
   ↓
fct_orders
```

`fct_orders`가 수정되었다면 선택 결과는 대략 이렇게 됩니다.

```text
stg_orders
int_orders
fct_orders
```

---

# 8. 수정된 모델 + 부모 + 자식까지 실행

조금 더 안전하게 검증하고 싶다면:

```bash
dbt build --select +state:modified+ --state state/prod
```

selectors.yml:

```yaml
selectors:
  - name: modified_full_lineage
    description: "수정된 리소스의 upstream과 downstream까지 선택"
    definition:
      method: state
      value: modified
      parents: true
      children: true
```

뜻:

```text
수정된 모델
+ 그 모델을 만들기 위한 부모 모델
+ 그 모델의 영향을 받는 자식 모델
```

입니다.

---

# 9. 실무형 selector 예시

CI/CD에서 쓸 수 있는 예시입니다.

```yaml
selectors:
  - name: ci_modified
    description: "CI에서 변경된 모델과 downstream을 검증하되 무거운 모델은 제외"
    definition:
      method: state
      value: modified
      children: true
      exclude:
        - method: tag
          value: backfill
        - method: tag
          value: heavy
        - method: tag
          value: manual
```

실행:

```bash
dbt ls --selector ci_modified --state state/prod
```

```bash
dbt build --selector ci_modified --state state/prod
```

해석:

```text
이전 운영 state와 비교해서 수정된 모델을 찾는다.
그 수정된 모델의 downstream까지 포함한다.
단, backfill / heavy / manual 태그 모델은 제외한다.
```

---

# 10. 단, `exclude`는 조심해야 함

예를 들어 이런 구조가 있다고 해보겠습니다.

```text
fct_orders
   ↓
mart_sales_summary
   ↑
dim_customers
```

`mart_sales_summary`가 `dim_customers`도 필요로 하는데, `dim_customers`에 `heavy` 태그가 붙어 있다고 합시다.

```yaml
exclude:
  - method: tag
    value: heavy
```

그러면 `dim_customers`가 제외되어서 `mart_sales_summary` 빌드가 실패할 수 있습니다.

그래서 CI selector는 항상 먼저 확인해야 합니다.

```bash
dbt ls --selector ci_modified --state state/prod
```

그리고 나서 실행합니다.

```bash
dbt build --selector ci_modified --state state/prod
```

---

# 11. `state:modified`와 `@` 조합

앞에서 배운 `@`와도 조합할 수 있습니다.

```bash
dbt build --select @state:modified --state state/prod
```

의미:

```text
수정된 모델
+ 그 downstream 모델
+ downstream 모델을 빌드하는 데 필요한 부모 모델
```

selectors.yml:

```yaml
selectors:
  - name: ci_modified_buildable
    description: "수정된 모델의 downstream을 빌드 가능하게 필요한 부모까지 포함"
    definition:
      method: state
      value: modified
      childrens_parents: true
```

실행:

```bash
dbt build --selector ci_modified_buildable --state state/prod
```

이 패턴은 CI/CD에서 꽤 유용합니다.

왜냐하면 단순히 `state:modified+`만 하면 downstream은 잡히지만, 그 downstream이 필요로 하는 다른 부모 모델이 현재 CI 스키마에 없을 수 있기 때문입니다.

이럴 때 `@state:modified`를 쓰면 downstream 빌드에 필요한 부모까지 포함할 수 있습니다. dbt의 `@` operator는 선택된 리소스의 descendants와 그 descendants의 ancestors까지 선택하는 연산자입니다. ([docs.getdbt.com][4])

---

# 12. 오늘 핵심 정리

가장 기본:

```bash
dbt build --select state:modified --state state/prod
```

selector:

```yaml
selectors:
  - name: modified
    definition:
      method: state
      value: modified
```

실행:

```bash
dbt build --selector modified --state state/prod
```

---

CI에서 자주 쓰는 형태:

```yaml
selectors:
  - name: ci_modified
    definition:
      method: state
      value: modified
      children: true
      exclude:
        - method: tag
          value: backfill
        - method: tag
          value: heavy
```

실행:

```bash
dbt build --selector ci_modified --state state/prod
```

---

제일 기억해야 할 문장입니다.

```text
selectors.yml은 선택 조건을 저장한다.
--state는 비교할 이전 manifest 위치를 알려준다.
```

그래서 `state:modified` 계열은 항상 보통 이렇게 같이 갑니다.

```bash
dbt build --selector ci_modified --state state/prod
```

다음은 자연스럽게 **`--defer`**입니다.
`state:modified`와 거의 세트로 쓰이고, CI에서 “바뀐 모델만 임시 스키마에 만들고, 안 바뀐 부모 모델은 운영 스키마 것을 참조하게 하는 방식”입니다.

[1]: https://docs.getdbt.com/reference/node-selection/state-selection?utm_source=chatgpt.com "About state in dbt | dbt Developer Hub"
[2]: https://docs.getdbt.com/reference/node-selection/configure-state?utm_source=chatgpt.com "Configure state selection | dbt Developer Hub"
[3]: https://docs.getdbt.com/best-practices/best-practice-workflows?utm_source=chatgpt.com "Best practices for workflows | dbt Developer Hub"
[4]: https://docs.getdbt.com/reference/node-selection/syntax?utm_source=chatgpt.com "Syntax overview | dbt Developer Hub"

좋습니다. 이번 단계는 **`--defer`**입니다.

`state:modified`와 거의 세트로 이해하면 됩니다.

---

# 1. `--defer`가 뭐냐?

한 문장으로 말하면 이겁니다.

```text
현재 dev/CI 환경에 없는 부모 모델은,
직접 새로 만들지 않고 prod에 이미 만들어진 모델을 참조하게 하는 기능
```

dbt 공식 문서에서도 defer는 sandbox 환경에서 일부 모델만 실행하거나 테스트할 수 있게 해주며, 선택되지 않은 upstream 모델은 다른 환경의 relation으로 참조할 수 있게 해주는 기능이라고 설명합니다. ([docs.getdbt.com][1])

---

# 2. defer가 필요한 상황

예를 들어 모델 흐름이 이렇게 있다고 합시다.

```text
stg_orders
   ↓
int_orders
   ↓
fct_orders
   ↓
mart_sales_summary
```

내가 이번에 `fct_orders`만 수정했습니다.

CI에서 이렇게 실행한다고 해보겠습니다.

```bash
dbt build --select state:modified+ --state state/prod --target ci
```

그러면 선택 대상은 보통 이렇게 됩니다.

```text
fct_orders
mart_sales_summary
```

그런데 `fct_orders`를 만들려면 부모인 `int_orders`가 필요합니다.

문제는 CI 스키마에 `int_orders`가 없을 수 있다는 겁니다.

```text
ci_schema.int_orders 없음
prod_schema.int_orders 있음
```

이때 `--defer`를 쓰면 dbt가 이렇게 판단합니다.

```text
int_orders는 이번 선택 대상이 아니네?
그럼 CI에서 새로 만들지 말고,
prod에 있는 int_orders를 참조하자.
```

그래서 실행 명령어는 이렇게 됩니다.

```bash
dbt build --select state:modified+ --state state/prod --defer --target ci
```

---

# 3. `--defer`가 없을 때 vs 있을 때

## `--defer` 없음

```bash
dbt build --select state:modified+ --state state/prod --target ci
```

`fct_orders` 컴파일 시:

```sql
from ci_schema.int_orders
```

그런데 `ci_schema.int_orders`가 없으면 실패할 수 있습니다.

---

## `--defer` 있음

```bash
dbt build --select state:modified+ --state state/prod --defer --target ci
```

`fct_orders` 컴파일 시:

```sql
from prod_schema.int_orders
```

즉, 선택되지 않은 부모 모델을 prod 쪽 relation으로 넘겨서 참조합니다.

dbt 문서에 따르면 `--defer`는 ref를 해석할 때, 현재 실행에서 선택되지 않은 노드에 대해 state manifest에 있는 다른 환경의 relation으로 resolve할 수 있습니다. ([docs.getdbt.com][1])

---

# 4. 중요한 규칙

`--defer`는 아무 모델이나 무조건 prod로 보내는 기능이 아닙니다.

대략 이렇게 이해하면 됩니다.

```text
이번 실행에서 선택된 모델 → 현재 target에 빌드
이번 실행에서 선택되지 않은 부모 모델 → state manifest 기준 relation으로 참조 가능
```

예를 들어:

```bash
dbt build --select state:modified+ --state state/prod --defer --target ci
```

이면:

```text
수정된 모델과 downstream 모델 → ci 스키마에 새로 빌드
그 모델들이 참조하는 미선택 upstream 모델 → prod 스키마 참조
```

---

# 5. `selectors.yml`과 같이 쓰기

이전에 만든 selector가 있다고 해보겠습니다.

```yaml
selectors:
  - name: ci_modified
    description: "CI에서 변경된 모델과 downstream 검증"
    definition:
      method: state
      value: modified
      children: true
      exclude:
        - method: tag
          value: backfill
        - method: tag
          value: heavy
```

실행은 이렇게 합니다.

```bash
dbt build --selector ci_modified --state state/prod --defer --target ci
```

여기서 역할을 나누면 이렇습니다.

```text
--selector ci_modified
→ 무엇을 실행할지 결정

--state state/prod
→ 무엇과 비교할지 결정

--defer
→ 선택되지 않은 부모 모델을 이전 state 환경 relation으로 참조

--target ci
→ 이번에 빌드할 위치
```

중요한 점은 `--defer` 자체는 `selectors.yml` 안에 넣는 것이 아니라, 실행 명령어의 옵션으로 붙인다는 겁니다.

---

# 6. 실무 예시

상황:

```text
운영 스키마: analytics_prod
CI 스키마: analytics_ci_pr_25
수정된 모델: fct_orders
```

모델 의존성:

```text
stg_orders → int_orders → fct_orders → mart_sales_summary
```

CI에서 원하는 것:

```text
수정된 fct_orders와 그 downstream인 mart_sales_summary만 CI 스키마에 빌드
stg_orders, int_orders는 운영 스키마에 있는 것을 참조
```

명령어:

```bash
dbt build \
  --selector ci_modified \
  --state state/prod \
  --defer \
  --target ci
```

실행 결과 개념:

```text
analytics_ci_pr_25.fct_orders 생성
analytics_ci_pr_25.mart_sales_summary 생성

analytics_prod.stg_orders 참조
analytics_prod.int_orders 참조
```

이렇게 하면 CI에서 전체 staging/intermediate 계층을 다 만들지 않아도 됩니다.

---

# 7. `--defer`와 `+state:modified+` 비교

여기서 헷갈리기 쉽습니다.

## 부모까지 직접 새로 만들고 싶다

```bash
dbt build --select +state:modified+ --state state/prod --target ci
```

뜻:

```text
수정된 모델
+ 부모 모델
+ 자식 모델
전부 CI 스키마에 빌드
```

---

## 부모는 prod 것을 참조하고 싶다

```bash
dbt build --select state:modified+ --state state/prod --defer --target ci
```

뜻:

```text
수정된 모델과 자식 모델만 CI 스키마에 빌드
선택되지 않은 부모 모델은 prod 것을 참조
```

실무 CI에서는 두 번째가 더 자주 유용합니다.

---

# 8. `--defer`와 `@state:modified`

앞에서 배운 `@`와도 비교해야 합니다.

```bash
dbt build --select @state:modified --state state/prod --target ci
```

이건:

```text
수정된 모델
+ downstream 모델
+ downstream 빌드에 필요한 부모 모델
```

을 CI 스키마에 직접 빌드하려는 쪽에 가깝습니다.

반면:

```bash
dbt build --select state:modified+ --state state/prod --defer --target ci
```

이건:

```text
수정된 모델과 downstream만 CI에 빌드
필요한 미선택 부모는 prod 참조
```

입니다.

즉:

```text
@state:modified
→ 필요한 부모까지 선택 대상에 포함

state:modified+ --defer
→ 필요한 부모를 선택하지 않고 prod relation으로 참조
```

---

# 9. `--defer` 쓸 때 주의할 점

## 1) `--state` 경로가 필요함

보통 이렇게 같이 씁니다.

```bash
dbt build --select state:modified+ --state state/prod --defer
```

`--state`는 이전 manifest가 있는 경로입니다. dbt 문서에서도 state와 defer는 CLI flag 또는 환경 변수로 설정할 수 있고, `--defer-state`를 따로 지정하지 않으면 deferral은 `--state`에 제공된 artifacts를 사용한다고 설명합니다. ([docs.getdbt.com][2])

---

## 2) `--state`와 `--target-path`를 같은 경로로 두면 안 좋음

예를 들어 이런 건 피해야 합니다.

```bash
dbt build --select state:modified+ --state target --target-path target
```

이러면 비교 기준으로 쓰는 manifest를 현재 실행 결과가 덮어쓸 수 있습니다.

dbt 문서도 `--defer`, `state:modified` 같은 state-dependent 기능을 쓸 때 `--state`와 `--target-path`를 같은 경로로 설정하지 말라고 주의합니다. ([docs.getdbt.com][3])

권장:

```bash
dbt build \
  --select state:modified+ \
  --state state/prod \
  --defer \
  --target-path target/ci
```

---

## 3) dev에 같은 이름의 relation이 이미 있으면 defer가 기대와 다를 수 있음

`--defer`는 선택되지 않은 노드를 항상 prod로 보내는 단순 기능이 아닙니다. 현재 target에 이미 해당 relation이 있으면 그것을 참조할 수 있습니다.

그래서 CI 환경은 보통 PR별로 깨끗한 schema를 쓰는 게 안전합니다.

```text
analytics_ci_pr_25
analytics_ci_pr_26
```

같은 식으로 분리하는 이유가 여기에 있습니다.

---

# 10. 추천 CI 명령어 패턴

제가 실무형으로 추천하는 기본 패턴은 이겁니다.

```bash
dbt build \
  --selector ci_modified \
  --state state/prod \
  --defer \
  --target ci \
  --target-path target/ci
```

그리고 `selectors.yml`은 이렇게 둡니다.

```yaml
selectors:
  - name: ci_modified
    description: "CI에서 변경된 모델과 downstream을 검증. 무거운 수동 모델 제외"
    definition:
      method: state
      value: modified
      children: true
      exclude:
        - method: tag
          value: backfill
        - method: tag
          value: heavy
        - method: tag
          value: manual
```

---

# 11. 오늘 핵심 정리

`state:modified`는:

```text
이전 manifest와 비교해서 바뀐 모델을 찾는 것
```

`--defer`는:

```text
선택되지 않은 부모 모델을 현재 target에서 새로 만들지 않고,
이전 state 환경의 relation으로 참조하게 하는 것
```

대표 명령어:

```bash
dbt build \
  --select state:modified+ \
  --state state/prod \
  --defer \
  --target ci
```

실무 해석:

```text
바뀐 모델과 downstream은 CI 스키마에 빌드한다.
필요한 upstream 중 선택되지 않은 모델은 prod 스키마 것을 참조한다.
```

`selectors.yml`과 같이 쓰면:

```bash
dbt build \
  --selector ci_modified \
  --state state/prod \
  --defer \
  --target ci
```

이 패턴이 dbt CI/CD에서 가장 많이 쓰이는 구조입니다.

[1]: https://docs.getdbt.com/reference/node-selection/defer?utm_source=chatgpt.com "Defer | dbt Developer Hub"
[2]: https://docs.getdbt.com/reference/node-selection/configure-state?utm_source=chatgpt.com "Configure state selection | dbt Developer Hub"
[3]: https://docs.getdbt.com/reference/node-selection/methods?utm_source=chatgpt.com "Node selector methods | dbt Developer Hub"

아래는 지금까지 설명한 내용을 한 번에 반영한 **실무형 `selectors.yml` 전체 예시**입니다.

파일명은 반드시 프로젝트 최상위의 **`selectors.yml`** 입니다. dbt 공식 문서 기준으로 selector는 top-level `selectors.yml`에 두고, 각 selector는 `name`과 `definition`을 가져야 합니다. 또한 Full YAML 방식에서는 `method`, `value`, `parents`, `children`, `childrens_parents`, `exclude` 등을 사용할 수 있습니다. ([docs.getdbt.com][1])

---

## 1. 예시 프로젝트 구조

```text
my_dbt_project/
├─ dbt_project.yml
├─ selectors.yml
├─ models/
│  ├─ staging/
│  │  ├─ stg_orders.sql
│  │  └─ stg_customers.sql
│  ├─ intermediate/
│  │  └─ int_orders.sql
│  └─ marts/
│     ├─ fct_orders.sql
│     ├─ fct_order_history.sql
│     ├─ dim_customers.sql
│     └─ mart_sales_summary.sql
└─ state/
   └─ prod/
      └─ manifest.json
```

---

## 2. 모델 태그 예시

```sql
-- models/marts/fct_orders.sql

{{ config(
    materialized='table',
    tags=['daily']
) }}

select *
from {{ ref('int_orders') }}
```

```sql
-- models/marts/fct_order_history.sql

{{ config(
    materialized='table',
    tags=['daily', 'backfill', 'heavy']
) }}

select *
from {{ ref('int_orders') }}
```

```sql
-- models/marts/mart_sales_summary.sql

{{ config(
    materialized='table',
    tags=['daily']
) }}

select
    o.order_id,
    c.customer_name
from {{ ref('fct_orders') }} o
join {{ ref('dim_customers') }} c
  on o.customer_id = c.customer_id
```

---

## 3. 전체 `selectors.yml` 예시

```yaml
# selectors.yml

selectors:

  # ------------------------------------------------------------
  # 1. 태그 기준 선택
  # CLI equivalent:
  # dbt build --select tag:daily
  # ------------------------------------------------------------
  - name: daily
    description: "daily 태그가 붙은 모델 실행"
    definition:
      method: tag
      value: daily


  # ------------------------------------------------------------
  # 2. 경로 기준 선택
  # CLI equivalent:
  # dbt build --select path:models/marts
  # ------------------------------------------------------------
  - name: marts
    description: "models/marts 하위 모델 실행"
    definition:
      method: path
      value: models/marts


  # ------------------------------------------------------------
  # 3. intersection: AND 조건
  # models/marts 아래에 있으면서 daily 태그가 붙은 모델
  # CLI equivalent:
  # dbt build --select "path:models/marts,tag:daily"
  # ------------------------------------------------------------
  - name: daily_marts
    description: "marts 폴더 안의 daily 모델 실행"
    definition:
      intersection:
        - method: path
          value: models/marts
        - method: tag
          value: daily


  # ------------------------------------------------------------
  # 4. union: OR 조건
  # daily 또는 hourly 태그가 붙은 모델
  # CLI equivalent:
  # dbt build --select "tag:daily tag:hourly"
  # ------------------------------------------------------------
  - name: daily_or_hourly
    description: "daily 또는 hourly 태그 모델 실행"
    definition:
      union:
        - method: tag
          value: daily
        - method: tag
          value: hourly


  # ------------------------------------------------------------
  # 5. exclude 기본형
  # daily는 실행하되 backfill은 제외
  # CLI equivalent:
  # dbt build --select tag:daily --exclude tag:backfill
  # ------------------------------------------------------------
  - name: daily_without_backfill
    description: "daily 모델 중 backfill 모델 제외"
    definition:
      method: tag
      value: daily
      exclude:
        - method: tag
          value: backfill


  # ------------------------------------------------------------
  # 6. 여러 태그 제외
  # daily는 실행하되 backfill, heavy, manual 제외
  # ------------------------------------------------------------
  - name: daily_normal
    description: "일반 daily 배치용. 무거운 모델과 수동 모델 제외"
    definition:
      method: tag
      value: daily
      exclude:
        - method: tag
          value: backfill
        - method: tag
          value: heavy
        - method: tag
          value: manual


  # ------------------------------------------------------------
  # 7. marts + daily + 제외 조건
  # marts 폴더 안의 daily 모델 중 backfill/heavy/manual 제외
  # ------------------------------------------------------------
  - name: daily_marts_normal
    description: "marts daily 모델 중 backfill, heavy, manual 제외"
    definition:
      intersection:
        - method: path
          value: models/marts
        - method: tag
          value: daily
        - exclude:
            - method: tag
              value: backfill
            - method: tag
              value: heavy
            - method: tag
              value: manual


  # ------------------------------------------------------------
  # 8. parents: upstream까지 포함
  # CLI equivalent:
  # dbt build --select +fct_orders
  # ------------------------------------------------------------
  - name: fct_orders_with_parents
    description: "fct_orders와 upstream 모델까지 실행"
    definition:
      method: fqn
      value: fct_orders
      parents: true


  # ------------------------------------------------------------
  # 9. children: downstream까지 포함
  # CLI equivalent:
  # dbt build --select fct_orders+
  # ------------------------------------------------------------
  - name: fct_orders_with_children
    description: "fct_orders와 downstream 모델까지 실행"
    definition:
      method: fqn
      value: fct_orders
      children: true


  # ------------------------------------------------------------
  # 10. parents + children
  # CLI equivalent:
  # dbt build --select +fct_orders+
  # ------------------------------------------------------------
  - name: fct_orders_full_lineage
    description: "fct_orders의 upstream과 downstream 모두 실행"
    definition:
      method: fqn
      value: fct_orders
      parents: true
      children: true


  # ------------------------------------------------------------
  # 11. parents_depth: upstream 깊이 제한
  # CLI equivalent:
  # dbt build --select 1+fct_orders
  # ------------------------------------------------------------
  - name: fct_orders_one_parent
    description: "fct_orders와 1단계 upstream만 실행"
    definition:
      method: fqn
      value: fct_orders
      parents: true
      parents_depth: 1


  # ------------------------------------------------------------
  # 12. children_depth: downstream 깊이 제한
  # CLI equivalent:
  # dbt build --select fct_orders+1
  # ------------------------------------------------------------
  - name: fct_orders_one_child
    description: "fct_orders와 1단계 downstream만 실행"
    definition:
      method: fqn
      value: fct_orders
      children: true
      children_depth: 1


  # ------------------------------------------------------------
  # 13. daily 모델 + upstream 포함 + 제외 조건
  # CLI equivalent:
  # dbt build --select +tag:daily --exclude tag:backfill tag:heavy tag:manual
  # ------------------------------------------------------------
  - name: daily_with_parents
    description: "daily 모델과 필요한 upstream 실행. backfill/heavy/manual 제외"
    definition:
      method: tag
      value: daily
      parents: true
      exclude:
        - method: tag
          value: backfill
        - method: tag
          value: heavy
        - method: tag
          value: manual


  # ------------------------------------------------------------
  # 14. @ operator: downstream + downstream 빌드에 필요한 부모까지 포함
  # CLI equivalent:
  # dbt build --select @fct_orders
  # ------------------------------------------------------------
  - name: fct_orders_buildable_downstream
    description: "fct_orders와 downstream, downstream 빌드에 필요한 부모까지 실행"
    definition:
      method: fqn
      value: fct_orders
      childrens_parents: true


  # ------------------------------------------------------------
  # 15. marts 기준 @ operator
  # marts 모델의 downstream과 그 downstream 빌드에 필요한 부모까지 포함
  # ------------------------------------------------------------
  - name: marts_buildable_downstream
    description: "marts 모델과 downstream, downstream 빌드에 필요한 부모까지 포함"
    definition:
      method: path
      value: models/marts
      childrens_parents: true


  # ------------------------------------------------------------
  # 16. state:modified
  # 이전 manifest와 비교해서 변경된 모델만 선택
  # 실행 시 --state 필요
  # CLI equivalent:
  # dbt build --select state:modified --state state/prod
  # ------------------------------------------------------------
  - name: modified
    description: "이전 state와 비교했을 때 수정된 리소스만 선택"
    definition:
      method: state
      value: modified


  # ------------------------------------------------------------
  # 17. state:modified+
  # 변경된 모델과 downstream까지 선택
  # CLI equivalent:
  # dbt build --select state:modified+ --state state/prod
  # ------------------------------------------------------------
  - name: modified_with_children
    description: "수정된 리소스와 downstream 리소스 선택"
    definition:
      method: state
      value: modified
      children: true


  # ------------------------------------------------------------
  # 18. +state:modified
  # 변경된 모델과 upstream까지 선택
  # CLI equivalent:
  # dbt build --select +state:modified --state state/prod
  # ------------------------------------------------------------
  - name: modified_with_parents
    description: "수정된 리소스와 upstream 리소스 선택"
    definition:
      method: state
      value: modified
      parents: true


  # ------------------------------------------------------------
  # 19. +state:modified+
  # 변경된 모델의 upstream + 본인 + downstream 모두 선택
  # CLI equivalent:
  # dbt build --select +state:modified+ --state state/prod
  # ------------------------------------------------------------
  - name: modified_full_lineage
    description: "수정된 리소스의 upstream과 downstream까지 선택"
    definition:
      method: state
      value: modified
      parents: true
      children: true


  # ------------------------------------------------------------
  # 20. @state:modified
  # 변경된 모델 + downstream + downstream 빌드에 필요한 부모까지 선택
  # CLI equivalent:
  # dbt build --select @state:modified --state state/prod
  # ------------------------------------------------------------
  - name: modified_buildable_downstream
    description: "수정된 모델의 downstream을 빌드 가능하게 필요한 부모까지 포함"
    definition:
      method: state
      value: modified
      childrens_parents: true


  # ------------------------------------------------------------
  # 21. CI용 selector
  # 변경된 모델과 downstream을 검증하되 무거운 모델 제외
  # 보통 --defer와 함께 사용
  # ------------------------------------------------------------
  - name: ci_modified
    description: "CI에서 변경된 모델과 downstream 검증. 무거운 수동 모델 제외"
    definition:
      method: state
      value: modified
      children: true
      exclude:
        - method: tag
          value: backfill
        - method: tag
          value: heavy
        - method: tag
          value: manual


  # ------------------------------------------------------------
  # 22. CI용 buildable selector
  # 변경된 모델 + downstream + downstream에 필요한 부모 포함
  # defer 없이 CI 스키마에 더 많이 직접 빌드하고 싶을 때 사용
  # ------------------------------------------------------------
  - name: ci_modified_buildable
    description: "CI에서 변경된 모델의 downstream과 필요한 부모까지 직접 빌드"
    definition:
      method: state
      value: modified
      childrens_parents: true
      exclude:
        - method: tag
          value: backfill
        - method: tag
          value: manual


  # ------------------------------------------------------------
  # 23. selector inheritance
  # 기존 selector를 재사용해서 추가 조건 적용
  # ------------------------------------------------------------
  - name: ci_modified_safe
    description: "ci_modified selector를 재사용한 안전 실행용 selector"
    definition:
      intersection:
        - method: selector
          value: ci_modified
        - exclude:
            - method: tag
              value: experimental
```

`+` 연산자는 선택한 리소스의 upstream 또는 downstream까지 확장하고, `@` 연산자는 선택 모델의 downstream과 그 downstream의 ancestors까지 포함합니다. YAML selector에서는 이에 대응해 `parents`, `children`, `parents_depth`, `children_depth`, `childrens_parents`를 사용할 수 있습니다. ([docs.getdbt.com][2])

---

## 4. 실행 명령어 예시

### 4-1. 먼저 선택 대상 확인

```bash
dbt ls --selector daily
```

```bash
dbt ls --selector daily_without_backfill
```

```bash
dbt ls --selector daily_marts_normal
```

```bash
dbt ls --selector fct_orders_full_lineage
```

---

### 4-2. 일반 운영 배치

```bash
dbt build --selector daily_normal
```

뜻:

```text
daily 태그 모델 실행
단, backfill/heavy/manual 태그는 제외
```

---

### 4-3. marts 계층만 실행

```bash
dbt build --selector marts
```

---

### 4-4. marts 중 daily만 실행

```bash
dbt build --selector daily_marts
```

---

### 4-5. marts daily 중 무거운 모델 제외

```bash
dbt build --selector daily_marts_normal
```

---

### 4-6. 특정 모델과 upstream까지 실행

```bash
dbt build --selector fct_orders_with_parents
```

CLI로 쓰면:

```bash
dbt build --select +fct_orders
```

---

### 4-7. 특정 모델과 downstream까지 실행

```bash
dbt build --selector fct_orders_with_children
```

CLI로 쓰면:

```bash
dbt build --select fct_orders+
```

---

### 4-8. 특정 모델의 upstream + downstream 모두 실행

```bash
dbt build --selector fct_orders_full_lineage
```

CLI로 쓰면:

```bash
dbt build --select +fct_orders+
```

---

### 4-9. CI에서 변경된 모델만 확인

```bash
dbt ls \
  --selector modified \
  --state state/prod
```

```bash
dbt build \
  --selector modified \
  --state state/prod
```

`state:modified`는 이전 invocation의 artifact, 보통 `manifest.json`, 을 `--state`로 넘겨 현재 프로젝트와 비교할 때 사용합니다. dbt 문서에서도 state selector와 deferral은 `--state`에 전달한 artifact를 기반으로 동작한다고 설명합니다. ([docs.getdbt.com][3])

---

### 4-10. CI에서 변경된 모델 + downstream 검증

```bash
dbt build \
  --selector modified_with_children \
  --state state/prod
```

---

### 4-11. Slim CI 권장 패턴: 변경 모델 + downstream만 CI에 빌드, 부모는 prod 참조

```bash
dbt build \
  --selector ci_modified \
  --state state/prod \
  --defer \
  --target ci \
  --target-path target/ci
```

해석:

```text
변경된 모델과 downstream은 CI 스키마에 빌드한다.
선택되지 않은 upstream 모델은 state/prod의 manifest 기준 relation을 참조한다.
```

dbt 공식 문서 기준으로 deferral은 `--defer`와 `--state`를 함께 요구하며, 선택되지 않은 upstream 리소스를 state manifest가 가리키는 다른 환경의 relation으로 참조할 수 있게 합니다. ([docs.getdbt.com][4])

---

### 4-12. `@state:modified` 방식으로 필요한 부모까지 직접 빌드

```bash
dbt build \
  --selector ci_modified_buildable \
  --state state/prod \
  --target ci \
  --target-path target/ci
```

해석:

```text
변경된 모델
+ downstream 모델
+ downstream 빌드에 필요한 부모 모델까지
CI 스키마에 직접 빌드
```

---

## 5. 운영/CI에서 추천 조합

제가 정리하면 이렇게 쓰면 됩니다.

```bash
# 운영 daily 배치
dbt build --selector daily_normal
```

```bash
# 운영 marts daily 배치
dbt build --selector daily_marts_normal
```

```bash
# 개발 중 특정 모델 영향도 확인
dbt build --selector fct_orders_full_lineage
```

```bash
# CI: 변경된 모델과 downstream만 검증, 부모는 운영 테이블 참조
dbt build \
  --selector ci_modified \
  --state state/prod \
  --defer \
  --target ci \
  --target-path target/ci
```

```bash
# CI: defer 없이 필요한 부모까지 직접 빌드
dbt build \
  --selector ci_modified_buildable \
  --state state/prod \
  --target ci \
  --target-path target/ci
```

핵심은 이겁니다.

```text
운영 배치        → tag/path + exclude 중심
개발 영향도 확인 → parents/children 중심
CI/CD           → state:modified + children + defer 중심
복잡한 CI        → @state:modified, 즉 childrens_parents 사용
```

[1]: https://docs.getdbt.com/reference/node-selection/yaml-selectors "YAML Selectors | dbt Developer Hub"
[2]: https://docs.getdbt.com/reference/node-selection/graph-operators "Graph operators | dbt Developer Hub"
[3]: https://docs.getdbt.com/reference/node-selection/state-selection "About state in dbt | dbt Developer Hub"
[4]: https://docs.getdbt.com/reference/node-selection/defer "Defer | dbt Developer Hub"
