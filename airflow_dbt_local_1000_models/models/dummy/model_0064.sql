{{ config(tags=['daily', 'operations', 'operations_procurement']) }}
with parent as (
    select * from {{ ref('model_0060') }}
)

select dummy_id + 1 as dummy_id
from parent
