{{ config(tags=['weekly', 'sales', 'sales_renewal_and_retention']) }}
with parent as (
    select * from {{ ref('model_0613') }}
)

select dummy_id + 1 as dummy_id
from parent
