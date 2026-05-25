{{ config(tags=['weekly', 'finance', 'finance_expense_control']) }}
with parent as (
    select * from {{ ref('model_0519') }}
)

select dummy_id + 1 as dummy_id
from parent
