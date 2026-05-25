{{ config(tags=['daily', 'marketing', 'marketing_event_marketing']) }}
with parent as (
    select * from {{ ref('model_0310') }}
)

select dummy_id + 1 as dummy_id
from parent
