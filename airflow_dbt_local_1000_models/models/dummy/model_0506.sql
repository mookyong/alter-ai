{{ config(tags=['weekly', 'marketing', 'marketing_paid_acquisition']) }}
with parent as (
    select * from {{ ref('model_0502') }}
)

select dummy_id + 1 as dummy_id
from parent
