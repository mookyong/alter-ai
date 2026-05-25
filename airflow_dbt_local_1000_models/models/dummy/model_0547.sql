{{ config(tags=['weekly', 'finance', 'finance_revenue_recognition']) }}
with parent as (
    select * from {{ ref('model_0543') }}
)

select dummy_id + 1 as dummy_id
from parent
