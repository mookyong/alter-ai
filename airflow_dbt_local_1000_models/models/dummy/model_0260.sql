{{ config(tags=['daily', 'operations', 'operations_capacity_management']) }}
with parent as (
    select * from {{ ref('model_0256') }}
)

select dummy_id + 1 as dummy_id
from parent
