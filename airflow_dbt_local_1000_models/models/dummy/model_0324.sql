{{ config(tags=['daily', 'operations', 'operations_process_improvement']) }}
with parent as (
    select * from {{ ref('model_0320') }}
)

select dummy_id + 1 as dummy_id
from parent
