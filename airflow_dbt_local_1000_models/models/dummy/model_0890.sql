{{ config(tags=['monthly', 'marketing', 'marketing_web_analytics']) }}
with parent as (
    select * from {{ ref('model_0886') }}
)

select dummy_id + 1 as dummy_id
from parent
