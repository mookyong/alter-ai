{{ config(tags=['daily', 'marketing', 'marketing_audience_segmentation']) }}
with parent as (
    select * from {{ ref('model_0050') }}
)

select dummy_id + 1 as dummy_id
from parent
