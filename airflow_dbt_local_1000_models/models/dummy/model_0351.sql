{{ config(tags=['weekly', 'finance', 'finance_general_ledger']) }}
with parent as (
    select * from {{ ref('model_0347') }}
)

select dummy_id + 1 as dummy_id
from parent
