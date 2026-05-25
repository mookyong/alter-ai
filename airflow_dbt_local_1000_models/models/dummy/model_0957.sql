{{ config(tags=['monthly', 'sales', 'sales_renewal_and_retention']) }}
with parent as (
    select * from {{ ref('model_0953') }}
)

select dummy_id + 1 as dummy_id
from parent
