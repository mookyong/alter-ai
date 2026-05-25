{{ config(tags=['weekly', 'operations', 'operations_workforce_planning']) }}
with parent as (
    select * from {{ ref('model_0564') }}
)

select dummy_id + 1 as dummy_id
from parent
