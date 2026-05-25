{{ config(tags=['monthly', 'finance', 'finance_revenue_recognition']) }}
with parent as (
    select * from {{ ref('model_0875') }}
)

select dummy_id + 1 as dummy_id
from parent
