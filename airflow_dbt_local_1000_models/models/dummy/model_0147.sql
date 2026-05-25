{{ config(tags=['daily', 'finance', 'finance_budget_planning']) }}
with parent as (
    select * from {{ ref('model_0143') }}
)

select dummy_id + 1 as dummy_id
from parent
