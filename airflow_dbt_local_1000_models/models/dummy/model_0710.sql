{{ config(tags=['monthly', 'marketing', 'marketing_audience_segmentation']) }}
with parent as (
    select * from {{ ref('model_0706') }}
)

select dummy_id + 1 as dummy_id
from parent
