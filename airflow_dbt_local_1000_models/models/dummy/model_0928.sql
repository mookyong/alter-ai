{{ config(tags=['monthly', 'operations', 'operations_capacity_management']) }}
with parent as (
    select * from {{ ref('model_0924') }}
)

select dummy_id + 1 as dummy_id
from parent
