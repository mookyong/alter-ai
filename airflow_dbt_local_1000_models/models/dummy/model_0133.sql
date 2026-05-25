{{ config(tags=['daily', 'sales', 'sales_pipeline_analytics']) }}
with parent as (
    select * from {{ ref('model_0129') }}
)

select dummy_id + 1 as dummy_id
from parent
