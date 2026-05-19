# dbt Core + Postgres 교육용 프로젝트

주제: `주문`

`profiles.yml`은 프로젝트 root에 있지만, dbt는 기본적으로 `~/.dbt/profiles.yml`을 찾습니다. 이 프로젝트에서는 모든 dbt 명령에 `--profiles-dir .`를 붙이세요.

## 준비

```bash
cp .env.example .env
docker compose up -d
pip install -r requirements.txt
```

## 실행

```bash
dbt debug --profiles-dir .
dbt deps --profiles-dir .
dbt seed --profiles-dir .
dbt source freshness --profiles-dir .
dbt snapshot --profiles-dir .
dbt parse --profiles-dir .
dbt compile --profiles-dir . --select fct_orders
dbt ls --profiles-dir . --selector core_models
dbt show --profiles-dir . --select fct_orders --limit 5
dbt run --profiles-dir .
dbt test --profiles-dir .
dbt build --profiles-dir .
dbt docs generate --profiles-dir .
dbt docs serve --profiles-dir .
```

## 실습 리소스

- `seeds/`: 고객, 상품, 주문, 주문상세, retry 제어 데이터
- `models/staging/`: source 기반 정제 모델
- `models/intermediate/`: 조인 모델
- `models/marts/`: fact/dim 모델
- `snapshots/`: 고객 이력 snapshot
- `selectors.yml`: selector 실습
- `packages.yml`: `dbt_utils` 실습

## retry 실습

```bash
dbt run-operation --profiles-dir . demo_retry
```

`dbt retry` 확인용 모델은 아래처럼 실행합니다.

```bash
dbt run --profiles-dir . --select retry_demo --vars '{enable_retry_demo: true}'
```

실패 후 `analytics_raw.retry_controls.should_fail` 값을 `false`로 바꾸고 바로 다음 명령을 실행합니다.

예:

```sql
update analytics_raw.retry_controls
set should_fail = false
where task_name = 'demo_retry';
```

```bash
dbt retry --profiles-dir .
```

## clone 실습

```bash
dbt clone --profiles-dir . --selector marts_only --state target
```
