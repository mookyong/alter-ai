{{ config(tags=['daily', 'sales', 'sales_sales_compensation']) }}
with parent as (
    select * from {{ ref('model_0317') }}
)

select dummy_id + 1 as dummy_id
from parent
