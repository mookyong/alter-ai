{{ config(tags=['weekly', 'marketing', 'marketing_audience_segmentation']) }}
with parent as (
    select * from {{ ref('model_0378') }}
)

select dummy_id + 1 as dummy_id
from parent
