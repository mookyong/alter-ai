{{ config(tags=['monthly', 'sales', 'sales_sales_compensation']) }}
with parent as (
    select * from {{ ref('model_0993') }}
)

select dummy_id + 1 as dummy_id
from parent
