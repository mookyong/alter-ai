{{ config(tags=['monthly', 'sales', 'sales_revenue_forecasting']) }}
with parent as (
    select * from {{ ref('model_0877') }}
)

select dummy_id + 1 as dummy_id
from parent
