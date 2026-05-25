{{ config(tags=['daily', 'finance', 'finance_revenue_recognition']) }}
with parent as (
    select * from {{ ref('model_0223') }}
)

select dummy_id + 1 as dummy_id
from parent
