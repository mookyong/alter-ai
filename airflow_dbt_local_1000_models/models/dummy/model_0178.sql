{{ config(tags=['daily', 'marketing', 'marketing_email_lifecycle']) }}
with parent as (
    select * from {{ ref('model_0174') }}
)

select dummy_id + 1 as dummy_id
from parent
