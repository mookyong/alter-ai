{{ config(tags=['monthly', 'marketing', 'marketing_content_operations']) }}
with parent as (
    select * from {{ ref('model_0758') }}
)

select dummy_id + 1 as dummy_id
from parent
