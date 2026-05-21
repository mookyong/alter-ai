select
    'a_customer' as model_name,
    customer_id,
    customer_name
from {{ ref('a_customer') }}

union all

select
    'b_customer' as model_name,
    customer_id,
    customer_name
from {{ ref('b_customer') }}
