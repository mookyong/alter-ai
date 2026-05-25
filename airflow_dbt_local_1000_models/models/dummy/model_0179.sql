{{ config(tags=['daily', 'finance', 'finance_expense_control']) }}
with parent as (
    select * from {{ ref('model_0175') }}
)

select dummy_id + 1 as dummy_id
from parent
