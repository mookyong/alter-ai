{{ config(tags=['weekly', 'sales', 'sales_account_management']) }}
with parent as (
    select * from {{ ref('model_0597') }}
)

select dummy_id + 1 as dummy_id
from parent
