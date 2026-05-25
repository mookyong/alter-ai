{{ config(tags=['daily', 'marketing', 'marketing_campaign_planning']) }}
with parent as (
    select * from {{ ref('model_0014') }}
)

select dummy_id + 1 as dummy_id
from parent
