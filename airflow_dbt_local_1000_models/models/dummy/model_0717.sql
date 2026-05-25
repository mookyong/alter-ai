{{ config(tags=['monthly', 'sales', 'sales_lead_qualification']) }}
with parent as (
    select * from {{ ref('model_0713') }}
)

select dummy_id + 1 as dummy_id
from parent
