from datetime import datetime

from airflow import DAG

try:
    from airflow.providers.standard.operators.empty import EmptyOperator
    from airflow.providers.standard.operators.trigger_dagrun import TriggerDagRunOperator
except ImportError:
    from airflow.operators.empty import EmptyOperator
    from airflow.providers.standard.operators.trigger_dagrun import TriggerDagRunOperator


CHILD_DAG_IDS = [
    f"cosmos_{schedule}_{topic}"
    for schedule in ["daily", "weekly", "monthly"]
    for topic in ["sales", "marketing", "finance", "operations"]
]


with DAG(
    dag_id="cosmos_dbt_orchestrator",
    start_date=datetime(2024, 1, 1),
    schedule="@daily",
    catchup=False,
    is_paused_upon_creation=False,
    default_args={"retries": 1},
):
    start = EmptyOperator(task_id="start")
    end = EmptyOperator(task_id="end")

    previous = start
    for child_dag_id in CHILD_DAG_IDS:
        trigger = TriggerDagRunOperator(
            task_id=f"trigger_{child_dag_id}",
            trigger_dag_id=child_dag_id,
            wait_for_completion=False,
            reset_dag_run=False,
            skip_when_already_exists=True,
        )
        previous >> trigger
        previous = trigger

    previous >> end
