{{ config(tags=['monthly', 'finance', 'finance_general_ledger']) }}
with parent as (
    select * from {{ ref('model_0667') }}
)

select dummy_id + 1 as dummy_id
from parent
