{{ config(tags=['monthly', 'operations', 'operations_fulfillment']) }}
with parent as (
    select * from {{ ref('model_0748') }}
)

select dummy_id + 1 as dummy_id
from parent
