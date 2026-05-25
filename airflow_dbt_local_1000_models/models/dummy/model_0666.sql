{{ config(tags=['weekly', 'marketing', 'marketing_event_marketing']) }}
with parent as (
    select * from {{ ref('model_0662') }}
)

select dummy_id + 1 as dummy_id
from parent
