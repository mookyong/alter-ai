{{ config(tags=['weekly', 'operations', 'operations_inventory_management']) }}
with parent as (
    select * from {{ ref('model_0360') }}
)

select dummy_id + 1 as dummy_id
from parent
