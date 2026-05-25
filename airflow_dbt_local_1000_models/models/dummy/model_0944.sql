{{ config(tags=['monthly', 'operations', 'operations_service_delivery']) }}
with parent as (
    select * from {{ ref('model_0940') }}
)

select dummy_id + 1 as dummy_id
from parent
