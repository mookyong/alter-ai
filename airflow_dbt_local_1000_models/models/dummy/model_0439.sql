{{ config(tags=['weekly', 'finance', 'finance_accounts_receivable']) }}
with parent as (
    select * from {{ ref('model_0435') }}
)

select dummy_id + 1 as dummy_id
from parent
