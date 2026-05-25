from datetime import datetime

from airflow import DAG

from cosmos import DbtTaskGroup, ExecutionConfig, ProfileConfig, ProjectConfig, RenderConfig, TestBehavior
from cosmos.constants import InvocationMode, LoadMode
from cosmos.profiles import PostgresUserPasswordProfileMapping

try:
    from airflow.providers.standard.operators.empty import EmptyOperator
except ImportError:
    from airflow.operators.empty import EmptyOperator


DBT_PROJECT_PATH = "/opt/project"
DBT_MANIFEST_PATH = "/opt/project/target/manifest.json"

PROFILE_CONFIG = ProfileConfig(
    profile_name="airflow_dbt_local_1000_models",
    target_name="dev",
    profile_mapping=PostgresUserPasswordProfileMapping(
        conn_id="postgres_dbt",
        profile_args={"schema": "dbt_dev"},
    ),
)

TOPIC_SUBCATEGORIES = {
    "sales": [
        "sales_lead_generation",
        "sales_lead_qualification",
        "sales_opportunity_management",
        "sales_pipeline_analytics",
        "sales_quote_and_pricing",
        "sales_order_processing",
        "sales_revenue_forecasting",
        "sales_account_management",
        "sales_renewal_and_retention",
        "sales_sales_compensation",
    ],
    "marketing": [
        "marketing_campaign_planning",
        "marketing_audience_segmentation",
        "marketing_content_operations",
        "marketing_channel_performance",
        "marketing_paid_acquisition",
        "marketing_email_lifecycle",
        "marketing_web_analytics",
        "marketing_attribution_modeling",
        "marketing_brand_tracking",
        "marketing_event_marketing",
    ],
    "finance": [
        "finance_general_ledger",
        "finance_accounts_payable",
        "finance_accounts_receivable",
        "finance_cash_management",
        "finance_budget_planning",
        "finance_expense_control",
        "finance_revenue_recognition",
        "finance_tax_reporting",
        "finance_financial_closing",
        "finance_variance_analysis",
    ],
    "operations": [
        "operations_inventory_management",
        "operations_procurement",
        "operations_fulfillment",
        "operations_logistics",
        "operations_supply_chain_planning",
        "operations_quality_control",
        "operations_workforce_planning",
        "operations_capacity_management",
        "operations_service_delivery",
        "operations_process_improvement",
    ],
}


def build_child_dag(schedule_tag: str, topic_tag: str) -> DAG:
    dag_id = f"cosmos_{schedule_tag}_{topic_tag}"
    with DAG(
        dag_id=dag_id,
        start_date=datetime(2024, 1, 1),
        schedule=None,
        catchup=False,
        is_paused_upon_creation=False,
        default_args={"retries": 1},
    ) as dag:
        start = EmptyOperator(task_id="start")
        end = EmptyOperator(task_id="end")

        groups = []
        for subcategory_tag in TOPIC_SUBCATEGORIES[topic_tag]:
            group = DbtTaskGroup(
                group_id=f"tg_{schedule_tag}_{topic_tag}_{subcategory_tag}",
                project_config=ProjectConfig(
                    dbt_project_path=DBT_PROJECT_PATH,
                    manifest_path=DBT_MANIFEST_PATH,
                    project_name="airflow_dbt_local_1000_models",
                    install_dbt_deps=False,
                ),
                profile_config=PROFILE_CONFIG,
                render_config=RenderConfig(
                    select=[f"tag:{schedule_tag},tag:{topic_tag},tag:{subcategory_tag}"],
                    load_method=LoadMode.DBT_MANIFEST,
                    test_behavior=TestBehavior.AFTER_EACH,
                ),
                execution_config=ExecutionConfig(invocation_mode=InvocationMode.SUBPROCESS),
                operator_args={"install_deps": False},
            )
            start >> group
            group >> end
            groups.append(group)

    return dag


for _schedule_tag in ["daily", "weekly", "monthly"]:
    for _topic_tag in ["sales", "marketing", "finance", "operations"]:
        dag = build_child_dag(_schedule_tag, _topic_tag)
        globals()[dag.dag_id] = dag
