{{ config(tags=['weekly', 'sales', 'sales_quote_and_pricing']) }}
with parent as (
    select * from {{ ref('model_0497') }}
)

select dummy_id + 1 as dummy_id
from parent
