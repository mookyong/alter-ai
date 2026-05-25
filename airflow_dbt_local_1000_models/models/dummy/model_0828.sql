{{ config(tags=['monthly', 'operations', 'operations_supply_chain_planning']) }}
with parent as (
    select * from {{ ref('model_0824') }}
)

select dummy_id + 1 as dummy_id
from parent
