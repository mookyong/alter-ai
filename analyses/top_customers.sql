select
    customer_id,
    customer_name,
    customer_segment,
    total_revenue,
    order_count,
    last_order_date
from {{ ref('dim_customers') }}
order by total_revenue desc, order_count desc
limit 10
