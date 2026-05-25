{{ config(tags=['daily', 'finance', 'finance_accounts_receivable']) }}
with parent as (
    select * from {{ ref('model_0087') }}
)

select dummy_id + 1 as dummy_id
from parent
