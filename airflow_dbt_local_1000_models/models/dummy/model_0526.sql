{{ config(tags=['weekly', 'marketing', 'marketing_email_lifecycle']) }}
with parent as (
    select * from {{ ref('model_0522') }}
)

select dummy_id + 1 as dummy_id
from parent
