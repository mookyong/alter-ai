{{ config(tags=['monthly', 'marketing', 'marketing_attribution_modeling']) }}
with parent as (
    select * from {{ ref('model_0906') }}
)

select dummy_id + 1 as dummy_id
from parent
