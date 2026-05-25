{{ config(tags=['monthly', 'finance', 'finance_variance_analysis']) }}
with parent as (
    select * from {{ ref('model_0983') }}
)

select dummy_id + 1 as dummy_id
from parent
