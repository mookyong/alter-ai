{{ config(tags=['monthly', 'finance', 'finance_budget_planning']) }}
with parent as (
    select * from {{ ref('model_0815') }}
)

select dummy_id + 1 as dummy_id
from parent
