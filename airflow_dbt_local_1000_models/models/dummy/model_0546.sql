{{ config(tags=['weekly', 'marketing', 'marketing_web_analytics']) }}
with parent as (
    select * from {{ ref('model_0542') }}
)

select dummy_id + 1 as dummy_id
from parent
