{{ config(tags=['weekly', 'sales', 'sales_lead_generation']) }}
with parent as (
    select * from {{ ref('model_0361') }}
)

select dummy_id + 1 as dummy_id
from parent
