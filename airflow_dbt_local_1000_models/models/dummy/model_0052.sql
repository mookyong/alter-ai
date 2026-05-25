{{ config(tags=['daily', 'operations', 'operations_procurement']) }}
with parent as (
    select * from {{ ref('model_0048') }}
)

select dummy_id + 1 as dummy_id
from parent
