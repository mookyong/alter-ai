-- depends_on: {{ ref('stg_orders') }}

select
    customer_id,
    count(*) as order_count,
    sum(order_amount) as total_order_amount
from {{ ref('stg_orders') }}
group by 1
