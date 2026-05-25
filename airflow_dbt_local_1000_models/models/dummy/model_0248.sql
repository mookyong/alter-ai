{{ config(tags=['daily', 'operations', 'operations_capacity_management']) }}
with parent as (
    select * from {{ ref('model_0244') }}
)

select dummy_id + 1 as dummy_id
from parent
