{{ config(tags=['daily', 'finance', 'finance_cash_management']) }}
with parent as (
    select * from {{ ref('model_0115') }}
)

select dummy_id + 1 as dummy_id
from parent
