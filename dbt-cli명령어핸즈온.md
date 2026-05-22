#--------------------

아래 자료기반으로 postgres 전용 교육용 핸즈용 dbt 프로젝트를 만들어줘. 절차는 다음 같습니다.

프로젝트를 dbt Core + Postgres 기준으로 여부 질문?
예시 도메인은 질문(예:주문/고객/상품)?
일반적인 dbt 프로젝트 형식으로 생성
도메인에 맞춘 샘플 데이터 목록 제시 및 사용자 선택
샘플 데이터 생성(seed용 csv 또는 insert sql)
도메인 및 샘플 데이터에 맞춘 모델 생성
가준 DB 실행용 docker compose 파일 생성
DBT 실행 로컬 실행 방식으로
profiles.yml은 프로젝트 root에 위치
프로젝트 실행 방법 제시
#--------------------



좋아요. 공식 dbt 문서의 **List of commands**에는 `build`, `clean`, `clone`, `docs`, `compile`, `debug`, `deps`, `environment`, `init`, `invocation`, `ls`, `parse`, `retry`, `rpc`, `run`, `run-operation`, `seed`, `show`, `snapshot`, `source`, `test`, `version` 등이 정리되어 있습니다. 이번 답변에서는 먼저 **Part 1: 실무에서 가장 자주 쓰는 실행/검증 명령어**만 정리할게요. ([dbt 공식 문서][1])

# Part 1. 핵심 실행/검증 명령어

| 명령어            | 용도                                    | 언제 쓰는지                                                |
| -------------- | ------------------------------------- | ----------------------------------------------------- |
| `dbt build`    | 모델 실행, 테스트, 스냅샷, 시드 등을 DAG 순서대로 함께 수행 | 운영 배포 전 전체 검증까지 한 번에 돌릴 때                             |
| `dbt run`      | 모델만 실행                                | SQL 모델을 실제 DW에 view/table/incremental 등으로 생성할 때       |
| `dbt test`     | 데이터 테스트와 유닛 테스트 실행                    | not_null, unique, relationships, custom test 등을 검증할 때 |
| `dbt seed`     | CSV seed 파일을 테이블로 적재                  | 코드성 기준 데이터, 매핑 테이블, 소규모 참조 데이터를 적재할 때                 |
| `dbt snapshot` | snapshot 정의를 실행해 변경 이력 저장             | SCD Type 2처럼 원천 데이터의 변경 이력을 남길 때                      |

## 1. `dbt build`

`dbt build`는 `run`, `test`, `snapshot`, `seed`를 통합해서 실행하는 명령어입니다. 선택된 리소스 또는 전체 프로젝트를 DAG 의존성 순서대로 처리합니다. 공식 문서 기준으로 dbt Core v1.11 및 dbt Fusion engine에서는 user-defined functions도 build 대상에 포함됩니다. ([dbt 공식 문서][2])

```bash
dbt build
```

특정 모델만 대상으로 실행할 수도 있습니다.

```bash
dbt build --select stg_orders
```

상위/하위 의존성까지 포함하려면 이렇게 씁니다.

```bash
dbt build --select +fct_orders+
```

실무 감각으로 보면, **운영 배포 전 최종 검증 명령어**에 가깝습니다. `dbt run`만 하면 모델은 만들어지지만 테스트가 같이 보장되지 않습니다. 반면 `dbt build`는 모델 생성과 테스트를 묶어서 보기 때문에 CI/CD나 배포 파이프라인에서 더 자주 쓰기 좋습니다.

## 2. `dbt run`

`dbt run`은 **모델만 실행**합니다. 테스트, 스냅샷, 시드 등은 실행하지 않습니다. 공식 문서에서도 `dbt run`은 models에만 적용되며, 테스트나 스냅샷, 시드는 각각 `dbt test`, `dbt snapshot`, `dbt seed` 또는 `dbt build`를 사용하라고 설명합니다. ([dbt 공식 문서][3])

```bash
dbt run
```

특정 모델만 실행:

```bash
dbt run --select stg_customers
```

특정 폴더 아래 모델만 실행:

```bash
dbt run --select models/marts
```

incremental 모델을 전체 재생성할 때:

```bash
dbt run --full-refresh
```

또는 짧게:

```bash
dbt run -f
```

실무에서는 개발 중에 특정 모델 SQL을 수정한 뒤 빠르게 확인할 때 `dbt run --select 모델명`을 많이 씁니다. 단, 이 명령어만으로는 데이터 품질 테스트가 실행되지 않으므로 최종 확인에는 `dbt test` 또는 `dbt build`를 같이 써야 합니다.

## 3. `dbt test`

`dbt test`는 models, sources, snapshots, seeds에 정의된 data tests와 SQL model에 정의된 unit tests를 실행합니다. 공식 문서 기준으로 이미 해당 리소스들이 적절한 명령어로 생성되어 있어야 테스트를 실행할 수 있습니다. ([dbt 공식 문서][4])

```bash
dbt test
```

특정 모델의 테스트만 실행:

```bash
dbt test --select stg_orders
```

data test만 실행:

```bash
dbt test --select test_type:data
```

unit test만 실행:

```bash
dbt test --select test_type:unit
```

generic test만 실행:

```bash
dbt test --select test_type:generic
```

singular test만 실행:

```bash
dbt test --select test_type:singular
```

실무에서는 `dbt run` 후에 바로 `dbt test`를 붙여서 씁니다.

```bash
dbt run --select fct_orders
dbt test --select fct_orders
```

하지만 이 흐름을 한 번에 처리하고 싶으면 보통 이렇게 갑니다.

```bash
dbt build --select fct_orders
```

## 4. `dbt seed`

`dbt seed`는 프로젝트의 seed-paths에 있는 정적 CSV 파일을 데이터베이스 테이블로 적재하는 명령어입니다. 공식 문서에서는 국가 코드, 지역 매핑, 비즈니스 정의 카테고리처럼 작은 버전 관리용 참조 데이터에 seed를 사용할 수 있다고 설명합니다. ([dbt 공식 문서][1])

```bash
dbt seed
```

특정 seed만 적재:

```bash
dbt seed --select country_codes
```

seed를 전체 재적재하고 싶을 때:

```bash
dbt seed --full-refresh
```

실무 예시는 이런 경우입니다.

```text
seeds/
  country_codes.csv
  product_category_mapping.csv
  status_code_mapping.csv
```

이런 CSV를 Git으로 관리하고, DW에는 테이블로 올려서 모델에서 join할 수 있게 만드는 방식입니다.

## 5. `dbt snapshot`

`dbt snapshot`은 프로젝트에 정의된 snapshot을 실행합니다. 공식 문서에서는 snapshot이 원천 데이터의 변경을 시간에 따라 기록하며, Type 2 Slowly Changing Dimensions 구현에 사용된다고 설명합니다. ([dbt 공식 문서][1])

```bash
dbt snapshot
```

특정 snapshot만 실행:

```bash
dbt snapshot --select snap_customers
```

예를 들어 고객 정보 테이블에서 주소, 등급, 상태값이 바뀌는 이력을 남기고 싶을 때 snapshot을 씁니다.

```text
raw.customers
→ snapshot 실행
→ snapshot.customers_snapshot
```

결과적으로 `valid_from`, `valid_to` 같은 개념으로 과거 상태를 추적할 수 있습니다.

---

이번 파트만 기준으로 외우면 이렇게 정리하면 됩니다.

```text
dbt run       → 모델만 만든다
dbt test      → 테스트만 돌린다
dbt build     → run + test + seed + snapshot을 통합 실행한다
dbt seed      → CSV 기준 데이터를 테이블로 올린다
dbt snapshot  → 변경 이력을 남긴다
```

다음은 **Part 2: 개발/디버깅 명령어 — `debug`, `compile`, `parse`, `ls`, `show`, `docs`**로 이어가면 됩니다.

[1]: https://docs.getdbt.com/category/list-of-commands "List of commands | dbt Developer Hub"
[2]: https://docs.getdbt.com/reference/commands/build "About dbt build command | dbt Developer Hub"
[3]: https://docs.getdbt.com/reference/commands/run "About dbt run command | dbt Developer Hub"
[4]: https://docs.getdbt.com/reference/commands/test "About dbt test command | dbt Developer Hub"


# Part 2. 개발/디버깅용 명령어

이번 편은 **모델을 실제로 만들기 전**, SQL/Jinja/프로젝트 구조/연결 상태를 확인할 때 쓰는 명령어입니다.

| 명령어                   | 용도                        | 실무에서 쓰는 상황                                   |
| --------------------- | ------------------------- | -------------------------------------------- |
| `dbt debug`           | dbt 환경, profile, DB 연결 확인 | 처음 세팅했는데 연결이 되는지 확인할 때                       |
| `dbt compile`         | Jinja가 반영된 최종 SQL 확인      | `ref`, `source`, macro가 실제 SQL로 어떻게 바뀌는지 볼 때 |
| `dbt parse`           | 프로젝트 문법/구조 검증             | YAML, Jinja 오류를 빠르게 잡고 싶을 때                  |
| `dbt ls` / `dbt list` | 프로젝트 리소스 목록 조회            | 어떤 모델/테스트/source가 선택되는지 확인할 때                |
| `dbt show`            | 단일 모델/쿼리 결과 미리보기          | 모델을 materialize하지 않고 결과 샘플만 보고 싶을 때          |
| `dbt docs`            | 문서 사이트 생성/서빙              | 모델 lineage, 컬럼 설명, 테스트 정보를 문서화할 때            |

---

## 1. `dbt debug`

`dbt debug`는 dbt 프로젝트 설정, `profiles.yml`, 데이터베이스 연결, dbt 버전, Python 환경, adapter 정보 등을 점검하는 명령어입니다. 공식 문서에서도 데이터베이스 연결과 시스템 설정을 테스트하는 유틸리티 명령어로 설명합니다. ([dbt 공식 문서][1])

```bash
dbt debug
```

연결만 확인하고 싶을 때는 보통 이렇게 씁니다.

```bash
dbt debug --connection
```

실무에서는 dbt 프로젝트를 처음 받았을 때 제일 먼저 실행해보면 좋습니다.

```text
1. dbt debug
2. 연결 실패 시 profiles.yml 확인
3. warehouse/schema/user/password/role/host 확인
4. 다시 dbt debug
```

특히 Redshift, Snowflake, BigQuery 같은 DW 연결 문제는 `dbt run`부터 돌리기보다 `dbt debug`로 먼저 확인하는 게 좋습니다.

---

## 2. `dbt compile`

`dbt compile`은 모델, 테스트, analysis, snapshot 등에 들어 있는 dbt SQL/Jinja를 실제 실행 가능한 SQL로 변환합니다. 컴파일된 SQL은 기본적으로 `target/` 디렉터리에 생성되며, 복잡한 Jinja나 macro 결과를 눈으로 확인할 때 유용합니다. ([dbt 공식 문서][2])

```bash
dbt compile
```

특정 모델만 컴파일:

```bash
dbt compile --select stg_orders
```

인라인 SQL도 컴파일할 수 있습니다.

```bash
dbt compile --inline "select * from {{ ref('stg_orders') }}"
```

예를 들어 모델 SQL이 이렇게 되어 있다면,

```sql
select *
from {{ ref('stg_orders') }}
```

컴파일 후에는 실제 DW 테이블/뷰명을 포함한 SQL로 바뀝니다.

```sql
select *
from "dev"."analytics"."stg_orders"
```

중요한 점은 `dbt compile`이 `dbt run`의 필수 사전 단계는 아니라는 점입니다. `dbt run`, `dbt build` 같은 명령어는 내부적으로 필요한 컴파일을 처리합니다. 공식 문서도 `dbt compile`을 먼저 실행할 필요는 없다고 설명합니다. ([dbt 공식 문서][2])

실무 감각으로 보면 `dbt compile`은 **“이 SQL이 최종적으로 어떻게 변환되는지 확인하는 명령어”**입니다.

---

## 3. `dbt parse`

`dbt parse`는 프로젝트 안의 YAML, Jinja, dbt 리소스 정의를 읽고 검증합니다. 공식 문서 기준으로 Jinja 또는 YAML 문법 오류가 있으면 실패하며, warehouse에는 연결하지 않습니다. ([dbt 공식 문서][3])

```bash
dbt parse
```

전체 프로젝트를 처음부터 다시 파싱하고 싶으면 다음처럼 씁니다.

```bash
dbt parse --no-partial-parse
```

`compile`과 헷갈리면 이렇게 구분하면 됩니다.

```text
dbt parse   → 프로젝트 구조와 문법을 읽고 검증
dbt compile → 실제 실행 가능한 SQL로 변환
```

예를 들어 `schema.yml`에서 들여쓰기나 key 이름을 잘못 쓰면 `dbt parse` 단계에서 잡힐 수 있습니다.

```yaml
models:
  - name: stg_orders
    columns:
      - name: order_id
        tests:
          - not_null
```

실무에서는 CI에서 가볍게 프로젝트가 깨졌는지 확인할 때 유용합니다.

---

## 4. `dbt ls` / `dbt list`

`dbt ls`는 dbt 프로젝트 안의 리소스 목록을 출력합니다. `dbt list`는 `dbt ls`의 alias입니다. 공식 문서 기준으로 selector 문법을 받아서 모델, source, seed, snapshot, test 등을 필터링할 수 있고, 데이터베이스에 직접 연결해서 쿼리를 실행하지는 않습니다. ([dbt 공식 문서][4])

```bash
dbt ls
```

모델만 보기:

```bash
dbt ls --resource-type model
```

특정 태그가 붙은 리소스 보기:

```bash
dbt ls --select tag:nightly
```

특정 폴더 아래 모델 보기:

```bash
dbt ls --select models/marts
```

실무에서 정말 유용한 패턴은 이겁니다.

```bash
dbt ls --select +fct_orders+
```

이렇게 하면 `fct_orders`를 기준으로 어떤 상위/하위 리소스가 선택되는지 먼저 확인할 수 있습니다. 바로 `dbt build --select +fct_orders+`를 실행하기 전에, 실제 실행 대상이 맞는지 검증하는 용도입니다.

JSON 형태로 출력할 수도 있습니다.

```bash
dbt ls --select stg_orders --output json
```

자동화 스크립트나 CI/CD에서 리소스 목록을 가공해야 할 때 유용합니다.

---

## 5. `dbt show`

`dbt show`는 단일 모델, 테스트, analysis 또는 인라인 dbt SQL을 컴파일하고, 그 쿼리를 warehouse에서 실행한 뒤 결과 일부를 터미널에 보여줍니다. 공식 문서 기준으로 기본적으로 첫 5개 row를 보여주며, `--limit`으로 조회 row 수를 조정할 수 있습니다. ([dbt 공식 문서][5])

```bash
dbt show --select stg_orders
```

조회 row 수 지정:

```bash
dbt show --select stg_orders --limit 10
```

인라인 쿼리 실행:

```bash
dbt show --inline "select * from {{ ref('stg_orders') }} limit 5"
```

`dbt show`는 모델을 테이블이나 뷰로 생성하는 명령어가 아닙니다. 결과를 미리 확인하는 용도입니다.

```text
dbt run   → 모델을 실제 DW에 생성
dbt show  → 모델 SQL 결과를 미리보기
```

개발 중에는 `dbt run`을 계속 돌리기보다, 먼저 `dbt show`로 결과 모양을 빠르게 확인할 수 있습니다.

---

## 6. `dbt docs`

`dbt docs`는 dbt 프로젝트 문서를 생성하고 확인할 때 쓰는 명령어입니다. 공식 문서의 commands 목록에서는 `dbt docs`가 프로젝트 문서를 generate하고 serve하는 명령어로 분류되어 있습니다. ([dbt 공식 문서][6])

문서 생성:

```bash
dbt docs generate
```

로컬에서 문서 사이트 실행:

```bash
dbt docs serve
```

보통 흐름은 이렇습니다.

```bash
dbt docs generate
dbt docs serve
```

그러면 브라우저에서 모델 목록, 컬럼 설명, 테스트 정보, lineage graph를 확인할 수 있습니다.

실무에서는 `schema.yml`에 컬럼 설명을 잘 써두면 문서 품질이 좋아집니다.

```yaml
models:
  - name: fct_orders
    description: "주문 단위 매출 fact 테이블"
    columns:
      - name: order_id
        description: "주문 식별자"
        tests:
          - not_null
          - unique
```

즉, `dbt docs`는 단순한 문서 생성이 아니라 **데이터 모델 카탈로그 + lineage 확인 도구**에 가깝습니다.

---

# Part 2 요약

```text
dbt debug    → dbt 환경과 DB 연결 확인
dbt compile  → Jinja/ref/source/macro가 반영된 최종 SQL 확인
dbt parse    → YAML/Jinja/프로젝트 구조 검증
dbt ls       → 선택되는 dbt 리소스 목록 확인
dbt show     → 단일 모델 또는 쿼리 결과 미리보기
dbt docs     → dbt 문서 생성 및 로컬 확인
```

실무 흐름으로 묶으면 이렇게 외우면 됩니다.

```bash
dbt debug
dbt parse
dbt ls --select +fct_orders+
dbt compile --select fct_orders
dbt show --select fct_orders --limit 10
dbt build --select fct_orders
dbt docs generate
dbt docs serve
```

다음은 **Part 3: 프로젝트 관리/패키지/초기화 명령어 — `init`, `deps`, `clean`, `version`, `environment`, `invocation`**로 이어가면 됩니다.

[1]: https://docs.getdbt.com/reference/commands/debug "About dbt debug command | dbt Developer Hub"
[2]: https://docs.getdbt.com/reference/commands/compile "About dbt compile command | dbt Developer Hub"
[3]: https://docs.getdbt.com/reference/commands/parse "About dbt parse command | dbt Developer Hub"
[4]: https://docs.getdbt.com/reference/commands/list "About dbt ls (list) command | dbt Developer Hub"
[5]: https://docs.getdbt.com/reference/commands/show "About dbt show command | dbt Developer Hub"
[6]: https://docs.getdbt.com/reference/commands/cmd-docs?utm_source=chatgpt.com "About dbt docs commands | dbt Developer Hub"

# Part 3. 프로젝트 관리/패키지/CLI 관리 명령어

이번 파트는 모델을 직접 실행하는 명령어라기보다는, **dbt 프로젝트를 만들고, 의존 패키지를 설치하고, 작업 환경을 정리/확인하는 명령어**입니다.

| 명령어                           | 용도                                            | 자주 쓰는 상황                    |
| ----------------------------- | --------------------------------------------- | --------------------------- |
| `dbt init`                    | 새 dbt 프로젝트 생성 또는 기존 프로젝트의 profile 설정          | 처음 프로젝트 만들 때                |
| `dbt deps`                    | `packages.yml` / `dependencies.yml` 기반 패키지 설치 | 외부 dbt package 설치할 때        |
| `dbt clean`                   | `target/`, `dbt_packages/` 등 생성 파일 정리         | 캐시/빌드 결과를 지우고 새로 시작할 때      |
| `dbt --version`               | dbt Core/CLI 및 adapter 버전 확인                  | 버전 충돌, adapter 확인할 때        |
| `dbt environment` / `dbt env` | dbt CLI 환경 정보 확인                              | dbt Cloud CLI 환경 확인할 때      |
| `dbt invocation`              | 실행 중인 dbt CLI invocation 확인/관리                | long-running session 디버깅할 때 |

---

## 1. `dbt init`

`dbt init`은 새 dbt 프로젝트를 생성할 때 사용하는 명령어입니다. 기존 프로젝트를 clone/download한 경우에도 `profiles.yml` 연결 정보를 빠르게 설정하는 데 사용할 수 있습니다. 공식 문서에 따르면 `dbt init`은 연결 정보를 물어보고, 프로젝트의 `profile` 이름에 맞춰 로컬 `profiles.yml`에 profile을 추가하거나 파일이 없으면 생성합니다. ([dbt 공식 문서][1])

```bash
dbt init
```

프로젝트 이름을 바로 지정할 수도 있습니다.

```bash
dbt init my_dbt_project
```

실행하면 보통 다음과 같은 구성을 만들게 됩니다.

```text
my_dbt_project/
  dbt_project.yml
  models/
  macros/
  seeds/
  snapshots/
  tests/
```

실무적으로는 처음 프로젝트 만들 때만 자주 쓰고, 이후에는 `dbt run`, `dbt build`, `dbt test`를 훨씬 많이 씁니다.

---

## 2. `dbt deps`

`dbt deps`는 `packages.yml` 또는 `dependencies.yml`에 정의된 dbt package 의존성을 설치하는 명령어입니다. 공식 문서에 따르면 dbt는 설치된 정확한 패키지 버전과 commit SHA 등을 `package-lock.yml`에 기록해서 환경 간 반복 가능한 설치를 돕습니다. ([dbt 공식 문서][2])

```bash
dbt deps
```

예를 들어 `packages.yml`에 다음처럼 패키지를 정의했다고 하면,

```yaml
packages:
  - package: dbt-labs/dbt_utils
    version: 1.3.0
```

아래 명령어로 패키지를 설치합니다.

```bash
dbt deps
```

설치 후에는 보통 이런 디렉터리가 생깁니다.

```text
dbt_packages/
  dbt_utils/
```

실무에서는 `dbt_utils` 같은 공통 macro 패키지를 사용할 때 거의 필수로 보게 됩니다.

```sql
select
    {{ dbt_utils.generate_surrogate_key(['customer_id', 'order_id']) }} as order_key
from {{ ref('stg_orders') }}
```

즉, `dbt deps`는 Python의 `pip install -r requirements.txt`와 비슷하게 이해하면 됩니다. 단, Python package가 아니라 **dbt package**를 설치하는 명령어입니다.

---

## 3. `dbt clean`

`dbt clean`은 `dbt_project.yml`의 `clean-targets`에 지정된 경로를 삭제하는 명령어입니다. 공식 문서에서는 다른 dbt 명령어 실행 중 생성된 불필요한 파일이나 디렉터리를 제거해 프로젝트를 깨끗한 상태로 만드는 유틸리티 명령어로 설명합니다. ([dbt 공식 문서][3])

```bash
dbt clean
```

보통 `dbt_project.yml`에는 이런 설정이 있습니다.

```yaml
clean-targets:
  - "target"
  - "dbt_packages"
```

그러면 `dbt clean` 실행 시 다음과 같은 생성물이 정리됩니다.

```text
target/
dbt_packages/
```

특정 옵션도 있습니다.

```bash
dbt clean --clean-project-files-only
```

기본적으로 dbt는 프로젝트 디렉터리 안의 `clean-targets` 경로를 삭제합니다. 프로젝트 밖의 경로를 지우려 하면 에러가 날 수 있으며, 프로젝트 외부 경로까지 삭제하려면 `--no-clean-project-files-only` 옵션을 사용할 수 있습니다. ([dbt 공식 문서][3])

```bash
dbt clean --no-clean-project-files-only
```

실무에서는 다음 상황에서 자주 씁니다.

```text
1. target/ 결과물이 꼬였을 때
2. dbt_packages/를 새로 받고 싶을 때
3. partial parsing 캐시 때문에 이상한 오류가 나는 것 같을 때
4. CI/CD에서 깨끗한 상태로 다시 실행하고 싶을 때
```

자주 쓰는 조합은 이겁니다.

```bash
dbt clean
dbt deps
dbt build
```

---

## 4. `dbt --version`

`dbt --version`은 현재 설치된 dbt 버전을 확인하는 명령어입니다. 공식 문서에 따르면 dbt Core에서는 설치된 dbt Core 버전과 adapter 버전을 보여주고, dbt CLI에서는 설치된 dbt CLI 버전과 dbt runtime 관련 버전 정보를 보여줍니다. ([dbt 공식 문서][4])

```bash
dbt --version
```

예상 출력 형태는 대략 이런 느낌입니다.

```text
Core:
  - installed: 1.x.x
  - latest:    1.x.x

Plugins:
  - redshift: 1.x.x
  - snowflake: 1.x.x
```

실무에서는 오류가 났을 때 먼저 확인해야 합니다.

```bash
dbt --version
```

왜냐하면 dbt는 버전에 따라 설정 방식, flag 이름, 지원 기능이 달라질 수 있기 때문입니다. 예를 들어 `dbt-core`, `dbt-redshift`, `dbt-snowflake` 같은 adapter 버전이 맞지 않으면 예상하지 못한 오류가 날 수 있습니다.

---

## 5. `dbt environment` / `dbt env`

`dbt environment`는 dbt CLI에서 로컬 설정 정보나 dbt 환경 정보를 확인하는 명령어입니다. 공식 문서에 따르면 계정 ID, 활성 project ID, deployment environment, environment ID, environment name, connection type 등의 정보를 확인하는 데 쓰이며, `dbt env`라는 shorthand도 제공합니다. ([dbt 공식 문서][5])

```bash
dbt environment
```

또는 짧게:

```bash
dbt env
```

하위 명령어 형태로 사용합니다.

```bash
dbt environment [command]
```

```bash
dbt env [command]
```

이 명령어는 일반적인 로컬 dbt Core 프로젝트보다 **dbt Cloud CLI / dbt Platform 환경**에서 더 의미가 큽니다. 로컬에서 `dbt Core + profiles.yml`만 쓰는 경우라면 보통 `dbt debug`, `dbt --version`, `dbt deps`를 더 자주 보게 됩니다.

---

## 6. `dbt invocation`

`dbt invocation`은 dbt CLI에서 실행 중인 active invocation을 확인하고 long-running session을 디버깅할 때 사용하는 명령어입니다. 공식 문서에서는 long-running session이 활성화되어 있을 때 active invocation 목록을 확인하는 데 사용할 수 있다고 설명합니다. ([dbt 공식 문서][6])

```bash
dbt invocation list
```

이 명령어도 일반적인 dbt Core 로컬 개발보다는 **dbt CLI에서 세션이 길게 잡혀 있거나 session occupied 같은 문제가 생겼을 때** 의미가 큽니다.

혼동하지 말아야 할 개념이 하나 있습니다.

```text
dbt invocation 명령어
→ 실행 중인 CLI invocation/session을 다루는 명령어

invocation_id
→ dbt 명령 실행마다 생성되는 UUID
```

공식 문서에 따르면 `invocation_id`는 dbt 명령마다 생성되는 UUID이며, dbt 실행 메타데이터를 감사하거나 분석할 때 유용합니다. ([dbt 공식 문서][7])

예를 들어 dbt 실행 로그 테이블을 만들 때 이런 값이 유용할 수 있습니다.

```sql
select
    '{{ invocation_id }}' as dbt_invocation_id,
    current_timestamp as logged_at
```

---

# Part 3 요약

```text
dbt init        → 새 프로젝트 생성 / profile 설정
dbt deps        → dbt package 설치
dbt clean       → target, dbt_packages 등 생성 파일 정리
dbt --version   → dbt 및 adapter 버전 확인
dbt environment → dbt CLI 환경 정보 확인
dbt invocation  → 실행 중인 dbt CLI invocation 확인/관리
```

실무에서 많이 쓰는 흐름은 이겁니다.

```bash
dbt init my_project
cd my_project

dbt debug
dbt deps
dbt run
dbt test
```

프로젝트가 꼬였거나 패키지를 새로 받고 싶으면:

```bash
dbt clean
dbt deps
dbt build
```

이번 파트에서 특히 자주 외우면 되는 건 세 개입니다.

```text
dbt init  → 처음 만들 때
dbt deps  → 패키지 받을 때
dbt clean → 생성물 지우고 새로 시작할 때
```

다음은 **Part 4: 조회/소스/운영 보조 명령어 — `source`, `run-operation`, `clone`, `retry`, `rpc`**로 이어가면 됩니다.

[1]: https://docs.getdbt.com/reference/commands/init?utm_source=chatgpt.com "About dbt init command | dbt Developer Hub"
[2]: https://docs.getdbt.com/reference/commands/deps?utm_source=chatgpt.com "About dbt deps command | dbt Developer Hub"
[3]: https://docs.getdbt.com/reference/commands/clean?utm_source=chatgpt.com "About dbt clean command | dbt Developer Hub"
[4]: https://docs.getdbt.com/reference/commands/version?utm_source=chatgpt.com "About dbt --version | dbt Developer Hub"
[5]: https://docs.getdbt.com/reference/commands/dbt-environment?utm_source=chatgpt.com "About dbt environment command | dbt Developer Hub"
[6]: https://docs.getdbt.com/reference/commands/invocation?utm_source=chatgpt.com "About dbt invocation command | dbt Developer Hub"
[7]: https://docs.getdbt.com/reference/dbt-jinja-functions/invocation_id?utm_source=chatgpt.com "About invocation_id | dbt Developer Hub"


# Part 4. 소스/운영 보조/고급 명령어

이번 파트는 **실무에서 자주 쓰이지만, 앞의 `run/build/test/debug`보다 조금 더 운영·고급 기능에 가까운 명령어**입니다.

| 명령어                    | 용도                         | 실무 사용 상황                    |
| ---------------------- | -------------------------- | --------------------------- |
| `dbt source freshness` | 원천 테이블 최신성 확인              | 원천 데이터가 제때 들어왔는지 SLA 체크     |
| `dbt run-operation`    | macro 실행 / SQL 작업 실행       | 권한 부여, 로그 적재, DDL 실행, 관리 작업 |
| `dbt clone`            | 기존 환경의 객체를 다른 schema로 복제   | prod 데이터를 dev/CI 환경에 복제     |
| `dbt retry`            | 실패한 이전 dbt 실행을 실패 지점부터 재시도 | 긴 배치가 중간에 실패했을 때            |
| `dbt rpc`              | RPC 서버 기반 dbt 실행           | 현재는 deprecated라 신규 사용 비추천   |

---

## 1. `dbt source freshness`

`dbt source freshness`는 dbt에 정의된 source table의 최신성을 확인하는 명령어입니다. 공식 문서 기준으로 `dbt source` 명령어에는 `dbt source freshness`라는 하위 명령어가 있고, source에 설정한 freshness 기준에 따라 stale 상태면 warning 또는 error를 발생시킬 수 있습니다. ([dbt 공식 문서][1])

```bash
dbt source freshness
```

특정 source만 확인:

```bash
dbt source freshness --select "source:jaffle_shop"
```

특정 source table만 확인:

```bash
dbt source freshness --select "source:jaffle_shop.orders"
```

결과 파일 경로를 바꾸고 싶을 때:

```bash
dbt source freshness --output target/source_freshness.json
```

예시 설정은 이런 식입니다.

```yaml
sources:
  - name: jaffle_shop
    database: raw
    config:
      freshness:
        warn_after: {count: 12, period: hour}
        error_after: {count: 24, period: hour}
      loaded_at_field: _etl_loaded_at
    tables:
      - name: orders
        config:
          freshness:
            warn_after: {count: 6, period: hour}
            error_after: {count: 12, period: hour}
```

실무적으로는 이렇게 이해하면 됩니다.

```text
원천 테이블에 데이터가 제때 들어왔나?
→ dbt source freshness
```

예를 들어 Airflow에서 dbt를 돌리기 전에 원천 적재가 늦었는지 확인하고 싶을 때 사용할 수 있습니다.

---

## 2. `dbt run-operation`

`dbt run-operation`은 dbt macro를 직접 실행하거나, 최신 문서 기준으로 SQL/Jinja 문자열을 target database에 직접 실행할 수 있는 명령어입니다. 공식 문서에 따르면 macro 기반 실행은 `dbt run-operation [macro] --args '{args}'` 형태이고, `--sql`은 dbt Core v1.12부터 제공되는 beta 기능입니다. ([dbt 공식 문서][2])

기본 형태:

```bash
dbt run-operation macro_name
```

인자를 넘기는 형태:

```bash
dbt run-operation grant_select --args '{role: reporter}'
```

여러 인자를 넘기는 형태:

```bash
dbt run-operation clean_stale_models --args '{days: 7, dry_run: True}'
```

예를 들어 macro가 이렇게 있다고 하면,

```sql
{% macro grant_select(role) %}
    grant select on all tables in schema {{ target.schema }} to role {{ role }};
{% endmacro %}
```

실행은 이렇게 합니다.

```bash
dbt run-operation grant_select --args '{role: reporter}'
```

공식 문서 기준으로 dbt Core v1.12부터는 `--sql`로 일회성 SQL도 실행할 수 있습니다. 다만 이 기능은 v1.12 beta로 표시되어 있으므로, 현재 실습 환경이 dbt 1.11 계열이면 안 될 가능성이 있습니다. ([dbt 공식 문서][2])

```bash
dbt run-operation --sql "DROP TABLE IF EXISTS my_schema.old_table"
```

실무에서는 이런 작업에 자주 씁니다.

```text
권한 부여
오래된 테이블 정리
관리용 로그 테이블 insert
DDL 실행
운영 전후처리 macro 실행
```

너가 예전에 말했던 **dbt 실행 로그를 admin schema에 남기는 macro** 같은 것도 `dbt run-operation`으로 실행할 수 있습니다.

---

## 3. `dbt clone`

`dbt clone`은 특정 state artifact를 기준으로 선택된 node들을 target schema에 복제하는 명령어입니다. 공식 문서에 따르면 Snowflake, Databricks, BigQuery처럼 zero-copy cloning을 지원하는 플랫폼에서는 table을 clone하고, 그렇지 않은 경우에는 source object를 바라보는 단순 view를 생성합니다. ([dbt 공식 문서][3])

기본 형태:

```bash
dbt clone --state path/to/artifacts
```

특정 모델만 clone:

```bash
dbt clone --select one_specific_model --state path/to/artifacts
```

이미 존재하는 relation까지 다시 만들고 싶을 때:

```bash
dbt clone --state path/to/artifacts --full-refresh
```

병렬성을 높이고 싶을 때:

```bash
dbt clone --state path/to/artifacts --threads 50
```

실무적으로는 이런 상황에서 씁니다.

```text
운영 prod 상태를 dev schema에 복제
CI 환경에서 incremental model을 매번 full-refresh하지 않기
BI 도구에서 변경 영향도 테스트
blue/green 배포
```

예를 들어 운영 테이블이 매우 큰데 개발 환경에서 테스트하려고 매번 `dbt run --full-refresh`를 하면 비용이 큽니다. 이때 warehouse가 zero-copy clone을 지원한다면 `dbt clone`으로 빠르게 dev/CI 환경을 구성할 수 있습니다.

---

## 4. `dbt retry`

`dbt retry`는 마지막 dbt 실행을 실패 지점부터 다시 실행하는 명령어입니다. 공식 문서에 따르면 실패 전까지 실행된 node 기록을 바탕으로 재시도하며, 이전 실행이 성공했다면 `no operation`으로 끝납니다. 또한 `run_results.json`을 참고해서 어디서부터 재시작할지 판단합니다. ([dbt 공식 문서][4])

```bash
dbt retry
```

예를 들어 이런 상황입니다.

```bash
dbt build
```

실행 중에 100개 모델 중 70번째에서 실패했다면, 원인을 수정한 후:

```bash
dbt retry
```

를 실행해 실패 지점부터 이어갈 수 있습니다.

다만 주의할 점이 있습니다. 공식 문서 기준으로 warehouse connection error나 permission error처럼 node가 실행되기 전에 실패한 경우에는 retry할 기록이 없어서 아무것도 실행하지 않을 수 있습니다. 이 경우에는 `run_results.json`을 확인하거나 전체 작업을 다시 실행해야 합니다. ([dbt 공식 문서][4])

지원되는 명령어는 공식 문서 기준으로 다음과 같습니다.

```text
build
compile
clone
docs generate
seed
snapshot
test
run
run-operation
```

실무에서는 긴 배치에서 중간 실패가 발생했을 때 유용합니다.

---

## 5. `dbt rpc`

`dbt rpc`는 RPC 서버를 띄워서 dbt 작업을 외부 요청으로 실행할 수 있게 하는 기능이었습니다. 하지만 공식 문서에서 `dbt-rpc plugin is deprecated`라고 명시하고 있고, dbt-core v1.6부터는 지속적인 호환 지원 대상이 아니라고 설명합니다. ([dbt 공식 문서][5])

예전 사용 방식은 이런 형태였습니다.

```bash
dbt-rpc serve
```

그리고 JSON-RPC 요청으로 `compile`, `run`, `test`, `seed`, `snapshot`, `build` 같은 작업을 호출할 수 있었습니다. ([dbt 공식 문서][5])

하지만 현재 기준으로는 이렇게 정리하는 게 맞습니다.

```text
신규 프로젝트 → dbt rpc 사용 비추천
기존 레거시 프로젝트 → 유지보수 관점에서만 확인
자동화 필요 → dbt CLI, dbt Cloud Job, Airflow, GitHub Actions 등 사용
```

특히 너처럼 Airflow와 dbt를 연결하려는 상황이라면 `dbt rpc`보다는 보통 다음 방식이 더 현실적입니다.

```text
Airflow BashOperator / KubernetesPodOperator / ECSOperator 등
→ dbt build, dbt run, dbt test 실행
```

---

# Part 4 요약

```text
dbt source freshness
→ 원천 데이터가 최신인지 확인

dbt run-operation
→ macro 또는 관리성 SQL 실행

dbt clone
→ prod/dev/CI 환경 간 객체 복제

dbt retry
→ 실패한 dbt 실행을 실패 지점부터 재시도

dbt rpc
→ deprecated, 신규 사용 비추천
```

실무 사용 빈도로 보면 이렇게 외우면 됩니다.

```text
자주 씀:
dbt source freshness
dbt run-operation

상황에 따라 유용:
dbt clone
dbt retry

알아만 두기:
dbt rpc
```

여기까지 하면 공식 List of commands의 주요 명령어는 거의 다 정리했습니다. 다음은 **Part 5: 전체 명령어 실무 치트시트 — 상황별로 어떤 명령어를 쓰는지**로 정리해드리면 됩니다.

[1]: https://docs.getdbt.com/reference/commands/source "About dbt source command | dbt Developer Hub"
[2]: https://docs.getdbt.com/reference/commands/run-operation "About dbt run-operation command | dbt Developer Hub"
[3]: https://docs.getdbt.com/reference/commands/clone "About dbt clone command | dbt Developer Hub"
[4]: https://docs.getdbt.com/reference/commands/retry "About dbt retry command | dbt Developer Hub"
[5]: https://docs.getdbt.com/reference/commands/rpc "About dbt rpc command | dbt Developer Hub"
