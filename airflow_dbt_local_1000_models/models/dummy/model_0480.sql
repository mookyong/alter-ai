{{ config(tags=['weekly', 'operations', 'operations_supply_chain_planning']) }}
with parent as (
    select * from {{ ref('model_0476') }}
)

select dummy_id + 1 as dummy_id
from parent
