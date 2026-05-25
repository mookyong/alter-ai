{{ config(tags=['monthly', 'operations', 'operations_inventory_management']) }}
with parent as (
    select * from {{ ref('model_0680') }}
)

select dummy_id + 1 as dummy_id
from parent
