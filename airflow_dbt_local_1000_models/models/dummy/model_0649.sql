{{ config(tags=['weekly', 'sales', 'sales_sales_compensation']) }}
with parent as (
    select * from {{ ref('model_0645') }}
)

select dummy_id + 1 as dummy_id
from parent
