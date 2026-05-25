{{ config(tags=['daily', 'operations', 'operations_logistics']) }}
with parent as (
    select * from {{ ref('model_0112') }}
)

select dummy_id + 1 as dummy_id
from parent
