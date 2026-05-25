{{ config(tags=['monthly', 'sales', 'sales_opportunity_management']) }}
with parent as (
    select * from {{ ref('model_0749') }}
)

select dummy_id + 1 as dummy_id
from parent
