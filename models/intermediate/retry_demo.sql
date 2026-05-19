{{ config(materialized='table', enabled=var('enable_retry_demo', false)) }}

select
    task_name,
    case
        when should_fail then cast(task_name as integer)
        else 1
    end as retry_status
from {{ source('raw_orders_training', 'retry_controls') }}
where task_name = 'demo_retry'
