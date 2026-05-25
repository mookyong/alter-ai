{{ config(tags=['daily', 'marketing', 'marketing_attribution_modeling']) }}
with parent as (
    select * from {{ ref('model_0238') }}
)

select dummy_id + 1 as dummy_id
from parent
