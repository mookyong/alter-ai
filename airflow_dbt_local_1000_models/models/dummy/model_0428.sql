{{ config(tags=['weekly', 'operations', 'operations_fulfillment']) }}
with parent as (
    select * from {{ ref('model_0424') }}
)

select dummy_id + 1 as dummy_id
from parent
