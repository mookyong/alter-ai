{{ config(tags=['monthly', 'sales', 'sales_order_processing']) }}
with parent as (
    select * from {{ ref('model_0845') }}
)

select dummy_id + 1 as dummy_id
from parent
