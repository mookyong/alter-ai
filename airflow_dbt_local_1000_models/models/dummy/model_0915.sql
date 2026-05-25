{{ config(tags=['monthly', 'finance', 'finance_tax_reporting']) }}
with parent as (
    select * from {{ ref('model_0911') }}
)

select dummy_id + 1 as dummy_id
from parent
