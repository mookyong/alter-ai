{{ config(tags=['daily', 'finance', 'finance_accounts_payable']) }}
with parent as (
    select * from {{ ref('model_0047') }}
)

select dummy_id + 1 as dummy_id
from parent
