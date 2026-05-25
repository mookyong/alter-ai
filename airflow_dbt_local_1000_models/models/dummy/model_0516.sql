{{ config(tags=['weekly', 'operations', 'operations_quality_control']) }}
with parent as (
    select * from {{ ref('model_0512') }}
)

select dummy_id + 1 as dummy_id
from parent
