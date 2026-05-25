{{ config(tags=['monthly', 'finance', 'finance_accounts_receivable']) }}
with parent as (
    select * from {{ ref('model_0759') }}
)

select dummy_id + 1 as dummy_id
from parent
