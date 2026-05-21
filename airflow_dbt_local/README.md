# Airflow + dbt Local Demo

Local development stack for running dbt through Airflow 3.0 with Cosmos.

## Layout

- `airflow/` Airflow image, DAGs, and dependencies
- `dbt/` dbt project
- `postgres/` Postgres init scripts
- `docker-compose.yml` local services

## Services

- `postgres` metadata DB for Airflow and warehouse DB for dbt
- `airflow-init` initializes Airflow metadata and creates the admin user
- `airflow-apiserver`, `airflow-scheduler`, `airflow-dag-processor`, `airflow-triggerer`

## Airflow Settings

This stack is configured for Airflow 3.0 local development:

- `LocalExecutor` is enabled for simple local runs
- `AIRFLOW__CORE__AUTH_MANAGER` uses the FAB auth manager
- `AIRFLOW__CORE__EXECUTION_API_SERVER_URL` points scheduler-related components to the API server
- `FERNET_KEY` must be a valid 32-byte url-safe base64 key
- `AIRFLOW_CONN_DBT_POSTGRES` maps the dbt warehouse connection to the local Postgres container
- the Airflow image is custom-built in `airflow/Dockerfile` with Cosmos and dbt dependencies
- dbt is installed in `/home/airflow/dbt_venv` so it does not conflict with Airflow 3 packages
- `astronomer-cosmos` is pinned to `1.10.3` because newer AF3 plugins require Airflow 3.1+
- if you upgrade Airflow to 3.1+, you can revisit the Cosmos pin and use a newer AF3-compatible release

## Issues Encountered

- running `pip install` as `root` inside the Airflow image fails; use the `airflow` user
- installing `dbt` into the same Python environment as Airflow 3 caused dependency conflicts, especially around `protobuf` and `opentelemetry`
- the fix was to install `dbt` in a separate virtual environment inside the Airflow image (`/home/airflow/dbt_venv`)
- `astronomer-cosmos==1.14.1` loaded the Airflow 3 plugin, which requires Airflow 3.1+; pinning to `1.10.3` avoids that issue on Airflow 3.0
- for local development, use a separate `conda` env for `dbt` so it does not affect the Airflow container image
- after a fresh start, run `airflow dags reserialize` if the DAG does not appear in `airflow dags list` yet
- Airflow 3 emits Cosmos dataset URI warnings because URI validation changed from Airflow 2.x; the DAG still runs successfully

## Run

1. Copy env file

```bash
cp .env.example .env
```

2. Start the stack

```bash
docker compose up -d postgres
docker compose up airflow-init
docker compose up -d
```

3. Open Airflow

```text
http://localhost:8080
```

## Re-run

If you want to run this test environment again later:

```bash
docker compose up -d postgres
docker compose up airflow-init
docker compose up -d
```

If you want a clean restart with fresh containers and data:

```bash
docker compose down -v
docker compose up -d postgres
docker compose up airflow-init
docker compose up -d
```

## DAG Check

To confirm Airflow loaded the Cosmos DAG:

```bash
docker compose exec airflow-apiserver airflow dags reserialize
docker compose exec airflow-apiserver airflow dags list
docker compose exec airflow-apiserver airflow tasks list dbt_cosmos_demo
```

Expected tasks:

- `stg_customers_run`
- `customer_summary_run`

To run the DAG once and verify dbt execution:

```bash
docker compose exec airflow-apiserver airflow dags test dbt_cosmos_demo 2024-05-21
```

## dbt commands

Run dbt locally with the same warehouse connection. If you use `conda`, create a separate env for dbt:

```bash
cd dbt
conda env create -f environment.yml
conda activate dbt-local
dbt debug --profiles-dir .
dbt run --profiles-dir .
dbt test --profiles-dir .
```
