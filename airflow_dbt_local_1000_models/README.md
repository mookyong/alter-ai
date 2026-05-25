# dbt PostgreSQL Project

PostgreSQL을 대상으로 한 dbt 프로젝트 스캐폴드입니다.

## 구조

- `dbt_project.yml`: dbt 프로젝트 설정
- `profiles.yml.example`: 로컬 개발용 PostgreSQL profile 예시
- `models/staging`: 원천 테이블 정리 레이어
- `models/marts`: 분석용 비즈니스 레이어
- `macros`: 공통 매크로

## 시작하기

1. `profiles.yml.example`을 참고해 `~/.dbt/profiles.yml`을 설정합니다.
2. `dbt debug`로 연결을 확인합니다.
3. `dbt build`로 모델을 실행합니다.

## Docker Compose

1. `.env.example`을 `.env`로 복사하고 필요값을 수정합니다.
2. `docker compose up -d postgres airflow-init`
3. `docker compose up -d --build`
4. Airflow UI: `http://localhost:8080`
5. 로그인: `admin` / `admin`
6. 실행은 `CeleryExecutor` + worker 4개 구성입니다.

## Cosmos DAG

- Parent DAG ID: `cosmos_dbt_orchestrator`
- Child DAG IDs: `cosmos_daily_*`, `cosmos_weekly_*`, `cosmos_monthly_*`
- Airflow connection: `postgres_dbt`
- executor: `CeleryExecutor`
- worker: `airflow-worker-1` ~ `airflow-worker-4`
- `dbt test`: 각 child DAG의 `DbtTaskGroup` 내부에 포함
- dbt tags: `daily/weekly/monthly` + `sales/marketing/finance/operations` + `대분류_소분류`
- 각 `schedule/topic/subcategory` 조합은 독립 chain으로 구성됨
- child DAG 내부는 소분류별 `DbtTaskGroup` 10개가 병렬로 실행됨

### 실행 구조

- parent DAG: `cosmos_dbt_orchestrator`
- child DAG: `cosmos_{schedule}_{topic}`
- child DAG 내부: `start -> 10개 DbtTaskGroup -> end`
- 각 `DbtTaskGroup`은 `tag:{schedule},tag:{topic},tag:{subcategory}`를 선택함
- 각 subcategory는 25개 모델의 단일 chain으로 구성되어 병렬 실행됨
