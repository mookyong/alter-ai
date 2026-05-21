from datetime import datetime

from cosmos import DbtDag, ExecutionConfig, ProfileConfig, ProjectConfig
from cosmos.profiles import PostgresUserPasswordProfileMapping


dbt_demo = DbtDag(
    dag_id="dbt_cosmos_demo",
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
    project_config=ProjectConfig("/opt/airflow/dbt"),
    profile_config=ProfileConfig(
        profile_name="dbt_local_demo",
        target_name="dev",
        profile_mapping=PostgresUserPasswordProfileMapping(
            conn_id="dbt_postgres",
            profile_args={"schema": "analytics"},
        ),
    ),
    execution_config=ExecutionConfig(dbt_executable_path="/home/airflow/dbt_venv/bin/dbt"),
)
