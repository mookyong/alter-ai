{{ config(tags=['weekly', 'marketing', 'marketing_content_operations']) }}
with parent as (
    select * from {{ ref('model_0434') }}
)

select dummy_id + 1 as dummy_id
from parent
