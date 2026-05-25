{{ config(tags=['daily', 'finance', 'finance_accounts_payable']) }}
with parent as (
    select * from {{ ref('model_0059') }}
)

select dummy_id + 1 as dummy_id
from parent
