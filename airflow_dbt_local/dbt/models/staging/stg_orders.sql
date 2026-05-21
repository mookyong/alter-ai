select
    order_id,
    customer_id,
    order_amount,
    order_date
from {{ source('raw', 'orders') }}
