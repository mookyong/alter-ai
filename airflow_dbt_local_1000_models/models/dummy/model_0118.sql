{{ config(tags=['daily', 'marketing', 'marketing_channel_performance']) }}
with parent as (
    select * from {{ ref('model_0114') }}
)

select dummy_id + 1 as dummy_id
from parent
