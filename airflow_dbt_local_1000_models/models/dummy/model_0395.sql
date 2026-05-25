{{ config(tags=['weekly', 'finance', 'finance_accounts_payable']) }}
with parent as (
    select * from {{ ref('model_0391') }}
)

select dummy_id + 1 as dummy_id
from parent
