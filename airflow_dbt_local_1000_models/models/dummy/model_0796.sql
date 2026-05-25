{{ config(tags=['monthly', 'operations', 'operations_logistics']) }}
with parent as (
    select * from {{ ref('model_0792') }}
)

select dummy_id + 1 as dummy_id
from parent
