{{ config(tags=['daily', 'sales', 'sales_order_processing']) }}
with parent as (
    select * from {{ ref('model_0193') }}
)

select dummy_id + 1 as dummy_id
from parent
