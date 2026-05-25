{{ config(tags=['monthly', 'marketing', 'marketing_email_lifecycle']) }}
with parent as (
    select * from {{ ref('model_0850') }}
)

select dummy_id + 1 as dummy_id
from parent
