{{ config(tags=['weekly', 'operations', 'operations_process_improvement']) }}
with parent as (
    select * from {{ ref('model_0644') }}
)

select dummy_id + 1 as dummy_id
from parent
