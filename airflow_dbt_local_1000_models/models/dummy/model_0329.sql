{{ config(tags=['daily', 'sales', 'sales_sales_compensation']) }}
with parent as (
    select * from {{ ref('model_0325') }}
)

select dummy_id + 1 as dummy_id
from parent
