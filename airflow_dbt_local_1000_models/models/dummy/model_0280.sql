{{ config(tags=['daily', 'operations', 'operations_service_delivery']) }}
with parent as (
    select * from {{ ref('model_0276') }}
)

select dummy_id + 1 as dummy_id
from parent
