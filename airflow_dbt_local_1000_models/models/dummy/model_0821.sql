{{ config(tags=['monthly', 'sales', 'sales_quote_and_pricing']) }}
with parent as (
    select * from {{ ref('model_0817') }}
)

select dummy_id + 1 as dummy_id
from parent
