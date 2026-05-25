{{ config(tags=['weekly', 'finance', 'finance_financial_closing']) }}
with parent as (
    select * from {{ ref('model_0615') }}
)

select dummy_id + 1 as dummy_id
from parent
