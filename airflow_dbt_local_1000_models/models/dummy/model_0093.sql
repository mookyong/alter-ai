{{ config(tags=['daily', 'sales', 'sales_opportunity_management']) }}
with parent as (
    select * from {{ ref('model_0089') }}
)

select dummy_id + 1 as dummy_id
from parent
