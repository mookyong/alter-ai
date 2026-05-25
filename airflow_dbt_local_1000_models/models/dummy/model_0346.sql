{{ config(tags=['weekly', 'marketing', 'marketing_campaign_planning']) }}
with parent as (
    select * from {{ ref('model_0342') }}
)

select dummy_id + 1 as dummy_id
from parent
