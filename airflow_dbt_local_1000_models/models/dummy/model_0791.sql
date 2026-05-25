{{ config(tags=['monthly', 'finance', 'finance_cash_management']) }}
with parent as (
    select * from {{ ref('model_0787') }}
)

select dummy_id + 1 as dummy_id
from parent
