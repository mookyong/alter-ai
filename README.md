# Postgres dbt Education Project

dbt Core + Postgres 기반 교육용 프로젝트입니다.

## 구성

- `seeds/`: 고객, 상품, 주문, 주문상세 샘플 데이터
- `models/sources.yml`: raw source + freshness
- `models/staging/`: 원천 정규화
- `models/intermediate/`: 조인 및 집계
- `models/marts/`: 분석용 최종 모델(일부 incremental)
- `snapshots/`: 고객 이력 추적
- `analyses/`: 탐색용 SQL
- `tests/`: singular test 예시
- `macros/`: 데모용 데이터 변경 매크로
- `.github/workflows/dbt-ci.yml`: CI 예시
- `docker-compose.yml`: Postgres 실행

## 사전 준비

1. `pip install dbt-postgres`
2. `profiles.example.yml`을 `~/.dbt/profiles.yml`로 복사
3. `docker compose up -d`

예:

```bash
mkdir -p ~/.dbt
cp profiles.example.yml ~/.dbt/profiles.yml
```

## 프로젝트 요약

- `raw` source는 `seeds/`에 적재된 CSV를 참조합니다.
- `orders` source에 `freshness`가 설정되어 있습니다.
- `customers_snapshot`은 고객 변경 이력을 SCD2 방식으로 추적합니다.
- `mart_sales_summary`는 incremental 모델입니다.

## 실행 순서

```bash
dbt debug
dbt seed
dbt source freshness
dbt snapshot
dbt run
dbt test
```

## 운영 실행 예시

```bash
dbt run --select staging
dbt run --select marts
dbt run --select +marts
```

주의:
- `dbt run --select +marts`는 upstream까지 포함합니다.
- `dbt run --selector marts`는 `selectors.yml`에 정의된 selector 이름을 사용할 때만 동작합니다.

## CI 예시

변경된 모델만 검증할 때:

```bash
dbt build --selector ci_modified --state state/prod --defer --target ci
```

필요한 부모까지 포함해서 빌드할 때:

```bash
dbt build --selector ci_modified_buildable --state state/prod --defer --target ci
```

참고:
- `--state state/prod`는 이전 prod artifact(`manifest.json`)가 있는 경로를 뜻합니다.
- 실제 CI에서는 배포된 prod artifact를 내려받아 해당 경로에 복원해 두는 구성이 필요합니다.
- CI 워크플로우 예시는 `.github/workflows/dbt-ci.yml`에 있습니다.

## 확장 항목

- `source/freshness`: `orders` 원천 데이터 신선도 확인
- `snapshot`: `customers_snapshot`으로 고객 변경 이력 추적
- `incremental`: `mart_sales_summary` 증분 적재
- `analysis`: `analyses/`에서 예시 조회 쿼리 관리

## 데모 시나리오

### 1. Snapshot 변경 이력 확인

```bash
dbt run-operation simulate_snapshot_changes
dbt snapshot
```

이후 `analytics_snapshots.customers_snapshot`에서 고객 17, 20의 변경 이력을 확인할 수 있습니다.

### 2. Incremental 재적재 확인

```bash
dbt run-operation simulate_incremental_append
dbt run --select mart_sales_summary
```

이후 `mart_sales_summary`에 2025-02-01, 2025-02-02 집계가 추가됩니다.

### 3. Analysis 조회

```bash
dbt compile
```

생성된 `analyses/` SQL은 운영 쿼리 초안으로 활용할 수 있습니다.
실제 조회는 `dbt compile` 후 생성된 SQL을 데이터베이스에서 실행하면 됩니다.

## 문서 생성

```bash
dbt docs generate
dbt docs serve
```

## 모델 요약

- `stg_customers`, `stg_products`, `stg_orders`, `stg_order_items`
- `int_order_items_enriched`, `int_orders_enriched`, `int_customer_metrics`
- `dim_customers`, `dim_products`, `fct_orders`, `fct_order_items`, `mart_sales_summary`

## 테스트

- source tests: `models/sources.yml`
- singular tests: `tests/`

```bash
dbt test
```
