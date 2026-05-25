{{ config(tags=['weekly', 'finance', 'finance_variance_analysis']) }}
with parent as (
    select * from {{ ref('model_0655') }}
)

select dummy_id + 1 as dummy_id
from parent
