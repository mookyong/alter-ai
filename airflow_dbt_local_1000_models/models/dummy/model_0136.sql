{{ config(tags=['daily', 'operations', 'operations_logistics']) }}
with parent as (
    select * from {{ ref('model_0132') }}
)

select dummy_id + 1 as dummy_id
from parent
