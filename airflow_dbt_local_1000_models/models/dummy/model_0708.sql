{{ config(tags=['monthly', 'operations', 'operations_procurement']) }}
with parent as (
    select * from {{ ref('model_0704') }}
)

select dummy_id + 1 as dummy_id
from parent
