{{ config(tags=['daily', 'sales', 'sales_lead_qualification']) }}
with parent as (
    select * from {{ ref('model_0057') }}
)

select dummy_id + 1 as dummy_id
from parent
