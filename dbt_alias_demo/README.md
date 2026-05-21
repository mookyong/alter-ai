# dbt Alias Demo

PostgreSQL에서 `alias`로 같은 relation 이름을 만들고, `schema`를 분리해 공존시키는 dbt 데모 프로젝트입니다.

## 구성

- database: `dbt_alias_demo`
- schema: `a`, `b`, `public`
- `models/a/a_customer.sql` -> `a.customer`
- `models/b/b_customer.sql` -> `b.customer`
- `models/combined_customers.sql` -> `public.combined_customers`

## 동작

- `dbt_project.yml`에서 `+materialized: table`로 설정되어 있습니다.
- `a_customer`와 `b_customer`는 파일명 기준으로 `ref()` 합니다.
- 실제 생성되는 relation 이름은 둘 다 `customer`입니다.
- 서로 다른 schema `a`, `b`에 생성되므로 이름이 같아도 충돌하지 않습니다.

## 실행

1. PostgreSQL 실행

```bash
docker compose up -d
```

`init-db` 서비스가 `dbt_alias_demo` database를 자동 생성합니다.

2. dbt 설치

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

3. 연결 확인

```bash
dbt debug --profiles-dir .
```

4. 모델 실행

```bash
dbt run --profiles-dir .
```

5. 검증

```bash
dbt test --profiles-dir .
```

## 확인 포인트

- pgAdmin에서는 `Databases > dbt_alias_demo`를 확인하세요.
- `a.customer`, `b.customer`는 `BASE TABLE`로 생성됩니다.
- `postgres` 데이터베이스에 보이는 예전 객체와 혼동하지 마세요.
