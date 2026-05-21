select
    customer_id,
    customer_name,
    city
from {{ source('raw', 'customers') }}
