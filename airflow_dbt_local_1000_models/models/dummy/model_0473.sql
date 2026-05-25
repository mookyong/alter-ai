{{ config(tags=['weekly', 'sales', 'sales_pipeline_analytics']) }}
with parent as (
    select * from {{ ref('model_0469') }}
)

select dummy_id + 1 as dummy_id
from parent
