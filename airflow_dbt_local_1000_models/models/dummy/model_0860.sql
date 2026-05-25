{{ config(tags=['monthly', 'operations', 'operations_quality_control']) }}
with parent as (
    select * from {{ ref('model_0856') }}
)

select dummy_id + 1 as dummy_id
from parent
