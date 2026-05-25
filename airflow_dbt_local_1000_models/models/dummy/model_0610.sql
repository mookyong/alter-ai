{{ config(tags=['weekly', 'marketing', 'marketing_brand_tracking']) }}
with parent as (
    select * from {{ ref('model_0606') }}
)

select dummy_id + 1 as dummy_id
from parent
