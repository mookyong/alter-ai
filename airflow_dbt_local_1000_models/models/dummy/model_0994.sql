{{ config(tags=['monthly', 'marketing', 'marketing_event_marketing']) }}
with parent as (
    select * from {{ ref('model_0990') }}
)

select dummy_id + 1 as dummy_id
from parent
